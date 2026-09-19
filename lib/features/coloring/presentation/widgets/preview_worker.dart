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

  /// Handed over rather than copied: the artwork is read once, painted, and
  /// never needed on the sending side again.
  final TransferableTypedData artwork;
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
  /// painted; after that the isolate keeps its map. [artwork] is given away:
  /// it is not to be read after this call.
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
        artwork: TransferableTypedData.fromList([artwork]),
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
        case (final int id, final TransferableTypedData pixels):
          _pending.remove(id)?.complete(pixels.materialize().asUint8List());
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
        final pixels = paintPixels(request, map);
        replies.send((id, TransferableTypedData.fromList([pixels])));
      } on Object catch (error) {
        replies.send((id, error));
      }
    });
  }
}

/// Colored regions take their pixels from the artwork, the rest stays white.
Uint8List paintPixels(PaintRequest request, Uint8List regions) {
  final size = request.size;
  final artwork = request.artwork.materialize().asUint32List();
  final pixels = Uint32List(size * size);
  // The column of the region map behind every column of the preview, worked
  // out once instead of once per pixel.
  final columns = Uint32List(size);
  for (var x = 0; x < size; x++) {
    columns[x] = x * request.regionsWidth ~/ size;
  }
  final regionWords = regions.buffer.asUint16List(
    regions.offsetInBytes,
    regions.lengthInBytes ~/ 2,
  );
  // Pixels are handled a word at a time. Every platform the app runs on is
  // little-endian, so the alpha byte of an RGBA pixel is the high one.
  const opaque = 0xFF000000;
  final filled = request.filled;
  for (var y = 0; y < size; y++) {
    final row = (y * request.regionsHeight ~/ size) * request.regionsWidth;
    final out = y * size;
    for (var x = 0; x < size; x++) {
      // The region number is in the red and green bytes, low byte first.
      final region = regionWords[(row + columns[x]) * 2] - 1;
      pixels[out + x] = region >= 0 && filled.contains(region)
          ? artwork[out + x] | opaque
          : 0xFFFFFFFF;
    }
  }
  return pixels.buffer.asUint8List();
}
