import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/library/presentation/providers/library_providers.dart';
import 'package:happy_color/features/library/presentation/widgets/collection_counter.dart';
import 'package:happy_color/features/library/presentation/widgets/library_picture_grid.dart';

/// Everything behind one banner: its artwork and the pictures of its category.
///
/// The artwork scrolls away under a bar that keeps the back button and shows
/// the collection title once the artwork is gone.
class CollectionPage extends ConsumerStatefulWidget {
  const CollectionPage({super.key, required this.categoryId});

  final String categoryId;

  /// Width to height of the banner artwork.
  static const _bannerRatio = 1.9;

  @override
  ConsumerState<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends ConsumerState<CollectionPage> {
  /// True once the artwork has scrolled behind the bar.
  final _collapsed = ValueNotifier(false);

  @override
  void dispose() {
    _collapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryId = widget.categoryId;
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
    const ratio = CollectionPage._bannerRatio;
    return Scaffold(
      backgroundColor: AppColors.sheet,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            // The artwork keeps its own shape, status bar included.
            expandedHeight: MediaQuery.sizeOf(context).width / ratio,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: _BackButton(collapsed: _collapsed),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final statusBar = MediaQuery.paddingOf(context).top;
                final collapsed =
                    constraints.maxHeight <= statusBar + kToolbarHeight + 1;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _collapsed.value = collapsed,
                );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _artwork(banner?.imageAsset),
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
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: collapsed ? 1 : 0,
                          child: Center(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          LibraryPictureGrid(categoryId: categoryId),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
          ),
        ],
      ),
    );
  }

  Widget _artwork(String? image) => image == null
      ? const ColoredBox(color: AppColors.placeholder)
      : Image.asset(image, fit: BoxFit.cover, alignment: Alignment.topCenter);
}

/// Sits in a white circle over the artwork and loses it once the bar takes
/// over, where the plain arrow reads better.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.collapsed});

  final ValueListenable<bool> collapsed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder(
        valueListenable: collapsed,
        builder: (context, collapsed, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: collapsed ? Colors.transparent : Colors.white,
          ),
          child: child,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: Navigator.of(context).pop,
            child: const SizedBox.square(
              dimension: 36,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
