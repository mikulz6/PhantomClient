import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/games/presentation/mobile/games_screen.dart';
import '../../features/games/presentation/desktop/desktop_games_screen.dart';
import '../../features/games/presentation/mobile/game_detail_screen.dart';
import '../../features/games/presentation/desktop/desktop_game_detail_screen.dart';
import '../../features/games/presentation/mobile/category_screen.dart';
import '../../features/lobby/presentation/mobile/lobby_screen.dart'; // Mobile Lobby
import '../../features/lobby/presentation/desktop/desktop_lobby_screen.dart'; // Desktop Lobby
import '../../features/profile/presentation/mobile/profile_screen.dart'; // Mobile Profile
import '../../features/profile/presentation/desktop/desktop_profile_screen.dart'; // Desktop Profile
import '../../shared/widgets/main_scaffold.dart';
import '../../features/games/domain/game_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _gamesNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _lobbyNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

class GamesScreenWrapper extends StatelessWidget {
  const GamesScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return const DesktopGamesScreen();
      }
      return const GamesScreen();
    });
  }
}

class GameDetailScreenWrapper extends StatelessWidget {
  final GameModel game;
  const GameDetailScreenWrapper({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return DesktopGameDetailScreen(game: game);
      }
      return GameDetailScreen(game: game);
    });
  }
}

class LobbyScreenWrapper extends StatelessWidget {
  const LobbyScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return const DesktopLobbyScreen();
      }
      return const LobbyScreen();
    });
  }
}

class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 800) {
        return const DesktopProfileScreen();
      }
      return const ProfileScreen();
    });
  }
}

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
              builder: (context, state) => const GamesScreenWrapper(),
              routes: [
                GoRoute(
                  path: 'game/:id',
                  parentNavigatorKey: _rootNavigatorKey, // 覆盖 BottomBar
                  builder: (context, state) {
                    final game = state.extra as GameModel;
                    return GameDetailScreenWrapper(game: game);
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
              builder: (context, state) => const LobbyScreenWrapper(), // 替换为 Wrapper
            ),
          ],
        ),
        // 我的 Tab
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreenWrapper(),
            ),
          ],
        ),
      ],
    ),
  ],
);
