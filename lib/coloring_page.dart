import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_palette.dart';
import 'coloring_controller.dart';
import 'coloring_picture.dart';
import 'painters/artwork_reveal_painter.dart';
import 'painters/highlight_painter.dart';
import 'painters/labels_painter.dart';
import 'painters/outline_painter.dart';

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

class ColoringView extends StatefulWidget {
  const ColoringView({super.key, required this.picture, required this.artwork});

  final ColoringPicture picture;
  final ui.Image artwork;

  @override
  State<ColoringView> createState() => _ColoringViewState();
}

class _ColoringViewState extends State<ColoringView>
    with SingleTickerProviderStateMixin {
  late final _controller = ColoringController(
    picture: widget.picture,
    vsync: this,
  );
  final _transform = TransformationController();
  late final _labels = LabelAtlas(widget.picture.palette.length);
  late final _artwork = artworkShader(widget.artwork, widget.picture.size);
  late final _stripes = stripeShader(widget.picture.outlineWidth);

  @override
  void dispose() {
    _controller.dispose();
    _transform.dispose();
    _labels.dispose();
    _artwork.dispose();
    _stripes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picture = widget.picture;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final viewport = constraints.biggest;
                    final scale = math.min(
                      viewport.width / picture.size.width,
                      viewport.height / picture.size.height,
                    );
                    final fit = (
                      scale: scale,
                      offset: Offset(
                        (viewport.width - picture.size.width * scale) / 2,
                        (viewport.height - picture.size.height * scale) / 2,
                      ),
                      viewport: viewport,
                    );
                    return ColoredBox(
                      color: const Color(0xFFF2F2F2),
                      child: InteractiveViewer(
                        transformationController: _transform,
                        maxScale: 12,
                        child: FittedBox(
                          child: SizedBox.fromSize(
                            size: picture.size,
                            child: GestureDetector(
                              onTapUp: (details) =>
                                  _controller.tapAt(details.localPosition),
                              child: ColoredBox(
                                color: Colors.white,
                                child: Stack(
                                  children: [
                                    _layer(
                                      HighlightPainter(_controller, _stripes),
                                    ),
                                    _layer(
                                      ArtworkRevealPainter(
                                        _controller,
                                        _artwork,
                                      ),
                                    ),
                                    _layer(
                                      OutlinePainter(
                                        picture: picture,
                                        transform: _transform,
                                        fit: fit,
                                      ),
                                    ),
                                    _layer(
                                      LabelsPainter(
                                        controller: _controller,
                                        transform: _transform,
                                        fit: fit,
                                        labels: _labels,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    tooltip: 'Open every region of the selected color',
                    onPressed: _controller.fillAllOfSelectedColor,
                    child: const Icon(Icons.format_color_fill),
                  ),
                ),
              ],
            ),
          ),
          ColorPalette(controller: _controller),
        ],
      ),
    );
  }

  Widget _layer(CustomPainter painter) => Positioned.fill(
    child: RepaintBoundary(child: CustomPaint(painter: painter)),
  );
}
