import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:teamcoach/features/auth/screens/login_screen.dart';
import 'package:teamcoach/features/auth/screens/register_screen.dart';
import 'package:teamcoach/features/roster/screens/roster_screen.dart';
import 'package:teamcoach/features/roster/screens/player_form_screen.dart';
import 'package:teamcoach/features/games/screens/games_list_screen.dart';
import 'package:teamcoach/features/games/screens/create_game_screen.dart';
import 'package:teamcoach/features/stats/screens/team_stats_screen.dart';
import 'package:teamcoach/shared/widgets/main_scaffold.dart';
import 'package:teamcoach/shared/models/player.dart';
import 'package:teamcoach/shared/models/game.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/roster',
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      
      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/roster',
            name: 'roster',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RosterScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-player',
                pageBuilder: (context, state) => MaterialPage(
                  key: state.pageKey,
                  child: const PlayerFormScreen(),
                ),
              ),
              GoRoute(
                path: 'edit/:playerId',
                name: 'edit-player',
                pageBuilder: (context, state) {
                  final player = state.extra as Player?;
                  return MaterialPage(
                    key: state.pageKey,
                    child: PlayerFormScreen(player: player),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/games',
            name: 'games',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GamesListScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-game',
                pageBuilder: (context, state) => MaterialPage(
                  key: state.pageKey,
                  child: const CreateGameScreen(),
                ),
              ),
              GoRoute(
                path: ':gameId/edit',
                name: 'edit-game',
                pageBuilder: (context, state) {
                  final game = state.extra as Game?;
                  return MaterialPage(
                    key: state.pageKey,
                    child: CreateGameScreen(game: game),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/stats',
            name: 'stats',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TeamStatsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
} 