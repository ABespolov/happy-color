import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/painters/coloring_canvas_painter.dart';
import 'package:happy_color/features/coloring/presentation/rendering/picture_images.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';

/// Everything the coloring view draws with.
class ColoringScene {
  const ColoringScene({
    required this.picture,
    required this.shader,
    required this.regionMap,
    required this.artwork,
    required this.lines,
  });

  final ColoringPicture picture;
  final ui.FragmentShader shader;
  final ui.Image regionMap;
  final ui.Image artwork;
  final ui.Image lines;

  void dispose() {
    shader.dispose();
    regionMap.dispose();
    artwork.dispose();
    lines.dispose();
  }

  static Future<void> disposeLoaded(Future<ColoringScene> scene) async {
    try {
      (await scene).dispose();
    } on Object {
      return;
    }
  }
}

final coloringSceneLoaderProvider = Provider<ColoringSceneLoader>((ref) {
  final loader = ColoringSceneLoader(ref.read(previewCacheProvider));
  ref.onDispose(loader.dispose);
  return loader;
});

/// Loads a scene, and can start on one ahead of time so the coloring page
/// opens on textures that are already decoded.
class ColoringSceneLoader {
  ColoringSceneLoader(this._previews);

  final PreviewCache _previews;

  (String, Future<ColoringScene>)? _warmed;

  void warm(String assetDir) {
    if (_warmed?.$1 == assetDir) return;
    _dropWarmed();
    _warmed = (assetDir, _load(assetDir));
  }

  /// The caller owns the scene.
  Future<ColoringScene> take(String assetDir) {
    final warmed = _warmed;
    if (warmed != null && warmed.$1 == assetDir) {
      _warmed = null;
      return warmed.$2;
    }
    return _load(assetDir);
  }

  void _dropWarmed() {
    if (_warmed case (_, final scene)?) {
      unawaited(ColoringScene.disposeLoaded(scene));
    }
    _warmed = null;
  }

  void dispose() => _dropWarmed();

  Future<ColoringScene> _load(String dir) async {
    final (program, json, regions, artwork, lines) = await (
      coloringProgram,
      rootBundle.loadString('$dir/picture.json'),
      // Shared with the previews.
      _previews.regionTexture(dir),
      loadImage('$dir/artwork.webp'),
      loadImage('$dir/lines.webp'),
    ).wait;
    final regionBytes = (await regions.toByteData())!;
    return ColoringScene(
      picture: ColoringPicture.fromJson(
        json,
        regionMapRgba: regionBytes,
        mapWidth: regions.width,
        mapHeight: regions.height,
      ),
      shader: program.fragmentShader(),
      regionMap: regions,
      artwork: artwork,
      lines: lines,
    );
  }
}
