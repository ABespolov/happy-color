import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/widgets/color_palette.dart';
import 'package:happy_color/features/coloring/presentation/widgets/colored_preview.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';
import 'package:happy_color/features/coloring/presentation/widgets/coloring_view.dart';
import 'package:happy_color/l10n/app_localizations.dart';

typedef _Scene = ({
  ColoringPicture picture,
  ui.FragmentShader shader,
  ui.Image regionMap,
  ui.Image artwork,
  ui.Image lines,
});

class ColoringPage extends ConsumerStatefulWidget {
  const ColoringPage({super.key, required this.id, required this.assetDir});

  final String id;

  /// Folder with the files written by `tools/generate_picture.py`.
  final String assetDir;

  @override
  ConsumerState<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends ConsumerState<ColoringPage> {
  late final _scene = _load();

  Future<_Scene> _load() async {
    final dir = widget.assetDir;
    final (program, json, regions, artwork, lines) = await (
      ui.FragmentProgram.fromAsset('shaders/coloring.frag'),
      rootBundle.loadString('$dir/picture.json'),
      // The preview of this picture has decoded its region map already, so
      // the texture is uploaded from those pixels instead of decoded again.
      _previews.regionMap(dir, () => loadRegionMap(dir)),
      _image('$dir/artwork.webp'),
      _image('$dir/lines.webp'),
    ).wait;
    return (
      picture: ColoringPicture.fromJson(
        json,
        regionMapRgba: ByteData.sublistView(regions.bytes),
        mapWidth: regions.width,
        mapHeight: regions.height,
      ),
      shader: program.fragmentShader(),
      regionMap: await decodePixels(regions.bytes, regions.width, regions.height),
      artwork: artwork,
      lines: lines,
    );
  }

  static Future<ui.Image> _image(String asset) async {
    final bytes = await rootBundle.load(asset);
    return decodeImageFromList(bytes.buffer.asUint8List());
  }

  /// Kept in a field: `ref` cannot be read once the page is being disposed of.
  late final PreviewCache _previews = ref.read(previewCacheProvider);

  /// What was colored when the page last saved, used to build the card-sized
  /// preview the grid will need.
  Set<int> _lastSaved = const {};

  void _warmCardPreview() {
    if (_lastSaved.isEmpty) return;
    coloredPreview(
      _previews,
      assetDir: widget.assetDir,
      size: ColoredPreview.cardSize,
      filled: _lastSaved,
    ).ignore();
  }

  @override
  void dispose() {
    _warmCardPreview();
    _scene.then((scene) {
      scene.shader.dispose();
      scene.regionMap.dispose();
      scene.artwork.dispose();
      scene.lines.dispose();
    });
    super.dispose();
  }

  /// Read once: the view keeps the colored regions itself from then on.
  late final _filled = ref
      .read(progressProvider.notifier)
      .of(widget.id, widget.assetDir)
      .filled;

  void _saveFilled(Set<int> filled) {
    _lastSaved = filled;
    ref
        .read(progressProvider.notifier)
        .setFilled(
          widget.id,
          widget.assetDir,
          filled: filled,
          regionCount: _regionCount,
        );
  }

  var _regionCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoringView.canvasColor,
      body: FutureBuilder(
        future: _scene,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!
                    .loadingFailed('${snapshot.error}'),
              ),
            );
          }
          final scene = snapshot.data;
          if (scene != null) _regionCount = scene.picture.regions.length;
          // The picture is already on screen as a preview while the shader and
          // the textures load, so there is nothing to wait in front of.
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: scene == null
                ? _Loading(assetDir: widget.assetDir, filled: _filled)
                : ColoringView(
                    picture: scene.picture,
                    shader: scene.shader,
                    regionMap: scene.regionMap,
                    artwork: scene.artwork,
                    lines: scene.lines,
                    filled: _filled,
                    onFilledChanged: _saveFilled,
                  ),
          );
        },
      ),
    );
  }
}

/// The picture as it was left, shown while the coloring scene loads.
class _Loading extends StatelessWidget {
  const _Loading({required this.assetDir, required this.filled});

  final String assetDir;
  final Set<int> filled;

  @override
  Widget build(BuildContext context) {
    // The same layout the coloring view has, so the picture does not jump
    // when the preview gives way to it.
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: ColoredPreview(
                  assetDir: assetDir,
                  filled: filled,
                  size: ColoredPreview.thumbnailSize,
                ),
              ),
            ),
          ),
          SizedBox(height: ColorPalette.heightOf(context)),
        ],
      ),
    );
  }
}
