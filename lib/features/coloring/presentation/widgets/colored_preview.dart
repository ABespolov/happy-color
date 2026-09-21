import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/fade_in_frame.dart';
import 'package:happy_color/core/widgets/picture_thumbnail.dart';
import 'package:happy_color/features/coloring/presentation/painters/coloring_canvas_painter.dart';
import 'package:happy_color/features/coloring/presentation/widgets/preview_cache.dart';

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
  /// Kept in a field: `ref` cannot be read while the widget is disposed of.
  late final PreviewCache _cache = ref.read(previewCacheProvider);

  /// The preview to paint right now: the one the cache already has, the one
  /// of the same picture at another size, or the one shown until a newer
  /// one finishes. Without it a card would go blank for a moment every time
  /// what is colored changes.
  ui.Image? _ready;

  Timer? _pending;

  /// The preview this card paints, held so the cache keeps it alive, and the
  /// newer one being rendered, held so it is not dropped before it is shown.
  PreviewKey? _painted;
  PreviewKey? _rendering;

  /// True while the preview on screen is not the one for [widget.filled]
  /// and the card is out of sight: under the coloring page or in another
  /// tab, where its tickers are off. Rendering waits until it shows again,
  /// instead of running once per tap for a card nobody sees.
  var _stale = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stale && TickerMode.valuesOf(context).enabled) {
      _stale = false;
      _request();
    }
  }

  @override
  void didUpdateWidget(ColoredPreview old) {
    super.didUpdateWidget(old);
    if (old.assetDir != widget.assetDir ||
        old.size != widget.size ||
        !setEquals(old.filled, widget.filled)) {
      _pending?.cancel();
      if (!TickerMode.valuesOf(context).enabled) {
        _stale = true;
        return;
      }
      // A burst of taps while coloring would otherwise build a preview for
      // every one of them; the last state is the only one worth having.
      _pending = Timer(
        const Duration(milliseconds: 150),
        () => setState(_request),
      );
    }
  }

  @override
  void dispose() {
    _pending?.cancel();
    _release(_painted);
    if (_rendering != _painted) _release(_rendering);
    super.dispose();
  }

  void _release(PreviewKey? key) {
    if (key == null) return;
    _cache.release(key);
  }

  /// Asks the cache for the preview; whatever is on screen stays up until
  /// the new one is there.
  void _request() {
    final image = _fromCache();
    unawaited(_show(image, _rendering));
  }

  /// Puts [image] up once it is rendered. One that failed leaves the card
  /// on what it shows.
  Future<void> _show(Future<ui.Image> image, PreviewKey? rendering) async {
    final ui.Image rendered;
    try {
      rendered = await image;
    } on Object {
      return;
    }
    if (!mounted) return;
    setState(() => _ready = rendered);
    // The older preview is only let go once the newer one shows.
    if (_painted != rendering) {
      _release(_painted);
      _painted = rendering;
    }
  }

  /// The cache owns the image, so this widget never disposes of it.
  Future<ui.Image> _fromCache() {
    final cache = _cache;
    final key = PreviewKey(
      assetDir: widget.assetDir,
      size: widget.size,
      filled: widget.filled,
    );
    cache.retain(key);
    if (_rendering != _painted) _release(_rendering);
    _rendering = key;
    final ready = cache.ready(key);
    if (ready != null) {
      _ready = ready;
      _release(_painted);
      _painted = key;
    } else if (_ready == null) {
      // A sheet or a page opens on the card's preview, scaled up, rather
      // than on a blank square.
      final other = cache.readyAtOtherSize(key);
      if (other != null) {
        cache.retain(other);
        _painted = other;
        _ready = cache.ready(other);
      }
    }
    return coloredPreview(
      cache,
      assetDir: widget.assetDir,
      size: widget.size,
      filled: widget.filled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _ready;
    // A preview that is there from the start is drawn as it is; one that
    // arrives later, or replaces a coarser one, is faded in over the line
    // art. The line art is what the cards show for untouched pictures and
    // sits in the image cache at the same width, so it is there at once and
    // the colors come in over it rather than the whole picture popping
    // into an empty square.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      child: ready == null
          ? Image.asset(
              '${widget.assetDir}/lines_thumb.webp',
              key: const ValueKey('lines'),
              cacheWidth: pictureThumbnailWidth(context),
              fit: BoxFit.contain,
              gaplessPlayback: true,
              // Not cached yet for a picture that was started: its card
              // never showed the plain line art.
              frameBuilder: fadeInFrame,
            )
          : RawImage(key: ObjectKey(ready), image: ready, fit: BoxFit.contain),
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
  final (program, regions, artwork, lines, state) = await (
    coloringProgram,
    cache.regionTexture(assetDir),
    _load('$assetDir/${small ? 'artwork_thumb' : 'artwork'}.webp', size),
    _load('$assetDir/${small ? 'lines_thumb' : 'lines'}.webp', size),
    _stateTexture(filled),
  ).wait;

  // The shader the coloring view draws with, with nothing selected and no
  // fill running: colored regions show the artwork, the rest stays clear.
  final shader = program.fragmentShader();
  var i = 0;
  void set(double value) => shader.setFloat(i++, value);
  set(size.toDouble());
  set(size.toDouble());
  set(state.width.toDouble());
  set(state.height.toDouble());
  set(-1); // Selected color.
  set(1); // Stripe width.
  for (var slot = 0; slot < 8 * 4; slot++) {
    set(0);
  }
  shader
    ..setImageSampler(0, regions)
    ..setImageSampler(1, state)
    ..setImageSampler(2, artwork, filterQuality: FilterQuality.medium);

  final bounds = Offset.zero & Size.square(size.toDouble());
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
    ..drawRect(bounds, Paint()..color = const Color(0xFFFFFFFF))
    ..drawRect(bounds, Paint()..shader = shader)
    ..drawImage(lines, Offset.zero, Paint());
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  picture.dispose();
  shader.dispose();
  regions.dispose();
  artwork.dispose();
  lines.dispose();
  state.dispose();
  return image;
}

/// Regions per row of the state texture.
const _stateWidth = 1024;

/// The state texture the shader reads, one texel per region: R is set for a
/// colored one. It only reaches the last colored region, plus a row left
/// empty: the shader reads past the texture as its edge, so every region
/// beyond lands on that row and stays white.
Future<ui.Image> _stateTexture(Set<int> filled) {
  final last = filled.fold(0, (last, id) => id > last ? id : last);
  final height = last ~/ _stateWidth + 2;
  final bytes = Uint8List(_stateWidth * height * 4);
  for (var i = 3; i < bytes.length; i += 4) {
    bytes[i] = 255;
  }
  for (final id in filled) {
    bytes[id * 4] = 255;
  }
  return decodePixels(bytes, _stateWidth, height);
}

/// The region map keeps its own resolution: scaling it would blend the region
/// numbers stored in its pixels into numbers of other regions.
Future<ui.Image> loadRegionMap(String assetDir) =>
    _load('$assetDir/regions.png', null);

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

/// An image from raw RGBA pixels: an upload rather than a decode.
Future<ui.Image> decodePixels(Uint8List pixels, int width, int height) {
  final done = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    done.complete,
  );
  return done.future;
}
