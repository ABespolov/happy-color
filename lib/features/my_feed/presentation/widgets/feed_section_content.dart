import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/features/my_feed/presentation/providers/feed_providers.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/empty_state.dart';
import 'package:happy_color/core/widgets/async_sliver.dart';
import 'package:happy_color/core/widgets/picture_sliver_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/router.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// Sliver with the pictures of a section, or its empty state. On a switch
/// the pictures slide the way the section switcher moved.
class FeedSectionContent extends ConsumerStatefulWidget {
  const FeedSectionContent({super.key, required this.section});

  final FeedSection section;

  @override
  ConsumerState<FeedSectionContent> createState() => _FeedSectionContentState();
}

class _FeedSectionContentState extends ConsumerState<FeedSectionContent> {
  var _direction = 1;

  @override
  void didUpdateWidget(FeedSectionContent old) {
    super.didUpdateWidget(old);
    if (old.section != widget.section) {
      _direction = widget.section.index < old.section.index ? -1 : 1;
    }
  }

  FeedSection get section => widget.section;

  @override
  Widget build(BuildContext context) {
    return AsyncSliver(
      value: ref.watch(feedPicturesProvider(section)),
      fillRemaining: true,
      builder: (pictures) => pictures.isEmpty
          ? SliverFillRemaining(
              hasScrollBody: false,
              child: _emptyState(context, AppLocalizations.of(context)!),
            )
          : PictureSliverGrid(
              pictures: [
                for (final picture in pictures)
                  (id: picture.id, assetDir: picture.assetDir),
              ],
              padding: const EdgeInsets.symmetric(horizontal: 16),
              slideDirection: _direction,
            ),
    );
  }

  void _openLibrary(BuildContext context) => context.go(Routes.library);

  Widget _emptyState(BuildContext context, AppLocalizations l10n) =>
      switch (section) {
        FeedSection.starred => EmptyState(
          illustration: 'starred_empty',
          message: l10n.starredEmpty,
          action: l10n.starredEmptyAction,
          onAction: () => _openLibrary(context),
        ),
        FeedSection.inProgress || FeedSection.completed => EmptyState(
          illustration: 'completed_empty',
          message: l10n.completedEmpty,
          action: l10n.completedEmptyAction,
          onAction: () => _openLibrary(context),
        ),
      };
}
