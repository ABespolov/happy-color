import 'package:flutter/material.dart';

typedef SceneFit = ({double scale, Offset offset, Size viewport});

Rect visibleRect(TransformationController transform, SceneFit fit) {
  final r = MatrixUtils.inverseTransformRect(
    transform.value,
    Offset.zero & fit.viewport,
  );
  return Rect.fromPoints(
    (r.topLeft - fit.offset) / fit.scale,
    (r.bottomRight - fit.offset) / fit.scale,
  );
}
