import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/async_sliver.dart';
import 'package:happy_color/core/widgets/picture_sliver_grid.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';

/// Sliver grid with the pictures of a category. Its cards ease in on their
/// own whenever the category changes.
class CategoryPictures extends ConsumerWidget {
  const CategoryPictures({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncSliver(
      value: ref.watch(libraryPicturesProvider(categoryId)),
      builder: (pictures) => PictureSliverGrid(
        // Keyed by category: a picture in two categories would otherwise
        // keep its card, and come in without the others.
        key: ValueKey(categoryId),
        pictures: [
          for (final picture in pictures)
            (id: picture.id, assetDir: picture.assetDir),
        ],
      ),
    );
  }
}
