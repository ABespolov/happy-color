import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_worker.dart';

/// Shows a picture the way the user left it: colored regions come from the
/// artwork, the rest stays white, and the line art is drawn on top.
class ColoredPreview extends ConsumerStatefulWidget {
  const ColoredPreview({
    super.key,
    required this.assetDir,
    required this.filled,
    this.size = 1000,
  });

  final String assetDir;
  final Set<int> filled;

  /// Side of the rendered preview in pixels; a grid cell needs far less than
  /// a full screen does.
  final int size;

  /// Above this size the full pictures are used instead of the thumbnails.
  static const thumbnailSize = 512;

  /// Side of a preview on a card.
  static const cardSize = 400;

  @override
  ConsumerState<ColoredPreview> createState() => _ColoredPreviewState();
}

class _ColoredPreviewState extends ConsumerState<ColoredPreview> {
  late Future<ui.Image> _image = _fromCache();
  Timer? _pending;

  @override
  void didUpdateWidget(ColoredPreview old) {
    super.didUpdateWidget(old);
    if (old.assetDir != widget.assetDir ||
        old.size != widget.size ||
        !setEquals(old.filled, widget.filled)) {
      // A burst of taps while coloring would otherwise build a preview for
      // every one of them; the last state is the only one worth having.
      _pending?.cancel();
      _pending = Timer(
        const Duration(milliseconds: 150),
        () => setState(() => _image = _fromCache()),
      );
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    super.dispose();
  }

  /// The cache owns the image, so this widget never disposes of it.
  Future<ui.Image> _fromCache() => coloredPreview(
    ref.read(previewCacheProvider),
    assetDir: widget.assetDir,
    size: widget.size,
    filled: widget.filled,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _image,
      builder: (context, snapshot) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: snapshot.hasData
            ? RawImage(image: snapshot.data, fit: BoxFit.contain)
            : const ColoredBox(color: Colors.white),
      ),
    );
  }
}

/// The preview of a picture at [size], built only if the cache does not have
/// it yet. The cache keeps and disposes of the image.
Future<ui.Image> coloredPreview(
  PreviewCache cache, {
  required String assetDir,
  required int size,
  required Set<int> filled,
}) {
  final key = PreviewKey(assetDir: assetDir, size: size, filled: filled);
  return cache.of(key, () => _render(cache, assetDir, size, filled));
}

Future<ui.Image> _render(
  PreviewCache cache,
  String assetDir,
  int size,
  Set<int> filled,
) async {
  final small = size <= ColoredPreview.thumbnailSize;
  final (regions, artwork, lines) = await (
    cache.regionMap(assetDir, () => _loadRegionMap(assetDir)),
    _load('$assetDir/${small ? 'artwork_thumb' : 'artwork'}.webp', size),
    _load('$assetDir/${small ? 'lines_thumb' : 'lines'}.webp', size),
  ).wait;

  final artworkBytes = (await artwork.toByteData())!.buffer.asUint8List();
  // Painting every pixel is the slow part, and it holds no engine objects,
  // so it happens away from the isolate that draws the frames.
  final pixels = await cache.worker.paint(
    PaintRequest(
      regions: regions.bytes,
      regionsWidth: regions.width,
      regionsHeight: regions.height,
      artwork: artworkBytes,
      filled: filled,
      size: size,
    ),
  );
  final painted = await _decodePixels(pixels, size);

  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
    ..drawImage(painted, Offset.zero, Paint())
    ..drawImage(lines, Offset.zero, Paint());
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  picture.dispose();
  for (final source in [artwork, lines, painted]) {
    source.dispose();
  }
  return image;
}

/// The region map keeps its own resolution: scaling it would blend the region
/// numbers stored in its pixels into numbers of other regions.
Future<RegionMap> _loadRegionMap(String assetDir) async {
  final image = await _load('$assetDir/regions.png', null);
  final bytes = (await image.toByteData())!.buffer.asUint8List();
  final map = RegionMap(bytes: bytes, width: image.width, height: image.height);
  image.dispose();
  return map;
}

Future<ui.Image> _load(String asset, int? size) async {
  final data = await rootBundle.load(asset);
  final codec = await ui.instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: size,
    targetHeight: size,
  );
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

Future<ui.Image> _decodePixels(Uint8List pixels, int size) {
  final done = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    size,
    size,
    ui.PixelFormat.rgba8888,
    done.complete,
  );
  return done.future;
}
