import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:happy_color/features/coloring/domain/entities/coloring_picture.dart';

class ColoringController extends ChangeNotifier {
  ColoringController({
    required this.picture,
    required TickerProvider vsync,
    Set<int> filled = const {},
    this.onFilledChanged,
  }) : _state = Uint8List(picture.regions.length),
       stateWidth = _stateWidthFor(picture.regions.length),
       stateHeight =
           (picture.regions.length / _stateWidthFor(picture.regions.length))
               .ceil() {
    animations = FillAnimations(vsync: vsync, onCompleted: _completeFills);
    _stateBytes = Uint8List(stateWidth * stateHeight * 4);
    for (var id = 0; id < picture.regions.length; id++) {
      _stateBytes[id * 4 + 2] = picture.regions[id].colorIndex;
      _stateBytes[id * 4 + 3] = 255;
    }
    for (final id in filled) {
      if (id < picture.regions.length) {
        _state[id] = _filled;
        _stateBytes[id * 4] = 255;
      }
    }
    _uploadState();
  }

  /// Called with every colored region whenever one more is filled.
  final void Function(Set<int> filled)? onFilledChanged;

  static const _empty = 0, _animating = 1, _filled = 2;

  static int _stateWidthFor(int regions) => regions.clamp(1, 1024);

  final ColoringPicture picture;
  final selectedColor = ValueNotifier<int>(0);
  late final FillAnimations animations;

  /// Per-region state for the shader, one texel per region:
  /// R = filled, G = animation slot + 1, B = color index.
  final stateImage = ValueNotifier<ui.Image?>(null);
  final int stateWidth;
  final int stateHeight;
  late final Uint8List _stateBytes;
  var _uploadVersion = 0;

  final Uint8List _state;

  bool isEmpty(int regionId) => _state[regionId] == _empty;

  Set<int> get filledRegions => {
    for (var id = 0; id < _state.length; id++)
      if (_state[id] == _filled) id,
  };

  double progress(int colorIndex) {
    final ids = picture.regionsByColor[colorIndex];
    return ids.where((id) => _state[id] == _filled).length / ids.length;
  }

  void tapAt(Offset scenePoint) {
    final id = picture.regionAt(scenePoint);
    if (id == null || _state[id] != _empty) return;
    if (picture.regions[id].colorIndex != selectedColor.value) return;

    final b = picture.regions[id].bounds;
    // Far enough to cover the whole region from any point inside it.
    final radius = Offset(b.width, b.height).distance;
    final slot = animations.start(id, scenePoint, radius);
    if (slot == null) {
      _completeFills([id]);
      return;
    }
    _state[id] = _animating;
    _stateBytes[id * 4 + 1] = slot + 1;
    _uploadState();
    notifyListeners();
  }

  void fillAllOfSelectedColor() {
    final pending = picture.regionsByColor[selectedColor.value]
        .where((id) => _state[id] == _empty)
        .toList();
    if (pending.isNotEmpty) _completeFills(pending);
  }

  void _completeFills(List<int> ids) {
    for (final id in ids) {
      _state[id] = _filled;
      _stateBytes[id * 4] = 255;
      _stateBytes[id * 4 + 1] = 0;
    }
    _uploadState();
    notifyListeners();
    onFilledChanged?.call(filledRegions);

    if (progress(selectedColor.value) >= 1) {
      for (var i = 0; i < picture.palette.length; i++) {
        if (progress(i) < 1) {
          selectedColor.value = i;
          break;
        }
      }
    }
  }

  void _uploadState() {
    final version = ++_uploadVersion;
    ui.decodeImageFromPixels(
      Uint8List.fromList(_stateBytes),
      stateWidth,
      stateHeight,
      ui.PixelFormat.rgba8888,
      (image) {
        if (version != _uploadVersion || _disposed) {
          image.dispose();
          return;
        }
        final old = stateImage.value;
        stateImage.value = image;
        old?.dispose();
        // Slots of fills that finished can be reused only once the shader
        // sees those regions as filled.
        animations.releaseFinished();
      },
    );
  }

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    stateImage.value?.dispose();
    stateImage.dispose();
    animations.dispose();
    selectedColor.dispose();
    super.dispose();
  }
}

class ActiveFill {
  ActiveFill(
    this.regionId,
    this.slot,
    this.origin,
    this.maxRadius,
    this.startedAt,
  );

  final int regionId;
  final int slot;
  final Offset origin;
  final double maxRadius;
  final Duration startedAt;
  double progress = 0;
  bool finished = false;
}

class FillAnimations extends ChangeNotifier {
  FillAnimations({required TickerProvider vsync, required this.onCompleted}) {
    _ticker = vsync.createTicker(_tick);
  }

  /// Fills the shader can animate at the same time.
  static const slots = 8;
  static const duration = Duration(milliseconds: 650);
  static const curve = Curves.easeOutCubic;

  final void Function(List<int> regionIds) onCompleted;
  late final Ticker _ticker;

  /// Fill per slot; a finished fill keeps its slot, fully grown, until the
  /// region's filled state reaches the shader.
  final bySlot = List<ActiveFill?>.filled(slots, null);
  var _elapsed = Duration.zero;

  /// Starts a fill and returns its slot, or null when all slots are busy.
  int? start(int regionId, Offset origin, double maxRadius) {
    final slot = bySlot.indexWhere((fill) => fill == null);
    if (slot < 0) return null;
    if (!_ticker.isActive) {
      _elapsed = Duration.zero;
      _ticker.start();
    }
    bySlot[slot] = ActiveFill(regionId, slot, origin, maxRadius, _elapsed);
    return slot;
  }

  void releaseFinished() {
    for (var i = 0; i < slots; i++) {
      if (bySlot[i]?.finished ?? false) bySlot[i] = null;
    }
  }

  void _tick(Duration elapsed) {
    _elapsed = elapsed;
    final completed = <int>[];
    var running = false;
    for (final fill in bySlot.nonNulls) {
      if (fill.finished) continue;
      final t =
          (elapsed - fill.startedAt).inMicroseconds / duration.inMicroseconds;
      if (t >= 1) {
        fill
          ..progress = 1
          ..finished = true;
        completed.add(fill.regionId);
      } else {
        fill.progress = curve.transform(t);
        running = true;
      }
    }

    if (completed.isNotEmpty) onCompleted(completed);
    notifyListeners();
    if (!running) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
