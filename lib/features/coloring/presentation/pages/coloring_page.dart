import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/widgets/coloring_view.dart';

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key, required this.assetDir});

  /// Folder with `picture.json` and `artwork.png`.
  final String assetDir;

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  late final _scene = _load();

  Future<(ColoringPicture, ui.Image, ui.Image?)> _load() async {
    final dir = widget.assetDir;
    final json = await rootBundle.loadString('$dir/picture.json');
    return (
      ColoringPicture.fromJson(json),
      await _image('$dir/artwork.png'),
      await _image('$dir/lines.png')
          .then<ui.Image?>((i) => i, onError: (_) => null),
    );
  }

  static Future<ui.Image> _image(String asset) async {
    final bytes = await rootBundle.load(asset);
    return decodeImageFromList(bytes.buffer.asUint8List());
  }

  @override
  void dispose() {
    _scene.then((scene) {
      scene.$2.dispose();
      scene.$3?.dispose();
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
          final (picture, artwork, lines) = snapshot.requireData;
          return ColoringView(picture: picture, artwork: artwork, lines: lines);
        },
      ),
    );
  }
}
