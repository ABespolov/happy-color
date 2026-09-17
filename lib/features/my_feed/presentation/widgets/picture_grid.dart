import 'package:flutter/material.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/picture_card.dart';

/// Sliver grid of feed pictures.
class PictureGrid extends StatelessWidget {
  const PictureGrid({super.key, required this.pictures});

  final List<FeedPicture> pictures;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: pictures.length,
        itemBuilder: (context, index) => PictureCard(picture: pictures[index]),
      ),
    );
  }
}
