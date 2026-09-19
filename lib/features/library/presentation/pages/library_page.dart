import 'package:flutter/material.dart';
import 'package:happy_color/core/widgets/picture_sliver_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/sheet_sliver.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/banner_carousel.dart';
import 'package:happy_color/features/library/presentation/widgets/category_tabs.dart';
import 'package:happy_color/features/library/presentation/widgets/category_pictures.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  static const _bannerPadding = EdgeInsets.symmetric(vertical: 24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(libraryBannersProvider).value ?? const [];
    final categories = ref.watch(libraryCategoriesProvider).value ?? const [];
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final statusBar = MediaQuery.paddingOf(context).top;
    final bannersHeight = banners.isEmpty
        ? 0.0
        : BannerCarousel.heightFor(MediaQuery.sizeOf(context).width);
    return ColoredBox(
      color: AppColors.background,
      child: CustomScrollView(
        scrollCacheExtent: PictureSliverGrid.cacheExtent,
        slivers: [
          SheetSliver(
            topHeight: statusBar + _bannerPadding.vertical + bannersHeight,
            top: Padding(
              padding: _bannerPadding.add(EdgeInsets.only(top: statusBar)),
              child: banners.isEmpty
                  ? const SizedBox.shrink()
                  : BannerCarousel(banners: banners),
            ),
            headerHeight: CategoryTabs.height + 8,
            header: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CategoryTabs(
                categories: categories,
                selectedId: selectedCategory,
                onSelected: ref.read(selectedCategoryProvider.notifier).select,
              ),
            ),
            slivers: [CategoryPictures(categoryId: selectedCategory)],
          ),
        ],
      ),
    );
  }
}
