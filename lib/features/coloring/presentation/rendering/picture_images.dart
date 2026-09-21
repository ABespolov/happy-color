import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Decodes a bundled image, scaled to [size] by [size] if given.
Future<ui.Image> loadImage(String asset, {int? size}) async {
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

/// Kept at its own resolution: scaling would blend the region numbers stored
/// in its pixels into numbers of other regions.
Future<ui.Image> loadRegionMap(String assetDir) =>
    loadImage('$assetDir/regions.png');

/// An image from raw RGBA pixels.
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
