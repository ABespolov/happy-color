import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';
import 'package:happy_color/features/navigation/presentation/providers/selected_tab_provider.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_bar_item.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/library_tab_icon.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/more_tab_icon.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_icons/my_feed_tab_icon.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// White rounded bottom bar with animated tab icons.
class AppTabBar extends ConsumerWidget {
  const AppTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTabProvider);
    final l10n = AppLocalizations.of(context)!;
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
      // The home indicator inset would leave a wide empty strip under the
      // labels, so only part of it is kept.
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom.clamp(0.0, 20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: TabBarItem(
                    icon: _iconOf(tab),
                    label: _labelOf(tab, l10n),
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

  static String _labelOf(AppTab tab, AppLocalizations l10n) => switch (tab) {
    AppTab.myFeed => l10n.myFeedTab,
    AppTab.library => l10n.libraryTab,
    AppTab.more => l10n.moreTab,
  };

  static TabIconBuilder _iconOf(AppTab tab) => switch (tab) {
    AppTab.myFeed => (progress) => MyFeedTabIcon(progress: progress),
    AppTab.library => (progress) => LibraryTabIcon(progress: progress),
    AppTab.more => (progress) => MoreTabIcon(progress: progress),
  };
}
