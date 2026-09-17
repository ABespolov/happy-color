import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

class PictureRegion {
  const PictureRegion({
    required this.colorIndex,
    required this.bounds,
    required this.labelAt,
    required this.labelRadius,
  });

  factory PictureRegion.fromJson(Map<String, dynamic> json) {
    final label = _doubles(json['label']);
    final b = _doubles(json['bounds']);
    return PictureRegion(
      colorIndex: json['color'] as int,
      bounds: Rect.fromLTRB(b[0], b[1], b[2], b[3]),
      labelAt: Offset(label[0], label[1]),
      labelRadius: label[2],
    );
  }

  final int colorIndex;
  final Rect bounds;
  final Offset labelAt;
  final double labelRadius;
}

/// A color-by-number picture whose regions are stored as a pixel map: every
/// pixel holds the index of the region it belongs to.
class ColoringPicture {
  ColoringPicture({
    required this.size,
    required this.palette,
    required this.regions,
    required this.regionMap,
    required this.mapWidth,
    required this.mapHeight,
  }) : regionsByColor = List.generate(palette.length, (_) => <int>[]) {
    for (var id = 0; id < regions.length; id++) {
      regionsByColor[regions[id].colorIndex].add(id);
    }
  }

  /// [regionMapRgba] is the decoded `regions.png`: region index + 1 in the
  /// red (low byte) and green (high byte) channels, 0 for no region.
  factory ColoringPicture.fromJson(
    String source, {
    required ByteData regionMapRgba,
    required int mapWidth,
    required int mapHeight,
  }) {
    final json = jsonDecode(source) as Map<String, dynamic>;

    final pixels = mapWidth * mapHeight;
    final bytes = regionMapRgba.buffer.asUint8List(
      regionMapRgba.offsetInBytes,
      regionMapRgba.lengthInBytes,
    );
    final regionMap = Int32List(pixels);
    for (var i = 0; i < pixels; i++) {
      regionMap[i] = bytes[i * 4] + (bytes[i * 4 + 1] << 8) - 1;
    }

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
      regionMap: regionMap,
      mapWidth: mapWidth,
      mapHeight: mapHeight,
    );
  }

  final Size size;
  final List<Color> palette;
  final List<PictureRegion> regions;
  final List<List<int>> regionsByColor;

  /// Region index per map pixel, row by row; -1 where there is no region.
  final Int32List regionMap;
  final int mapWidth;
  final int mapHeight;

  int? regionAt(Offset point) {
    final x = (point.dx / size.width * mapWidth).floor();
    final y = (point.dy / size.height * mapHeight).floor();
    if (x < 0 || y < 0 || x >= mapWidth || y >= mapHeight) return null;
    final id = regionMap[y * mapWidth + x];
    return id < 0 ? null : id;
  }
}

List<double> _doubles(Object? list) => [
  for (final v in list as List) (v as num).toDouble(),
];
