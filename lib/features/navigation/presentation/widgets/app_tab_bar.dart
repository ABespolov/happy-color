import 'package:flutter/material.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_bar_item.dart';
import 'package:happy_color/l10n/app_localizations.dart';

/// White rounded bottom bar with animated tab icons.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: EdgeInsets.only(bottom: _bottomInset(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            children: [
              for (final tab in AppTab.values)
                Expanded(
                  child: TabBarItem(
                    key: ValueKey(tab),
                    icon: _iconOf(tab),
                    label: _labelOf(tab, l10n),
                    selected: tab.index == selectedIndex,
                    onTap: () => onSelected(tab.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// A gesture bar only needs part of its inset, otherwise the labels sit on
  /// a wide empty strip; the buttons of a navigation bar need all of theirs,
  /// or they cover the labels. Where the system leaves no inset at all, the
  /// labels still keep some room instead of touching the screen edge.
  static double _bottomInset(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final room = inset > _gestureBarHeight
        ? inset
        : inset.clamp(_minimumInset, 20.0);
    // Plus a gap, so the labels never sit right on the system bar.
    return room + _gap;
  }

  /// Anything taller than this is a navigation bar with buttons.
  static const _gestureBarHeight = 36.0;

  static const _minimumInset = 12.0;
  static const _gap = 8.0;

  static String _labelOf(AppTab tab, AppLocalizations l10n) => switch (tab) {
    AppTab.myFeed => l10n.myFeedTab,
    AppTab.library => l10n.libraryTab,
    AppTab.more => l10n.moreTab,
  };

  static String _iconOf(AppTab tab) => switch (tab) {
    AppTab.myFeed => 'assets/icons/tabs/my_feed.png',
    AppTab.library => 'assets/icons/tabs/library.png',
    AppTab.more => 'assets/icons/tabs/more.png',
  };
}
