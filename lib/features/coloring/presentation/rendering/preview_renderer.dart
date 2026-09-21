import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:happy_color/features/coloring/presentation/painters/coloring_canvas_painter.dart';
import 'package:happy_color/features/coloring/presentation/rendering/picture_images.dart';

/// Side of the `_thumb` assets: up to it they are sharp enough.
const thumbnailSize = 512;

/// Renders a picture as the user left it: colored regions show the artwork,
/// the rest is white, the line art is on top. Disposes of [regionMap].
Future<ui.Image> renderPreview({
  required String assetDir,
  required int size,
  required Set<int> filled,
  required Future<ui.Image> regionMap,
}) async {
  final thumb = size <= thumbnailSize ? '_thumb' : '';
  final (program, regions, artwork, lines, state) = await (
    coloringProgram,
    regionMap,
    loadImage('$assetDir/artwork$thumb.webp', size: size),
    loadImage('$assetDir/lines$thumb.webp', size: size),
    _stateTexture(filled),
  ).wait;

  // The coloring view's shader with no color selected and no fill running.
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
  for (final texture in [regions, artwork, lines, state]) {
    texture.dispose();
  }
  return image;
}

const _stateWidth = 1024;

/// One texel per region, R set for a colored one. It ends one empty row after
/// the last colored region: the shader reads past the texture as its edge, so
/// every region beyond stays white.
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
