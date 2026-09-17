import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/widgets/coloring_view.dart';

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  late final _scene = _load();

  static Future<(ColoringPicture, ui.Image)> _load() async {
    final json = await rootBundle.loadString('assets/picture.json');
    final png = await rootBundle.load('assets/artwork.png');
    final artwork = await decodeImageFromList(png.buffer.asUint8List());
    return (ColoringPicture.fromJson(json), artwork);
  }

  @override
  void dispose() {
    _scene.then((scene) => scene.$2.dispose());
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
          final (picture, artwork) = snapshot.requireData;
          return ColoringView(picture: picture, artwork: artwork);
        },
      ),
    );
  }
}
