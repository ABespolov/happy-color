import 'package:flutter/material.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/picture_card.dart';

class PictureGrid extends StatelessWidget {
  const PictureGrid({super.key, required this.pictures});

  final List<FeedPicture> pictures;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Leave room for the floating tab bar.
      padding: EdgeInsets.only(
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: pictures.length,
      itemBuilder: (context, index) => PictureCard(picture: pictures[index]),
    );
  }
}
