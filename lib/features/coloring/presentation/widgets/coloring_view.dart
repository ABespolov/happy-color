import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:happy_color/features/coloring/presentation/widgets/color_palette.dart';
import 'package:happy_color/features/coloring/presentation/controllers/coloring_controller.dart';
import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/painters/coloring_canvas_painter.dart';
import 'package:happy_color/features/coloring/presentation/painters/labels_painter.dart';
import 'package:happy_color/features/coloring/presentation/painters/line_art_painter.dart';

class ColoringView extends StatefulWidget {
  const ColoringView({
    super.key,
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

  @override
  void dispose() {
    _controller.dispose();
    _transform.dispose();
    _labels.dispose();
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
                                      ColoringCanvasPainter(
                                        controller: _controller,
                                        shader: widget.shader,
                                        regionMap: widget.regionMap,
                                        artwork: widget.artwork,
                                      ),
                                    ),
                                    _layer(LineArtPainter(widget.lines)),
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
