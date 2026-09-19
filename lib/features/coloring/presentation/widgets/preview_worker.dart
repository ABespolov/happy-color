import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

/// One request to paint a preview: every pixel of a [size] by [size] image
/// takes its color from [artwork] where its region is colored, white where it
/// is not.
class PaintRequest {
  const PaintRequest({
    required this.assetDir,
    required this.regions,
    required this.regionsWidth,
    required this.regionsHeight,
    required this.artwork,
    required this.filled,
    required this.size,
  });

  /// The picture the region map belongs to.
  final String assetDir;

  /// The region map, sent only the first time this picture is painted: it is
  /// megabytes long, and sending it copies it.
  final Uint8List? regions;

  final int regionsWidth;
  final int regionsHeight;
  final Uint8List artwork;
  final Set<int> filled;
  final int size;
}

/// A single isolate that paints every preview, one after another.
///
/// Spawning an isolate per preview would cost more than the painting itself
/// once a grid of started pictures scrolls into view.
class PreviewWorker {
  Future<SendPort>? _worker;
  final _pending = <int, Completer<Uint8List>>{};

  /// Pictures whose region map the isolate already has.
  final _sentRegions = <String>{};
  var _nextId = 0;

  /// Paints a preview. [regions] is only read the first time a picture is
  /// painted; after that the isolate keeps its map.
  Future<Uint8List> paint({
    required String assetDir,
    required Uint8List regions,
    required int regionsWidth,
    required int regionsHeight,
    required Uint8List artwork,
    required Set<int> filled,
    required int size,
  }) async {
    final worker = await (_worker ??= _spawn());
    final id = _nextId++;
    final done = _pending[id] = Completer<Uint8List>();
    worker.send((
      id,
      PaintRequest(
        assetDir: assetDir,
        regions: _sentRegions.add(assetDir) ? regions : null,
        regionsWidth: regionsWidth,
        regionsHeight: regionsHeight,
        artwork: artwork,
        filled: filled,
        size: size,
      ),
    ));
    return done.future;
  }

  Future<SendPort> _spawn() async {
    final replies = ReceivePort();
    final ready = Completer<SendPort>();
    replies.listen((message) {
      switch (message) {
        case SendPort port:
          ready.complete(port);
        case (final int id, final Uint8List pixels):
          _pending.remove(id)?.complete(pixels);
        case (final int id, final Object error):
          _pending.remove(id)?.completeError(error);
      }
    });
    await Isolate.spawn(_run, replies.sendPort);
    return ready.future;
  }

  /// Stops the isolate; the next request starts a new one.
  void dispose() {
    _worker?.then((worker) => worker.send(null));
    _worker = null;
    _sentRegions.clear();
    for (final pending in _pending.values) {
      pending.completeError(StateError('preview worker stopped'));
    }
    _pending.clear();
  }

  static void _run(SendPort replies) {
    final requests = ReceivePort();
    final regions = <String, Uint8List>{};
    replies.send(requests.sendPort);
    requests.listen((message) {
      if (message == null) {
        requests.close();
        return;
      }
      final (id, request) = message as (int, PaintRequest);
      try {
        final map = request.regions ?? regions[request.assetDir];
        if (map == null) {
          throw StateError('no region map for ${request.assetDir}');
        }
        regions[request.assetDir] = map;
        replies.send((id, paintPixels(request, map)));
      } on Object catch (error) {
        replies.send((id, error));
      }
    });
  }
}

/// Colored regions take their pixels from the artwork, the rest stays white.
Uint8List paintPixels(PaintRequest request, Uint8List regions) {
  final size = request.size;
  final pixels = Uint8List(size * size * 4);
  for (var y = 0; y < size; y++) {
    final row = (y * request.regionsHeight ~/ size) * request.regionsWidth;
    for (var x = 0; x < size; x++) {
      final source = (row + x * request.regionsWidth ~/ size) * 4;
      final region = regions[source] + (regions[source + 1] << 8) - 1;
      final colored = region >= 0 && request.filled.contains(region);
      final i = (y * size + x) * 4;
      for (var channel = 0; channel < 3; channel++) {
        pixels[i + channel] = colored ? request.artwork[i + channel] : 255;
      }
      pixels[i + 3] = 255;
    }
  }
  return pixels;
}
