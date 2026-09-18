import 'package:flutter/material.dart';
import 'package:happy_color/core/widgets/picture_tile.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';

class LibraryPictureCard extends StatelessWidget {
  const LibraryPictureCard({super.key, required this.picture});

  final LibraryPicture picture;

  @override
  Widget build(BuildContext context) =>
      PictureTile(id: picture.id, assetDir: picture.assetDir);
}
