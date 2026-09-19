import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/widgets/async_sliver.dart';
import 'package:happy_color/core/widgets/picture_sliver_grid.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';

/// Sliver grid with the pictures of a category, faded in whenever the
/// category changes.
class CategoryPictures extends ConsumerStatefulWidget {
  const CategoryPictures({super.key, required this.categoryId});

  final String categoryId;

  @override
  ConsumerState<CategoryPictures> createState() => _CategoryPicturesState();
}

class _CategoryPicturesState extends ConsumerState<CategoryPictures>
    with SingleTickerProviderStateMixin {
  late final _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1,
  );

  late final _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeOut);

  @override
  void didUpdateWidget(CategoryPictures old) {
    super.didUpdateWidget(old);
    // Even a grid whose pictures are all decoded already would otherwise be
    // swapped in within a frame.
    if (old.categoryId != widget.categoryId) _fade.forward(from: 0);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverFadeTransition(
      opacity: _opacity,
      sliver: AsyncSliver(
        value: ref.watch(libraryPicturesProvider(widget.categoryId)),
        builder: (pictures) => PictureSliverGrid(
          pictures: [
            for (final picture in pictures)
              (id: picture.id, assetDir: picture.assetDir),
          ],
        ),
      ),
    );
  }
}
