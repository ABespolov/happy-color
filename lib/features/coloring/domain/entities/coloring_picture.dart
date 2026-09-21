import 'dart:convert';
import 'dart:ui';

class PictureRegion {
  const PictureRegion({
    required this.colorIndex,
    required this.bounds,
    required this.labelAt,
    required this.labelRadius,
  });

  factory PictureRegion.fromJson(Map<String, dynamic> json) {
    if (json case {
      'color': final int color,
      'label': [final num x, final num y, final num radius],
      'bounds': [
        final num left,
        final num top,
        final num right,
        final num bottom,
      ],
    }) {
      return PictureRegion(
        colorIndex: color,
        bounds: Rect.fromLTRB(
          left.toDouble(),
          top.toDouble(),
          right.toDouble(),
          bottom.toDouble(),
        ),
        labelAt: Offset(x.toDouble(), y.toDouble()),
        labelRadius: radius.toDouble(),
      );
    }
    throw FormatException('bad region', json);
  }

  final int colorIndex;
  final Rect bounds;
  final Offset labelAt;
  final double labelRadius;
}

/// A color-by-number picture.
class ColoringPicture {
  ColoringPicture({
    required this.size,
    required this.palette,
    required this.regions,
  }) : regionsByColor = List.generate(palette.length, (_) => <int>[]) {
    for (var id = 0; id < regions.length; id++) {
      regionsByColor[regions[id].colorIndex].add(id);
    }
  }

  factory ColoringPicture.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return ColoringPicture(
      size: Size(
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      ),
      palette: [
        for (final hex in json['palette'] as List)
          Color(
            0xFF000000 | int.parse((hex as String).substring(1), radix: 16),
          ),
      ],
      regions: [
        for (final r in json['regions'] as List)
          PictureRegion.fromJson(r as Map<String, dynamic>),
      ],
    );
  }

  final Size size;
  final List<Color> palette;
  final List<PictureRegion> regions;
  final List<List<int>> regionsByColor;
}
