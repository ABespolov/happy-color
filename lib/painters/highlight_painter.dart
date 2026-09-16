import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../coloring_controller.dart';

class HighlightPainter extends CustomPainter {
  HighlightPainter(this.controller, ui.ImageShader stripes)
    : _paint = Paint()
        ..filterQuality = FilterQuality.low
        ..shader = stripes,
      super(repaint: controller.selectedColor);

  final ColoringController controller;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawVertices(
      controller.highlightVertices(controller.selectedColor.value),
      BlendMode.srcOver,
      _paint,
    );
  }

  @override
  bool shouldRepaint(HighlightPainter oldDelegate) => true;
}

ui.ImageShader stripeShader(double outlineWidth) {
  const tilePx = 64;
  final stripe = outlineWidth * 5;
  final tile = stripe * 2;
  final gradient = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      Offset(stripe, stripe),
      const [
        Color(0x33000000),
        Color(0x33000000),
        Color(0x14000000),
        Color(0x14000000),
      ],
      const [0, 0.5, 0.5, 1],
      TileMode.repeated,
    );
  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..scale(tilePx / tile)
    ..drawRect(Rect.fromLTWH(0, 0, tile, tile), gradient);
  final image = recorder.endRecording().toImageSync(tilePx, tilePx);
  final shader = ui.ImageShader(
    image,
    TileMode.repeated,
    TileMode.repeated,
    Matrix4.diagonal3Values(tile / tilePx, tile / tilePx, 1).storage,
  );
  image.dispose();
  return shader;
}
