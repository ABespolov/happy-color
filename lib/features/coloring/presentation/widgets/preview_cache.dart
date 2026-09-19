import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_worker.dart';

final previewCacheProvider = Provider<PreviewCache>((ref) {
  final cache = PreviewCache();
  ref.onDispose(cache.clear);
  return cache;
});

/// A decoded `regions.png`: the region of every pixel, row by row.
class RegionMap {
  const RegionMap({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

/// What a preview shows: the same picture with the same regions colored looks
/// the same, so it only has to be rendered once.
@immutable
class PreviewKey {
  PreviewKey({
    required this.assetDir,
    required this.size,
    required Set<int> filled,
  }) : _filled = Object.hashAllUnordered(filled);

  final String assetDir;
  final int size;
  final int _filled;

  @override
  bool operator ==(Object other) =>
      other is PreviewKey &&
      other.assetDir == assetDir &&
      other.size == size &&
      other._filled == _filled;

  @override
  int get hashCode => Object.hash(assetDir, size, _filled);
}

/// Keeps rendered previews around so scrolling a grid does not build the same
/// picture over and over, and drops the oldest ones once they take too much
/// memory.
class PreviewCache {
  PreviewCache({this.budgetBytes = 32 << 20});

  /// How much the rendered previews may take together.
  final int budgetBytes;

  /// Paints the previews off the isolate that draws the frames.
  final worker = PreviewWorker();

  final _entries = <PreviewKey, Future<ui.Image>>{};
  var _bytes = 0;

  /// Decoded region maps, by picture folder. The map of a picture is the same
  /// whatever is colored in it, so it is worth keeping while its previews are
  /// being rebuilt tap after tap.
  final _regionMaps = <String, Future<RegionMap>>{};

  Future<RegionMap> regionMap(
    String assetDir,
    Future<RegionMap> Function() load,
  ) {
    final cached = _regionMaps.remove(assetDir);
    if (cached != null) return _regionMaps[assetDir] = cached;
    while (_regionMaps.length >= _regionMapsKept) {
      _regionMaps.remove(_regionMaps.keys.first);
    }
    return _regionMaps[assetDir] = load();
  }

  /// Region maps are a few megabytes each, so only a handful are kept.
  static const _regionMapsKept = 3;

  Future<ui.Image> of(PreviewKey key, Future<ui.Image> Function() render) {
    final cached = _entries.remove(key);
    if (cached != null) {
      // Putting it back last makes it the most recently used one.
      return _entries[key] = cached;
    }
    final image = render();
    _entries[key] = image;
    _bytes += key.size * key.size * 4;
    unawaited(
      image.catchError((Object error) {
        _drop(key);
        throw error;
      }),
    );
    _evict();
    return image;
  }

  void _evict() {
    while (_bytes > budgetBytes && _entries.length > 1) {
      _drop(_entries.keys.first);
    }
  }

  void _drop(PreviewKey key) {
    final image = _entries.remove(key);
    if (image == null) return;
    _bytes -= key.size * key.size * 4;
    // The widget that asked for it may still be painting it, so let the frame
    // finish before the image goes away.
    image
        .then(
          (image) => WidgetsBinding.instance.addPostFrameCallback(
            (_) => image.dispose(),
          ),
        )
        .catchError((_) {});
  }

  void clear() {
    worker.dispose();
    _regionMaps.clear();
    for (final key in _entries.keys.toList()) {
      _drop(key);
    }
  }
}
