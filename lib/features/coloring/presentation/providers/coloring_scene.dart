import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';

/// Everything the coloring view draws with: the picture, the shader and the
/// three textures. Owned by whoever took it from [ColoringSceneLoader].
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
}

final coloringSceneLoaderProvider = Provider<ColoringSceneLoader>((ref) {
  final loader = ColoringSceneLoader(ref.read(previewCacheProvider));
  ref.onDispose(loader.dispose);
  return loader;
});

/// Loads a scene, and can start on one ahead of time: the sheet that offers
/// to continue a picture warms its scene up, so the coloring page opens on
/// textures that are already decoded.
class ColoringSceneLoader {
  ColoringSceneLoader(this._previews);

  final PreviewCache _previews;

  /// The one scene loaded ahead of time, and the folder it is for.
  (String, Future<ColoringScene>)? _warmed;

  Future<ui.FragmentProgram>? _program;

  /// The coloring shader, read from the bundle the first time it is asked
  /// for and kept from then on.
  Future<ui.FragmentProgram> get program =>
      _program ??= ui.FragmentProgram.fromAsset('shaders/coloring.frag');

  /// Starts loading the scene of [assetDir] unless it is on its way already.
  void warm(String assetDir) {
    if (_warmed?.$1 == assetDir) return;
    _dropWarmed();
    _warmed = (assetDir, _load(assetDir));
  }

  /// The scene of [assetDir], warmed up or loaded now. The caller owns it.
  Future<ColoringScene> take(String assetDir) {
    final warmed = _warmed;
    if (warmed != null && warmed.$1 == assetDir) {
      _warmed = null;
      return warmed.$2;
    }
    return _load(assetDir);
  }

  /// A scene warmed up for a picture that was never opened is let go.
  void _dropWarmed() {
    _warmed?.$2.then((scene) => scene.dispose()).ignore();
    _warmed = null;
  }

  void dispose() => _dropWarmed();

  Future<ColoringScene> _load(String dir) async {
    final (program, json, regions, artwork, lines) = await (
      this.program,
      rootBundle.loadString('$dir/picture.json'),
      // The preview of this picture has decoded its region map already, so
      // the texture is uploaded from those pixels instead of decoded again.
      _previews.regionMap(dir, () => loadRegionMap(dir)),
      _image('$dir/artwork.webp'),
      _image('$dir/lines.webp'),
    ).wait;
    return ColoringScene(
      picture: ColoringPicture.fromJson(
        json,
        regionMapRgba: ByteData.sublistView(regions.bytes),
        mapWidth: regions.width,
        mapHeight: regions.height,
      ),
      shader: program.fragmentShader(),
      regionMap: await decodePixels(
        regions.bytes,
        regions.width,
        regions.height,
      ),
      artwork: artwork,
      lines: lines,
    );
  }

  static Future<ui.Image> _image(String asset) async {
    final bytes = await rootBundle.load(asset);
    return decodeImageFromList(bytes.buffer.asUint8List());
  }
}
