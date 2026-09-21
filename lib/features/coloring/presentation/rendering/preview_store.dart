import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/presentation/rendering/picture_images.dart';
import 'package:happy_color/features/coloring/presentation/rendering/preview_renderer.dart';
import 'package:path_provider/path_provider.dart';

final previewStoreProvider = Provider<PreviewStore>(
  (ref) => throw UnimplementedError('override previewStoreProvider'),
);

/// Opens the store in the app's support directory.
Future<PreviewStore> createPreviewStore() async {
  final support = await getApplicationSupportDirectory();
  return PreviewStore.open(Directory('${support.path}/previews'));
}

/// Previews of the pictures being colored, rendered once and saved as PNG
/// files, one per picture, so every screen decodes them at the size it needs.
class PreviewStore {
  PreviewStore._(this._dir, this._files);

  static Future<PreviewStore> open(Directory dir) async {
    await dir.create(recursive: true);
    final files = <String, File>{};
    await for (final entry in dir.list()) {
      if (entry is! File) continue;
      final name = entry.uri.pathSegments.last;
      final split = name.lastIndexOf('__');
      if (!name.endsWith('.png') || split < 0) {
        // A write cut short.
        await entry.delete();
        continue;
      }
      files[name.substring(0, split)] = entry;
    }
    return PreviewStore._(dir, files);
  }

  /// Enough for a full-width picture on a phone.
  static const size = 1024;

  final Directory _dir;

  /// The latest saved preview of every picture, by [_pictureId].
  final Map<String, File> _files;

  /// The state last asked for, per picture: older renders that finish later
  /// do not replace it.
  final _wanted = <String, String>{};

  final _saving = <String, Future<File>>{};

  /// The preview of [assetDir] colored as [filled], if it is saved.
  File? saved(String assetDir, Set<int> filled) {
    final file = _files[_pictureId(assetDir)];
    return file?.path == _fileOf(assetDir, filled).path ? file : null;
  }

  /// The latest saved preview of [assetDir], even if it is out of date.
  File? latest(String assetDir) => _files[_pictureId(assetDir)];

  /// The preview of [assetDir] colored as [filled], rendered unless saved.
  Future<File> save(String assetDir, Set<int> filled) {
    if (saved(assetDir, filled) case final file?) return Future.value(file);
    final file = _fileOf(assetDir, filled);
    _wanted[_pictureId(assetDir)] = file.path;
    return _saving[file.path] ??= _render(assetDir, Set.of(filled), file);
  }

  Future<File> _render(String assetDir, Set<int> filled, File file) async {
    try {
      final image = await renderPreview(
        assetDir: assetDir,
        size: size,
        filled: filled,
        regionMap: regionTexture(assetDir),
      );
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final temp = File('${file.path}.tmp');
      await temp.writeAsBytes(
        png!.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes),
        flush: true,
      );
      await temp.rename(file.path);

      final picture = _pictureId(assetDir);
      if (_wanted[picture] == file.path) {
        final old = _files[picture];
        _files[picture] = file;
        if (old != null && old.path != file.path) unawaited(_delete(old));
      } else {
        // A newer state was asked for while this one rendered.
        unawaited(_delete(file));
      }
      return file;
    } finally {
      _saving.remove(file.path);
    }
  }

  static Future<void> _delete(File file) async {
    try {
      await file.delete();
    } on FileSystemException {
      return;
    }
  }

  File _fileOf(String assetDir, Set<int> filled) =>
      File('${_dir.path}/${_pictureId(assetDir)}__${_hash(filled)}.png');

  static String _pictureId(String assetDir) => assetDir.replaceAll('/', '_');

  /// FNV-1a over the sorted regions: stable from one run to the next, unlike
  /// [Object.hashAllUnordered].
  static String _hash(Set<int> filled) {
    var hash = 0x811C9DC5;
    for (final id in filled.toList()..sort()) {
      hash = ((hash ^ id) * 0x01000193) & 0xFFFFFFFF;
    }
    return '${filled.length}_${hash.toRadixString(16)}';
  }

  /// Decoded region maps. A picture's map is the same whatever is colored,
  /// and the coloring view draws with it too.
  final _regionMaps = <String, Future<ui.Image>>{};

  /// A few megabytes each.
  static const _regionMapsKept = 3;

  /// The region map of [assetDir], as a clone the caller disposes of.
  Future<ui.Image> regionTexture(String assetDir) async {
    var map = _regionMaps.remove(assetDir);
    if (map == null) {
      while (_regionMaps.length >= _regionMapsKept) {
        unawaited(_disposeLoaded(_regionMaps.remove(_regionMaps.keys.first)!));
      }
      map = loadRegionMap(assetDir);
    }
    _regionMaps[assetDir] = map;
    return (await map).clone();
  }

  static Future<void> _disposeLoaded(Future<ui.Image> image) async {
    try {
      (await image).dispose();
    } on Object {
      return;
    }
  }
}
