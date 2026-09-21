import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/presentation/rendering/picture_images.dart';
import 'package:happy_color/features/coloring/presentation/rendering/preview_renderer.dart';

final previewCacheProvider = Provider<PreviewCache>((ref) {
  final cache = PreviewCache();
  ref.onDispose(cache.clear);
  return cache;
});

/// A picture at a size with some regions colored.
@immutable
class PreviewKey {
  PreviewKey({
    required this.assetDir,
    required this.size,
    required Set<int> filled,
  }) : filled = Set.unmodifiable(filled),
       _hash = Object.hash(assetDir, size, Object.hashAllUnordered(filled));

  final String assetDir;
  final int size;
  final Set<int> filled;
  final int _hash;

  /// The same picture colored the same way, at any size.
  bool looksLike(PreviewKey other) =>
      other.assetDir == assetDir && setEquals(other.filled, filled);

  @override
  bool operator ==(Object other) =>
      other is PreviewKey && other.size == size && looksLike(other);

  @override
  int get hashCode => _hash;
}

/// Rendered previews, so scrolling a grid does not render the same picture
/// over and over. The oldest go once they take more than [budgetBytes].
///
/// Every image it hands out is a clone the caller disposes of, so the cache
/// can let go of its own at any time.
class PreviewCache {
  PreviewCache({this.budgetBytes = 32 << 20});

  final int budgetBytes;

  /// Least recently used first.
  final _ready = <PreviewKey, ui.Image>{};
  var _bytes = 0;

  /// Renders under way, with everyone waiting for each.
  final _rendering = <PreviewKey, List<Completer<ui.Image>>>{};

  var _cleared = false;

  ui.Image? ready(PreviewKey key) {
    final image = _ready.remove(key);
    if (image == null) return null;
    _ready[key] = image;
    return image.clone();
  }

  /// Something to show, scaled, while the right size renders.
  ui.Image? readyAtOtherSize(PreviewKey key) {
    for (final MapEntry(key: other, value: image) in _ready.entries) {
      if (other.looksLike(key)) return image.clone();
    }
    return null;
  }

  /// The preview, rendered unless it is ready.
  Future<ui.Image> preview(PreviewKey key) {
    if (ready(key) case final image?) return Future.value(image);
    final waiter = Completer<ui.Image>();
    if (_rendering[key] case final waiters?) {
      waiters.add(waiter);
    } else {
      _rendering[key] = [waiter];
      unawaited(_render(key));
    }
    return waiter.future;
  }

  Future<void> warm(PreviewKey key) async => (await preview(key)).dispose();

  Future<void> _render(PreviewKey key) async {
    final waiters = _rendering[key]!;
    try {
      final image = await renderPreview(
        assetDir: key.assetDir,
        size: key.size,
        filled: key.filled,
        regionMap: regionTexture(key.assetDir),
      );
      for (final waiter in waiters) {
        waiter.complete(image.clone());
      }
      _keep(key, image);
    } on Object catch (error, stack) {
      for (final waiter in waiters) {
        waiter.completeError(error, stack);
      }
    } finally {
      _rendering.remove(key);
    }
  }

  void _keep(PreviewKey key, ui.Image image) {
    if (_cleared) return image.dispose();
    _ready[key] = image;
    _bytes += _sizeOf(key);
    while (_bytes > budgetBytes && _ready.length > 1) {
      final oldest = _ready.keys.first;
      _bytes -= _sizeOf(oldest);
      _ready.remove(oldest)!.dispose();
    }
  }

  static int _sizeOf(PreviewKey key) => key.size * key.size * 4;

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

  void clear() {
    _cleared = true;
    for (final image in _ready.values) {
      image.dispose();
    }
    _ready.clear();
    _bytes = 0;
    for (final map in _regionMaps.values) {
      unawaited(_disposeLoaded(map));
    }
    _regionMaps.clear();
  }
}
