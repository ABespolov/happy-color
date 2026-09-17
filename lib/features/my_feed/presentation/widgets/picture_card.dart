import 'package:flutter/material.dart';
import 'package:happy_color/features/coloring/presentation/pages/coloring_page.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_picture.dart';

class PictureCard extends StatelessWidget {
  const PictureCard({super.key, required this.picture});

  final FeedPicture picture;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ColoringPage(assetDir: picture.assetDir),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('${picture.assetDir}/lines.png'),
        ),
      ),
    );
  }
}
