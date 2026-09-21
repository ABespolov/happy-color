import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/core/theme/app_colors.dart';
import 'package:happy_color/features/navigation/presentation/widgets/app_tab_bar.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: shell,
      bottomNavigationBar: AppTabBar(
        selectedIndex: shell.currentIndex,
        // Tapping the open tab returns it to its first page.
        onSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
      ),
    );
  }
}
