import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';

class ColoringController extends ChangeNotifier {
  ColoringController({required this.picture, required TickerProvider vsync})
    : _state = Uint8List(picture.regions.length) {
    animations = FillAnimations(vsync: vsync, onCompleted: _completeFills);
  }

  static const _empty = 0, _animating = 1, _filled = 2;

  final ColoringPicture picture;
  final selectedColor = ValueNotifier<int>(0);
  late final FillAnimations animations;

  final Uint8List _state;

  /// Filled triangles per [ColoringPicture.cells] entry, so a fill only
  /// rebuilds the cell it touched.
  late final filledByCell = List<Vertices?>.filled(picture.cells.length, null);
  late final _highlightByColor = List<Vertices?>.filled(
    picture.palette.length,
    null,
  );

  bool isEmpty(int regionId) => _state[regionId] == _empty;

  double progress(int colorIndex) {
    final ids = picture.regionsByColor[colorIndex];
    return ids.where((id) => _state[id] == _filled).length / ids.length;
  }

  Vertices highlightVertices(int colorIndex) =>
      _highlightByColor[colorIndex] ??= _vertices(
        picture.regionsByColor[colorIndex],
      );

  Vertices _vertices(Iterable<int> ids) => Vertices.raw(
    VertexMode.triangles,
    Float32List.fromList([
      for (final id in ids) ...picture.regions[id].triangles,
    ]),
  );

  void tapAt(Offset scenePoint) {
    final id = picture.regionAt(scenePoint);
    if (id == null || _state[id] != _empty) return;
    if (picture.regions[id].colorIndex != selectedColor.value) return;
    _state[id] = _animating;
    final b = picture.regions[id].bounds;
    animations.start(id, scenePoint, Offset(b.width, b.height).distance);
    notifyListeners();
  }

  void fillAllOfSelectedColor() {
    final pending = picture.regionsByColor[selectedColor.value]
        .where((id) => _state[id] == _empty)
        .toList();
    if (pending.isNotEmpty) _completeFills(pending);
  }

  void _completeFills(List<int> ids) {
    final touched = <int>{};
    for (final id in ids) {
      _state[id] = _filled;
      touched.add(picture.cellOf[id]);
    }
    for (final cell in touched) {
      filledByCell[cell]?.dispose();
      filledByCell[cell] = _vertices(
        picture.cells[cell].regionIds.where((id) => _state[id] == _filled),
      );
    }
    notifyListeners();

    if (progress(selectedColor.value) >= 1) {
      for (var i = 0; i < picture.palette.length; i++) {
        if (progress(i) < 1) {
          selectedColor.value = i;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final filled in filledByCell) {
      filled?.dispose();
    }
    for (final highlight in _highlightByColor) {
      highlight?.dispose();
    }
    animations.dispose();
    selectedColor.dispose();
    super.dispose();
  }
}

class ActiveFill {
  ActiveFill(this.regionId, this.origin, this.maxRadius, this.startedAt);

  final int regionId;
  final Offset origin;
  final double maxRadius;
  final Duration startedAt;
  double progress = 0;
}

class FillAnimations extends ChangeNotifier {
  FillAnimations({required TickerProvider vsync, required this.onCompleted}) {
    _ticker = vsync.createTicker(_tick);
  }

  static const duration = Duration(milliseconds: 650);
  static const curve = Curves.easeOutCubic;

  final void Function(List<int> regionIds) onCompleted;
  late final Ticker _ticker;
  final active = <ActiveFill>[];
  var _elapsed = Duration.zero;

  void start(int regionId, Offset origin, double maxRadius) {
    if (!_ticker.isActive) {
      _elapsed = Duration.zero;
      _ticker.start();
    }
    active.add(ActiveFill(regionId, origin, maxRadius, _elapsed));
  }

  void _tick(Duration elapsed) {
    _elapsed = elapsed;
    final completed = <int>[];
    active.removeWhere((fill) {
      final t =
          (elapsed - fill.startedAt).inMicroseconds / duration.inMicroseconds;
      if (t >= 1) {
        completed.add(fill.regionId);
        return true;
      }
      fill.progress = curve.transform(t);
      return false;
    });

    if (completed.isNotEmpty) onCompleted(completed);
    notifyListeners();
    if (active.isEmpty) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
