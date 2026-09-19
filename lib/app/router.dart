import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:happy_color/app/home_shell.dart';
import 'package:happy_color/features/coloring/presentation/pages/coloring_page.dart';
import 'package:happy_color/features/library/presentation/pages/collection_page.dart';
import 'package:happy_color/features/library/presentation/pages/library_page.dart';
import 'package:happy_color/features/my_feed/presentation/pages/my_feed_page.dart';
import 'package:happy_color/features/navigation/domain/entities/app_tab.dart';
import 'package:happy_color/features/navigation/presentation/widgets/tab_switcher.dart';

abstract final class Routes {
  static const myFeed = '/feed';
  static const library = '/library';
  static const more = '/more';

  static String collection(String categoryId) => '$library/$categoryId';

  static String picture(String id, String assetDir) =>
      '/picture/$id?dir=$assetDir';

  static String of(AppTab tab) => switch (tab) {
    AppTab.myFeed => myFeed,
    AppTab.library => library,
    AppTab.more => more,
  };
}

/// Pushed screens slide in from the side and swipe back, on both platforms.
CupertinoPage<void> _slideIn(GoRouterState state, Widget child) =>
    CupertinoPage(key: state.pageKey, child: child);

/// Every tab keeps its own navigation stack, so a collection opened from the
/// library is still there after a trip to another tab.
final router = GoRouter(
  initialLocation: Routes.myFeed,
  routes: [
    StatefulShellRoute(
      builder: (context, state, shell) => HomeShell(shell: shell),
      navigatorContainerBuilder: (context, shell, children) =>
          TabSwitcher(index: shell.currentIndex, children: children),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.myFeed,
              builder: (context, state) => const MyFeedPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.library,
              builder: (context, state) => const LibraryPage(),
              routes: [
                GoRoute(
                  path: ':categoryId',
                  pageBuilder: (context, state) => _slideIn(
                    state,
                    CollectionPage(
                      categoryId: state.pathParameters['categoryId']!,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.more,
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/picture/:id',
      pageBuilder: (context, state) => _slideIn(
        state,
        ColoringPage(
          id: state.pathParameters['id']!,
          assetDir: state.uri.queryParameters['dir']!,
        ),
      ),
    ),
  ],
);
