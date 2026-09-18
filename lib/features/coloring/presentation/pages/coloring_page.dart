import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/progress/presentation/providers/progress_providers.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
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
    final (program, json, regionMap, artwork, lines) = await (
      ui.FragmentProgram.fromAsset('shaders/coloring.frag'),
      rootBundle.loadString('$dir/picture.json'),
      _image('$dir/regions.png'),
      _image('$dir/artwork.webp'),
      _image('$dir/lines.webp'),
    ).wait;
    final rgba = await regionMap.toByteData();
    return (
      picture: ColoringPicture.fromJson(
        json,
        regionMapRgba: rgba!,
        mapWidth: regionMap.width,
        mapHeight: regionMap.height,
      ),
      shader: program.fragmentShader(),
      regionMap: regionMap,
      artwork: artwork,
      lines: lines,
    );
  }

  static Future<ui.Image> _image(String asset) async {
    final bytes = await rootBundle.load(asset);
    return decodeImageFromList(bytes.buffer.asUint8List());
  }

  @override
  void dispose() {
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

  void _saveFilled(Set<int> filled) => ref
      .read(progressProvider.notifier)
      .setFilled(
        widget.id,
        widget.assetDir,
        filled: filled,
        regionCount: _regionCount,
      );

  var _regionCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final scene = snapshot.requireData;
          _regionCount = scene.picture.regions.length;
          return ColoringView(
            picture: scene.picture,
            shader: scene.shader,
            regionMap: scene.regionMap,
            artwork: scene.artwork,
            lines: scene.lines,
            filled: _filled,
            onFilledChanged: _saveFilled,
          );
        },
      ),
    );
  }
}
