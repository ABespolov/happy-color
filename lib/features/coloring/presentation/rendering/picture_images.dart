import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Decodes a bundled image, scaled to [size] by [size] if given. The engine
/// reads the file itself, so its bytes never pass through the UI thread.
Future<ui.Image> loadImage(String asset, {int? size}) async {
  final buffer = await ui.ImmutableBuffer.fromAsset(asset);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  buffer.dispose();
  final codec = await descriptor.instantiateCodec(
    targetWidth: size,
    targetHeight: size,
  );
  final frame = await codec.getNextFrame();
  codec.dispose();
  descriptor.dispose();
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
