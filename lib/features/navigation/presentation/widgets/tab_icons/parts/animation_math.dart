import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Maps [t] into the [begin]–[end] sub-range and applies [curve].
double interval(
  double t,
  double begin,
  double end, [
  Curve curve = Curves.linear,
]) => curve.transform(((t - begin) / (end - begin)).clamp(0.0, 1.0));

/// Converts a point on the 96×96 icon canvas into an [Alignment].
Alignment canvasAlignment(Offset point) =>
    Alignment(point.dx / 48 - 1, point.dy / 48 - 1);
