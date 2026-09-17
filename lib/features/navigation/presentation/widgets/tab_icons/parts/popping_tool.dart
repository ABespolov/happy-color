import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/animation_math.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/svg_layer.dart';

/// Pops a pencil or brush out of the cup and lets it wobble back in.
class PoppingTool extends StatelessWidget {
  const PoppingTool({
    super.key,
    required this.layer,
    required this.t,
    required this.start,
    required this.pivot,
    required this.tilt,
  });

  final String layer;
  final double t;
  final double start;
  final Offset pivot;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final local = interval(t, start, start + 0.55, Curves.easeInOut);
    final lift = math.sin(local * math.pi) * 12;
    final wobble = math.sin(local * math.pi * 2) * (1 - local) * 0.12 * tilt;
    return Transform.translate(
      offset: Offset(0, -lift),
      child: Transform.rotate(
        angle: wobble,
        alignment: canvasAlignment(pivot),
        child: SvgLayer(layer),
      ),
    );
  }
}
