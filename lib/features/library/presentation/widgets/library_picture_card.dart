import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';

class LibraryPictureCard extends StatelessWidget {
  const LibraryPictureCard({super.key, required this.picture});

  final LibraryPicture picture;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.placeholder,
        ),
      ),
    );
  }
}
