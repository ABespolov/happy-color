import 'package:flutter/material.dart';

import '../coloring_picture.dart';
import 'scene_fit.dart';

class OutlinePainter extends CustomPainter {
  OutlinePainter({
    required this.picture,
    required this.transform,
    required this.fit,
  }) : super(repaint: transform);

  final ColoringPicture picture;
  final TransformationController transform;
  final SceneFit fit;

  late final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = picture.outlineWidth
    ..strokeCap = StrokeCap.square
    ..color = const Color(0xFF424242);

  @override
  void paint(Canvas canvas, Size size) {
    final visible = visibleRect(transform, fit).inflate(picture.outlineWidth);
    for (final cell in picture.cells) {
      if (cell.bounds.overlaps(visible)) {
        canvas.drawPath(cell.outline, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(OutlinePainter oldDelegate) => true;
}
