import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:happy_color/features/coloring/presentation/controllers/coloring_controller.dart';

/// The coloring shader, read from the bundle the first time it is asked for
/// and kept from then on. The coloring view and the previews share it.
final Future<ui.FragmentProgram> coloringProgram = ui.FragmentProgram.fromAsset(
  'shaders/coloring.frag',
);

/// Paints revealed artwork and the selected color's stripes with
/// `shaders/coloring.frag`, looking up every pixel's region in the region map.
class ColoringCanvasPainter extends CustomPainter {
  ColoringCanvasPainter({
    required this.controller,
    required this.shader,
    required this.regionMap,
    required this.artwork,
  }) : super(
         repaint: Listenable.merge([
           controller,
           controller.animations,
           controller.selectedColor,
           controller.stateImage,
         ]),
       );

  final ColoringController controller;
  final ui.FragmentShader shader;
  final ui.Image regionMap;
  final ui.Image artwork;

  static const _stripeWidth = 7.0;

  @override
  void paint(Canvas canvas, Size size) {
    final state = controller.stateImage.value;
    if (state == null) return;

    var i = 0;
    void set(double value) => shader.setFloat(i++, value);
    set(size.width);
    set(size.height);
    set(controller.stateWidth.toDouble());
    set(controller.stateHeight.toDouble());
    set(controller.selectedColor.value.toDouble());
    set(_stripeWidth);
    for (final fill in controller.animations.bySlot) {
      set(fill?.origin.dx ?? 0);
      set(fill?.origin.dy ?? 0);
      set(fill == null ? 0 : fill.maxRadius * fill.progress);
      set(0);
    }
    shader
      ..setImageSampler(0, regionMap)
      ..setImageSampler(1, state)
      ..setImageSampler(2, artwork, filterQuality: FilterQuality.medium);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(ColoringCanvasPainter oldDelegate) => true;
}
