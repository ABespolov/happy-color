import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/features/my_feed/domain/entities/feed_section.dart';
import 'package:happy_color/features/my_feed/presentation/providers/feed_providers.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/empty_state.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/picture_grid.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';
import 'package:happy_color/features/navigation/presentation/providers/selected_tab_provider.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// Sliver with the pictures of a section, or its empty state.
class FeedSectionContent extends ConsumerWidget {
  const FeedSectionContent({super.key, required this.section});

  final FeedSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictures = ref.watch(feedPicturesProvider(section));
    return switch (pictures) {
      AsyncData(:final value) when value.isNotEmpty => PictureGrid(
        pictures: value,
      ),
      AsyncData() => SliverFillRemaining(
        hasScrollBody: false,
        child: _emptyState(ref, AppLocalizations.of(context)!),
      ),
      AsyncError(:final error) => SliverToBoxAdapter(
        child: Center(
          child: Text(AppLocalizations.of(context)!.loadingFailed('$error')),
        ),
      ),
      _ => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }

  void _openLibrary(WidgetRef ref) =>
      ref.read(selectedTabProvider.notifier).select(AppTab.library);

  Widget _emptyState(WidgetRef ref, AppLocalizations l10n) => switch (section) {
    FeedSection.starred => EmptyState(
      illustration: 'starred_empty',
      message: l10n.starredEmpty,
      action: l10n.starredEmptyAction,
      onAction: () => _openLibrary(ref),
    ),
    FeedSection.inProgress || FeedSection.completed => EmptyState(
      illustration: 'completed_empty',
      message: l10n.completedEmpty,
      action: l10n.completedEmptyAction,
      onAction: () => _openLibrary(ref),
    ),
  };
}
