import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:happy_color/features/coloring/presentation/controllers/coloring_controller.dart';

class ArtworkRevealPainter extends CustomPainter {
  ArtworkRevealPainter(this.controller, ui.ImageShader artwork)
    : _paint = Paint()
        ..filterQuality = FilterQuality.medium
        ..shader = artwork,
      super(repaint: Listenable.merge([controller, controller.animations]));

  final ColoringController controller;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    final picture = controller.picture;
    for (final filled in controller.filledByCell.nonNulls) {
      canvas.drawVertices(filled, BlendMode.srcOver, _paint);
    }
    for (final fill in controller.animations.active) {
      canvas
        ..save()
        ..clipPath(picture.regions[fill.regionId].path, doAntiAlias: false)
        ..drawCircle(fill.origin, fill.maxRadius * fill.progress, _paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(ArtworkRevealPainter oldDelegate) => true;
}

ui.ImageShader artworkShader(ui.Image image, Size pictureSize) =>
    ui.ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.diagonal3Values(
        pictureSize.width / image.width,
        pictureSize.height / image.height,
        1,
      ).storage,
    );
