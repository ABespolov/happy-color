import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../coloring_controller.dart';
import 'scene_fit.dart';

const _fontPx = 16.0;

class LabelsPainter extends CustomPainter {
  LabelsPainter({
    required this.controller,
    required this.transform,
    required this.fit,
    required this.labels,
  }) : super(
         repaint: Listenable.merge([
           transform,
           controller,
           controller.selectedColor,
         ]),
       );

  final ColoringController controller;
  final TransformationController transform;

  final SceneFit fit;
  final LabelAtlas labels;

  final _paint = Paint()..filterQuality = FilterQuality.medium;

  @override
  void paint(Canvas canvas, Size size) {
    final pixelsPerUnit = fit.scale * transform.value.getMaxScaleOnAxis();
    final visible = visibleRect(transform, fit);
    final picture = controller.picture;
    final selected = controller.selectedColor.value;

    final transforms = <double>[];
    final rects = <double>[];
    for (final cell in picture.cells) {
      if (!cell.bounds.overlaps(visible)) continue;
      for (final id in cell.regionIds) {
        final region = picture.regions[id];
        if (region.labelRadius * pixelsPerUnit < _fontPx ||
            !visible.contains(region.labelAt) ||
            !controller.isEmpty(id)) {
          continue;
        }

        final sprite = labels.spriteOf(
          region.colorIndex,
          selected: region.colorIndex == selected,
        );
        final scale = _fontPx / pixelsPerUnit / LabelAtlas.fontSize;
        transforms
          ..add(scale)
          ..add(0)
          ..add(region.labelAt.dx - scale * sprite.width / 2)
          ..add(region.labelAt.dy - scale * sprite.height / 2);
        rects
          ..add(sprite.left)
          ..add(sprite.top)
          ..add(sprite.right)
          ..add(sprite.bottom);
      }
    }
    if (rects.isEmpty) return;

    canvas.drawRawAtlas(
      labels.image,
      Float32List.fromList(transforms),
      Float32List.fromList(rects),
      null,
      null,
      null,
      _paint,
    );
  }

  @override
  bool shouldRepaint(LabelsPainter oldDelegate) => true;
}

class LabelAtlas {
  LabelAtlas(this._colors) {
    final colors = _colors;
    final painters = [
      for (var selected = 0; selected < 2; selected++)
        for (var i = 0; i < colors; i++) _layout(i, selected: selected == 1),
    ];
    final cellWidth = painters
        .map((p) => p.width)
        .reduce((a, b) => a > b ? a : b)
        .ceil();
    final cellHeight = painters
        .map((p) => p.height)
        .reduce((a, b) => a > b ? a : b)
        .ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    _sprites = List.generate(painters.length, (k) {
      final p = painters[k];
      final column = k % colors, row = k ~/ colors;
      final rect = Rect.fromLTWH(
        (column * cellWidth).toDouble(),
        (row * cellHeight).toDouble(),
        p.width.ceilToDouble(),
        p.height.ceilToDouble(),
      );
      p.paint(canvas, rect.topLeft);
      p.dispose();
      return rect;
    });
    image = recorder.endRecording().toImageSync(
      cellWidth * colors,
      cellHeight * 2,
    );
  }

  static const fontSize = 64.0;

  final int _colors;
  late final ui.Image image;
  late final List<Rect> _sprites;

  Rect spriteOf(int i, {required bool selected}) =>
      _sprites[selected ? _colors + i : i];

  static TextPainter _layout(int colorIndex, {required bool selected}) =>
      TextPainter(
        text: TextSpan(
          text: '${colorIndex + 1}',
          style: TextStyle(
            fontSize: fontSize,
            color: selected ? const Color(0xFF212121) : const Color(0xFF9E9E9E),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  void dispose() => image.dispose();
}
