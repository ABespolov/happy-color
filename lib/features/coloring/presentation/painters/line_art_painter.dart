import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class LineArtPainter extends CustomPainter {
  LineArtPainter(this.lines);

  final ui.Image lines;

  final _paint = Paint()..filterQuality = FilterQuality.medium;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      lines,
      Offset.zero & Size(lines.width.toDouble(), lines.height.toDouble()),
      Offset.zero & size,
      _paint,
    );
  }

  @override
  bool shouldRepaint(LineArtPainter oldDelegate) => lines != oldDelegate.lines;
}
