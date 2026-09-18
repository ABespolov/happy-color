import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/library/presentation/pages/library_page.dart';
import 'package:happy_color/features/my_feed/presentation/pages/my_feed_page.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';
import 'package:happy_color/features/navigation/presentation/providers/selected_tab_provider.dart';
import 'package:happy_color/features/navigation/presentation/widgets/app_tab_bar.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(selectedTabProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: tab.index,
        children: [
          for (final tab in AppTab.values)
            switch (tab) {
              AppTab.myFeed => const MyFeedPage(),
              AppTab.library => const LibraryPage(),
              AppTab.more => const SizedBox.shrink(),
            },
        ],
      ),
      bottomNavigationBar: const AppTabBar(),
    );
  }
}
