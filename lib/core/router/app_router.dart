import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/games/presentation/games_screen.dart';
import '../../features/games/presentation/game_detail_screen.dart';
import '../../features/games/presentation/category_screen.dart';
import '../../features/lobby/presentation/lobby_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/games/domain/game_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _gamesNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _lobbyNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/games',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // 游戏 Tab
        StatefulShellBranch(
          navigatorKey: _gamesNavigatorKey,
          routes: [
            GoRoute(
              path: '/games',
              builder: (context, state) => const GamesScreen(),
              routes: [
                GoRoute(
                  path: 'game/:id',
                  parentNavigatorKey: _rootNavigatorKey, // 覆盖 BottomBar
                  builder: (context, state) {
                    final game = state.extra as GameModel;
                    return GameDetailScreen(game: game);
                  },
                ),
                GoRoute(
                  path: 'category/:name',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final name = state.pathParameters['name']!;
                    return CategoryScreen(categoryName: name);
                  },
                ),
              ],
            ),
          ],
        ),
        // 大厅 Tab
        StatefulShellBranch(
          navigatorKey: _lobbyNavigatorKey,
          routes: [
            GoRoute(
              path: '/lobby',
              builder: (context, state) => const LobbyScreen(),
            ),
          ],
        ),
        // 我的 Tab
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
