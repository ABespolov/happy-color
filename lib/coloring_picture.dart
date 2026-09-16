import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

class PictureRegion {
  PictureRegion({
    required this.path,
    required this.triangles,
    required this.colorIndex,
    required this.labelAt,
    required this.labelRadius,
  }) : bounds = path.getBounds();

  final Path path;

  final Float32List triangles;

  final Rect bounds;
  final int colorIndex;

  final Offset labelAt;
  final double labelRadius;
}

/// A spatial bucket of regions. Every region lives in exactly one cell, and
/// [bounds] fully covers each of them, so a cell can be skipped whenever its
/// bounds miss the point or rect of interest.
typedef SceneCell = ({Rect bounds, Path outline, List<int> regionIds});

class ColoringPicture {
  ColoringPicture({
    required this.size,
    required this.outlineWidth,
    required this.palette,
    required this.regions,
  }) : regionsByColor = List.generate(palette.length, (_) => <int>[]),
       cellOf = Int32List(regions.length) {
    final buckets = List.generate(_grid * _grid, (_) => <int>[]);
    for (var id = 0; id < regions.length; id++) {
      final region = regions[id];
      regionsByColor[region.colorIndex].add(id);
      final c = region.bounds.center;
      final column = (c.dx / size.width * _grid).floor().clamp(0, _grid - 1);
      final row = (c.dy / size.height * _grid).floor().clamp(0, _grid - 1);
      buckets[row * _grid + column].add(id);
    }
    cells = [
      for (final ids in buckets)
        if (ids.isNotEmpty)
          (
            bounds: ids
                .map((id) => regions[id].bounds)
                .reduce((a, b) => a.expandToInclude(b)),
            outline: ids.fold(
              Path(),
              (p, id) => p..addPath(regions[id].path, Offset.zero),
            ),
            regionIds: ids,
          ),
    ];
    for (var cell = 0; cell < cells.length; cell++) {
      for (final id in cells[cell].regionIds) {
        cellOf[id] = cell;
      }
    }
  }

  static const _grid = 16;

  factory ColoringPicture.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    List<double> doubles(Object? list) => [
      for (final v in list as List) (v as num).toDouble(),
    ];

    return ColoringPicture(
      size: Size(
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      ),
      outlineWidth: (json['outlineWidth'] as num).toDouble(),
      palette: [
        for (final hex in json['palette'] as List)
          Color(
            0xFF000000 | int.parse((hex as String).substring(1), radix: 16),
          ),
      ],
      regions: [
        for (final r in json['regions'] as List)
          PictureRegion(
            path: Path()..addPolygon(_points(doubles(r['points'])), true),
            triangles: Float32List.fromList(doubles(r['triangles'])),
            colorIndex: r['color'] as int,
            labelAt: Offset(r['label'][0].toDouble(), r['label'][1].toDouble()),
            labelRadius: r['label'][2].toDouble(),
          ),
      ],
    );
  }

  final Size size;
  final double outlineWidth;
  final List<Color> palette;
  final List<PictureRegion> regions;
  final List<List<int>> regionsByColor;
  late final List<SceneCell> cells;

  /// Index into [cells] for each region id.
  final Int32List cellOf;

  int? regionAt(Offset point) {
    for (final cell in cells) {
      if (!cell.bounds.contains(point)) continue;
      for (final id in cell.regionIds) {
        final region = regions[id];
        if (region.bounds.contains(point) && region.path.contains(point)) {
          return id;
        }
      }
    }
    return null;
  }
}

List<Offset> _points(List<double> xy) => [
  for (var i = 0; i < xy.length; i += 2) Offset(xy[i], xy[i + 1]),
];
