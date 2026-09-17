import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';
import 'package:happy_color/features/navigation/presentation/providers/selected_tab_provider.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_bar_item.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/library_tab_icon.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/more_tab_icon.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/my_feed_tab_icon.dart';

/// White rounded bottom bar with animated tab icons.
class AppTabBar extends ConsumerWidget {
  const AppTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTabProvider);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.tabBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.tabBarShadow,
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: TabBarItem(
                    icon: _iconOf(tab),
                    label: _labelOf(tab),
                    selected: tab == selected,
                    onTap: () =>
                        ref.read(selectedTabProvider.notifier).select(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _labelOf(AppTab tab) => switch (tab) {
    AppTab.myFeed => 'My Feed',
    AppTab.library => 'Library',
    AppTab.more => 'More',
  };

  static TabIconBuilder _iconOf(AppTab tab) => switch (tab) {
    AppTab.myFeed => (progress) => MyFeedTabIcon(progress: progress),
    AppTab.library => (progress) => LibraryTabIcon(progress: progress),
    AppTab.more => (progress) => MoreTabIcon(progress: progress),
  };
}
