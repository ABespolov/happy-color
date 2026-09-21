import 'dart:typed_data';
import 'dart:ui';

/// The decoded `regions.png`: region index + 1 in the red (low byte) and
/// green (high byte) channels of every pixel, 0 for no region.
class RegionMap {
  RegionMap(ByteData rgba, {required this.width, required this.height})
    : _rgba = rgba.buffer.asUint8List(rgba.offsetInBytes, rgba.lengthInBytes);

  final Uint8List _rgba;
  final int width;
  final int height;

  /// The region at [point], given as a share of the picture's width and
  /// height.
  int? regionAt(Offset point) {
    final x = (point.dx * width).floor();
    final y = (point.dy * height).floor();
    if (x < 0 || y < 0 || x >= width || y >= height) return null;
    final i = (y * width + x) * 4;
    final id = _rgba[i] + (_rgba[i + 1] << 8) - 1;
    return id < 0 ? null : id;
  }
}
