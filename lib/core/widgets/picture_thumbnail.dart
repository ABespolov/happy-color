import 'package:flutter/widgets.dart';

/// Decodes a card picture no larger than the cell it is shown in. Every
/// place that shows a thumbnail decodes it at this width, so the image cache
/// holds one copy of each.
int pictureThumbnailWidth(BuildContext context) {
  final cell = MediaQuery.sizeOf(context).width / 2;
  return (cell * MediaQuery.devicePixelRatioOf(context)).round().clamp(
    200,
    512,
  );
}
