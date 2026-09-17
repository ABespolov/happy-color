import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/svg_layer.dart';

class HoppingDot extends StatelessWidget {
  const HoppingDot({super.key, required this.layer, required this.t});

  final String layer;
  final double t;

  @override
  Widget build(BuildContext context) {
    final hop = math.sin(t * math.pi);
    final squash = t > 0.8 ? math.sin((t - 0.8) / 0.2 * math.pi) * 0.08 : 0.0;
    return Transform.translate(
      offset: Offset(0, -hop * 14),
      child: Transform(
        alignment: const Alignment(0, 0.3),
        transform: Matrix4.diagonal3Values(1 + squash, 1 - squash, 1),
        child: SvgLayer(layer),
      ),
    );
  }
}
