import 'package:flutter/widgets.dart';

/// The same everywhere, so the image cache holds one copy of each thumbnail.
int pictureThumbnailWidth(BuildContext context) {
  final cell = MediaQuery.sizeOf(context).width / 2;
  return (cell * MediaQuery.devicePixelRatioOf(context)).round().clamp(
    200,
    512,
  );
}
