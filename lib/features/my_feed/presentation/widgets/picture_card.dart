import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';

class PictureCard extends StatelessWidget {
  const PictureCard({super.key, required this.picture});

  final FeedPicture picture;

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
