import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/parts/svg_layer.dart';

/// A right-hand page turning over the spine onto the left side.
class FlippingPage extends StatelessWidget {
  const FlippingPage({super.key, required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    if (t == 0 || t == 1) return const SizedBox.shrink();
    final shade = 1 - math.sin(t * math.pi) * 0.18;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.006)
        ..rotateY(-math.pi * t),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix([
          shade, 0, 0, 0, 0, //
          0, shade, 0, 0, 0, //
          0, 0, shade, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
        child: const SvgLayer('library/page'),
      ),
    );
  }
}
