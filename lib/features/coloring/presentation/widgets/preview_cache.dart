import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';

final previewCacheProvider = Provider<PreviewCache>((ref) {
  final cache = PreviewCache();
  ref.onDispose(cache.clear);
  return cache;
});

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

  final _entries = <PreviewKey, Future<ui.Image>>{};

  /// The entries that have finished, so a card can paint them right away
  /// instead of waiting a frame for its future.
  final _ready = <PreviewKey, ui.Image>{};
  var _bytes = 0;

  ui.Image? ready(PreviewKey key) => _ready[key];

  /// A finished preview of the same picture with the same regions colored at
  /// some other size: a card's preview stands in for a full-screen one while
  /// that one is being rendered.
  PreviewKey? readyAtOtherSize(PreviewKey key) {
    for (final other in _ready.keys) {
      if (other.assetDir == key.assetDir && other._filled == key._filled) {
        return other;
      }
    }
    return null;
  }

  /// Cards in view hold on to the preview they paint, so it is not disposed
  /// of under them when the cache runs out of room.
  final _held = <PreviewKey, int>{};

  void retain(PreviewKey key) =>
      _held.update(key, (count) => count + 1, ifAbsent: () => 1);

  void release(PreviewKey key) {
    final count = (_held[key] ?? 1) - 1;
    if (count > 0) {
      _held[key] = count;
      return;
    }
    _held.remove(key);
    if (!_entries.containsKey(key)) _dispose(key);
  }

  /// Previews that were dropped while a card was still painting them.
  final _disposeWhenFree = <PreviewKey, Future<ui.Image>>{};

  /// Decoded region maps, by picture folder. The map of a picture is the same
  /// whatever is colored in it, so it is worth keeping while its previews are
  /// being rebuilt tap after tap, and the coloring view draws with it too.
  final _regionMaps = <String, Future<ui.Image>>{};

  /// The region map of [assetDir], as a handle of its own the caller
  /// disposes of: the cache may let go of its own while it is in use.
  Future<ui.Image> regionTexture(String assetDir) {
    final cached = _regionMaps.remove(assetDir);
    if (cached == null) {
      while (_regionMaps.length >= _regionMapsKept) {
        _disposeRegionMap(_regionMaps.keys.first);
      }
    }
    final map = _regionMaps[assetDir] = cached ?? loadRegionMap(assetDir);
    return map.then((image) => image.clone());
  }

  void _disposeRegionMap(String assetDir) {
    _regionMaps.remove(assetDir)?.then((image) => image.dispose()).ignore();
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
      image
          .then<void>((rendered) {
            // A preview dropped while it was rendering is not worth keeping.
            if (_entries[key] == image) _ready[key] = rendered;
          })
          .catchError((Object _) {}),
    );
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
    _ready.remove(key);
    if (image == null) return;
    _bytes -= key.size * key.size * 4;
    _disposeWhenFree[key] = image;
    if (!_held.containsKey(key)) _dispose(key);
  }

  void _dispose(PreviewKey key) {
    final image = _disposeWhenFree.remove(key);
    if (image == null) return;
    // The card may still be painting it, so let the frame finish first.
    image
        .then(
          (image) => WidgetsBinding.instance.addPostFrameCallback(
            (_) => image.dispose(),
          ),
        )
        .catchError((Object _) {});
  }

  void clear() {
    _ready.clear();
    _held.clear();
    _regionMaps.keys.toList().forEach(_disposeRegionMap);
    for (final key in _entries.keys.toList()) {
      _drop(key);
    }
  }
}
