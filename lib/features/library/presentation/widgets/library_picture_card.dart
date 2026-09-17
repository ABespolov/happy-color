import 'package:flutter/material.dart';
import 'package:happy_color/features/coloring/presentation/pages/coloring_page.dart';
import 'package:happy_color/features/library/domain/entities/library_picture.dart';

class LibraryPictureCard extends StatelessWidget {
  const LibraryPictureCard({super.key, required this.picture});

  final LibraryPicture picture;

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
