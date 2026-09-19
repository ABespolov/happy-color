import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:happy_color/core/widgets/picture_tile.dart';

/// The two-column grid of pictures used by the feed, the library and a
/// collection.
class PictureSliverGrid extends StatelessWidget {
  const PictureSliverGrid({
    super.key,
    required this.pictures,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 0),
  });

  /// Picture ids with the folder each one is stored in.
  final List<({String id, String assetDir})> pictures;

  final EdgeInsets padding;

  /// How far beyond the screen a grid keeps its cards built, so the pictures
  /// of the next rows are decoded before they scroll into view.
  static const cacheExtent = ScrollCacheExtent.pixels(800);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: pictures.length,
        itemBuilder: (context, index) => PictureTile(
          id: pictures[index].id,
          assetDir: pictures[index].assetDir,
        ),
      ),
    );
  }
}
