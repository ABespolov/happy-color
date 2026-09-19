import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/async_sliver.dart';
import 'package:happy_color/core/widgets/picture_sliver_grid.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';

/// Sliver grid with the pictures of a category. On a switch the pictures
/// slide the way the category bar moved.
class CategoryPictures extends ConsumerStatefulWidget {
  const CategoryPictures({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryPictures> createState() => _CategoryPicturesState();
}

class _CategoryPicturesState extends ConsumerState<CategoryPictures> {
  var _direction = 1;

  @override
  void didUpdateWidget(CategoryPictures old) {
    super.didUpdateWidget(old);
    if (old.categoryId == widget.categoryId) return;
    final categories = ref.read(libraryCategoriesProvider).value ?? const [];
    int indexOf(String id) => categories.indexWhere((c) => c.id == id);
    _direction = indexOf(widget.categoryId) < indexOf(old.categoryId) ? -1 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncSliver(
      value: ref.watch(libraryPicturesProvider(widget.categoryId)),
      builder: (pictures) => PictureSliverGrid(
        pictures: [
          for (final picture in pictures)
            (id: picture.id, assetDir: picture.assetDir),
        ],
        slideDirection: _direction,
      ),
    );
  }
}
