import 'package:flutter/material.dart';
import 'package:happy_color/core/widgets/picture_tile.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';

class PictureCard extends StatelessWidget {
  const PictureCard({super.key, required this.picture});

  final FeedPicture picture;

  @override
  Widget build(BuildContext context) =>
      PictureTile(id: picture.id, assetDir: picture.assetDir);
}
