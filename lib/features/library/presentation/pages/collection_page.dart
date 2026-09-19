import 'package:flutter/material.dart';
import 'package:happy_color/core/widgets/picture_sliver_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/circle_icon_button.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/collection_counter.dart';
import 'package:happy_color/features/library/presentation/widgets/banner_card.dart';
import 'package:happy_color/features/library/presentation/widgets/category_pictures.dart';

/// Everything behind one banner: its artwork and the pictures of its category.
///
/// The artwork scrolls away under a bar that keeps the back button and shows
/// the collection title once the artwork is gone.
class CollectionPage extends ConsumerWidget {
  const CollectionPage({super.key, required this.categoryId});

  final String categoryId;

  /// Width to height of the banner artwork.
  static const _bannerRatio = 1.9;

  /// The last stretch of the collapse, over which the back button loses its
  /// white circle and the title comes in. Both follow the scroll itself: a
  /// switch at one point flickers when the scroll hovers around it.
  static const _handover = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictures = ref.watch(libraryPicturesProvider(categoryId)).value;
    final banner = ref
        .watch(libraryBannersProvider)
        .value
        ?.where((banner) => banner.id == categoryId)
        .firstOrNull;
    final title =
        ref
            .watch(libraryCategoriesProvider)
            .value
            ?.where((category) => category.id == categoryId)
            .firstOrNull
            ?.title ??
        '';
    const ratio = _bannerRatio;
    return Scaffold(
      backgroundColor: AppColors.sheet,
      body: CustomScrollView(
        scrollCacheExtent: PictureSliverGrid.cacheExtent,
        slivers: [
          SliverAppBar(
            pinned: true,
            // The artwork keeps its own shape, status bar included.
            expandedHeight: MediaQuery.sizeOf(context).width / ratio,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            // The back button sits in the flexible space, where it can
            // follow the collapse; the bar itself stays empty.
            automaticallyImplyLeading: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final statusBar = MediaQuery.paddingOf(context).top;
                // 1 while the artwork is behind the bar, 0 once it is gone.
                final artwork =
                    ((constraints.maxHeight - statusBar - kToolbarHeight) /
                            _handover)
                        .clamp(0.0, 1.0);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _artwork(context, banner?.imageAsset),
                          if (pictures != null)
                            Positioned(
                              top: statusBar + 8,
                              right: 12,
                              child: CollectionCounter(count: pictures.length),
                            ),
                        ],
                      ),
                    ),
                    // The title takes over once the artwork has scrolled away.
                    Positioned(
                      top: statusBar,
                      left: 0,
                      right: 0,
                      height: kToolbarHeight,
                      child: IgnorePointer(
                        child: Center(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink.withValues(
                                alpha: 1 - artwork,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Over the artwork the arrow sits in a white circle; over
                    // the bar the plain arrow reads better.
                    Positioned(
                      top: statusBar + (kToolbarHeight - 44) / 2,
                      left: 6,
                      child: CircleIconButton.back(
                        context,
                        background: Colors.white.withValues(alpha: artwork),
                        elevation: 2 * artwork,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          CategoryPictures(categoryId: categoryId),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
          ),
        ],
      ),
    );
  }

  Widget _artwork(BuildContext context, String? image) => image == null
      ? const ColoredBox(color: AppColors.placeholder)
      : Image.asset(
          image,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          cacheWidth: BannerCard.cacheWidth(context),
        );
}
