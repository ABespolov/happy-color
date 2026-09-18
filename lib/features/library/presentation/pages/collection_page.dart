import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/sheet_sliver.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/collection_counter.dart';
import 'package:happy_color/features/library/presentation/widgets/library_picture_grid.dart';

/// Everything behind one banner: its artwork and the pictures of its category.
class CollectionPage extends ConsumerWidget {
  const CollectionPage({super.key, required this.categoryId});

  final String categoryId;

  /// Width to height of the banner artwork.
  static const _artworkRatio = 1.9;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictures = ref.watch(libraryPicturesProvider(categoryId)).value;
    final banner = ref
        .watch(libraryBannersProvider)
        .value
        ?.where((banner) => banner.id == categoryId)
        .firstOrNull;
    final artworkHeight =
        MediaQuery.sizeOf(context).width / _artworkRatio +
        MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SheetSliver(
                topHeight: artworkHeight,
                top: _artwork(banner?.imageAsset),
                headerHeight: 8,
                header: const SizedBox.shrink(),
                slivers: [LibraryPictureGrid(categoryId: categoryId)],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: MediaQuery.paddingOf(context).top + 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _BackButton(),
                if (pictures != null) CollectionCounter(count: pictures.length),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _artwork(String? image) {
    return image == null
        ? const ColoredBox(color: AppColors.placeholder)
        : Image.asset(image, fit: BoxFit.cover, alignment: Alignment.topCenter);
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: Navigator.of(context).pop,
        child: const SizedBox.square(
          dimension: 36,
          child: Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.ink),
        ),
      ),
    );
  }
}
