import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/core/widgets/sheet_sliver.dart';
import 'package:happy_color/features/my_feed/presentation/providers/feed_providers.dart';
import 'package:happy_color/core/widgets/page_header.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/feed_section_content.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/feed_section_ui.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/section_switcher.dart';
import 'package:happy_color/l10n/app_localizations.dart';

class MyFeedPage extends ConsumerWidget {
  const MyFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedFeedSectionProvider);
    return DecoratedBox(
      decoration: PageHeader.background,
      child: CustomScrollView(
        slivers: [
          SheetSliver(
            topHeight: PageHeader.heightOf(context),
            top: PageHeader(title: AppLocalizations.of(context)!.feedTitle),
            headerHeight: SectionSwitcher.height + 12,
            header: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SectionSwitcher(
                selected: section,
                onSelected: ref
                    .read(selectedFeedSectionProvider.notifier)
                    .select,
              ),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    section.title(AppLocalizations.of(context)!),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              FeedSectionContent(section: section),
            ],
          ),
        ],
      ),
    );
  }
}
