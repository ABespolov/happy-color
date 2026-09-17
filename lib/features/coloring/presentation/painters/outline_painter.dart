import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';
import 'package:happy_color/features/coloring/presentation/painters/scene_fit.dart';

class OutlinePainter extends CustomPainter {
  OutlinePainter({
    required this.picture,
    required this.transform,
    required this.fit,
  }) : super(repaint: transform);

  final ColoringPicture picture;
  final TransformationController transform;
  final SceneFit fit;

  /// Thinnest outline on screen, in logical pixels, so zoomed-out lines stay
  /// crisp and black instead of fading into sub-pixel gray.
  static const _minScreenWidth = 1.0;

  final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size) {
    final pixelsPerUnit = fit.scale * transform.value.getMaxScaleOnAxis();
    _paint.strokeWidth = math.max(
      picture.outlineWidth,
      _minScreenWidth / pixelsPerUnit,
    );
    final visible = visibleRect(transform, fit).inflate(_paint.strokeWidth);
    for (final cell in picture.cells) {
      if (cell.bounds.overlaps(visible)) {
        canvas.drawPath(cell.outline, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(OutlinePainter oldDelegate) => true;
}
