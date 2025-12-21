import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/lobby_screen.dart';
import '../screens/slots_screen.dart';
import '../screens/live_casino_screen.dart';
import '../screens/table_games_screen.dart';
import '../widgets/layout/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'lobby',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LobbyScreen(),
          ),
        ),
        GoRoute(
          path: '/slots',
          name: 'slots',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SlotsScreen(),
          ),
        ),
        GoRoute(
          path: '/live-casino',
          name: 'live-casino',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LiveCasinoScreen(),
          ),
        ),
        GoRoute(
          path: '/table-games',
          name: 'table-games',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TableGamesScreen(),
          ),
        ),
      ],
    ),
  ],
);
