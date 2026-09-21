import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:happy_color/core/widgets/picture_tile.dart';

/// The two-column grid of pictures.
class PictureSliverGrid extends StatelessWidget {
  const PictureSliverGrid({
    super.key,
    required this.pictures,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 0),
  });

  final List<({String id, String assetDir})> pictures;

  final EdgeInsets padding;

  /// The next rows decode before they scroll into view.
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
        // Cells are kept by position on purpose, so on a category switch
        // each fades from its old picture to the new one.
        itemBuilder: (context, index) => PictureTile(
          id: pictures[index].id,
          assetDir: pictures[index].assetDir,
        ),
      ),
    );
  }
}
