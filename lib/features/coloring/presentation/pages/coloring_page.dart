import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/widgets/coloring_view.dart';

typedef _Scene = ({
  ColoringPicture picture,
  ui.FragmentShader shader,
  ui.Image regionMap,
  ui.Image artwork,
  ui.Image lines,
});

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key, required this.assetDir});

  /// Folder with the files written by `tools/generate_picture.py`.
  final String assetDir;

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  late final _scene = _load();

  Future<_Scene> _load() async {
    final dir = widget.assetDir;
    final (program, json, regionMap, artwork, lines) = await (
      ui.FragmentProgram.fromAsset('shaders/coloring.frag'),
      rootBundle.loadString('$dir/picture.json'),
      _image('$dir/regions.png'),
      _image('$dir/artwork.png'),
      _image('$dir/lines.png'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _scene,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final scene = snapshot.requireData;
          return ColoringView(
            picture: scene.picture,
            shader: scene.shader,
            regionMap: scene.regionMap,
            artwork: scene.artwork,
            lines: scene.lines,
          );
        },
      ),
    );
  }
}
