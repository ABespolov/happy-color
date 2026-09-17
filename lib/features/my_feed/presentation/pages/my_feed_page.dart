import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/my_feed/presentation/providers/feed_providers.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/feed_header.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/feed_section_content.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/feed_section_ui.dart';
import 'package:happy_color/features/my_feed/presentation/widgets/section_switcher.dart';

class MyFeedPage extends ConsumerWidget {
  const MyFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedFeedSectionProvider);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: AppColors.headerGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const FeedHeader(),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.sheet,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionSwitcher(
                        selected: section,
                        onSelected: ref
                            .read(selectedFeedSectionProvider.notifier)
                            .select,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: FeedSectionContent(
                            key: ValueKey(section),
                            section: section,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
