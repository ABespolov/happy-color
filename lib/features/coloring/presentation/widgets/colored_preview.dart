import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a picture the way the user left it: colored regions come from the
/// artwork, the rest stays white, and the line art is drawn on top.
class ColoredPreview extends StatefulWidget {
  const ColoredPreview({
    super.key,
    required this.assetDir,
    required this.filled,
  });

  final String assetDir;
  final Set<int> filled;

  /// Side of the rendered preview in pixels.
  static const _size = 1000;

  @override
  State<ColoredPreview> createState() => _ColoredPreviewState();
}

class _ColoredPreviewState extends State<ColoredPreview> {
  late final Future<ui.Image> _image = _render();

  Future<ui.Image> _render() async {
    const size = ColoredPreview._size;
    final (regions, artwork, lines) = await (
      _load('${widget.assetDir}/regions.png', size),
      _load('${widget.assetDir}/artwork.webp', size),
      _load('${widget.assetDir}/lines.webp', size),
    ).wait;

    final regionBytes = (await regions.toByteData())!.buffer.asUint8List();
    final artworkBytes = (await artwork.toByteData())!.buffer.asUint8List();
    final pixels = Uint8List(size * size * 4);
    for (var i = 0; i < size * size; i++) {
      final region = regionBytes[i * 4] + (regionBytes[i * 4 + 1] << 8) - 1;
      final colored = region >= 0 && widget.filled.contains(region);
      for (var channel = 0; channel < 3; channel++) {
        pixels[i * 4 + channel] = colored ? artworkBytes[i * 4 + channel] : 255;
      }
      pixels[i * 4 + 3] = 255;
    }
    final painted = await _decodePixels(pixels, size);

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..drawImage(painted, Offset.zero, Paint())
      ..drawImage(lines, Offset.zero, Paint());
    final image = await recorder.endRecording().toImage(size, size);
    for (final source in [regions, artwork, lines, painted]) {
      source.dispose();
    }
    return image;
  }

  static Future<ui.Image> _load(String asset, int size) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: size,
      targetHeight: size,
    );
    return (await codec.getNextFrame()).image;
  }

  static Future<ui.Image> _decodePixels(Uint8List pixels, int size) {
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

  @override
  void dispose() {
    _image.then((image) => image.dispose());
    super.dispose();
  }

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
