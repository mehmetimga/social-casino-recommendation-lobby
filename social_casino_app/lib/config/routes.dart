import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/game.dart';
import '../screens/lobby_screen.dart';
import '../screens/live_casino_screen.dart';
import '../screens/sports_screen.dart';
import '../screens/poker_screen.dart';
import '../screens/category_screen.dart';
import '../widgets/layout/main_scaffold.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Bottom navigation routes
        GoRoute(
          path: '/',
          name: 'casino',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LobbyScreen(),
          ),
        ),
        GoRoute(
          path: '/live-casino',
          name: 'live-casino-bottom',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LiveCasinoScreen(),
          ),
        ),
        GoRoute(
          path: '/sports',
          name: 'sports',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SportsScreen(),
          ),
        ),
        GoRoute(
          path: '/poker',
          name: 'poker',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PokerScreen(),
          ),
        ),
        // Category tab routes (within Casino bottom nav)
        GoRoute(
          path: '/category/slots',
          name: 'category-slots',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryScreen(
              categorySlug: 'slots',
              title: 'Slots',
              gameType: GameType.slot,
            ),
          ),
        ),
        GoRoute(
          path: '/category/live-casino',
          name: 'category-live-casino',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryScreen(
              categorySlug: 'live-casino',
              title: 'Live Casino',
              gameType: GameType.live,
            ),
          ),
        ),
        GoRoute(
          path: '/category/table-games',
          name: 'category-table-games',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryScreen(
              categorySlug: 'table-games',
              title: 'Table Games',
              gameType: GameType.table,
            ),
          ),
        ),
        GoRoute(
          path: '/category/instant-win',
          name: 'category-instant-win',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CategoryScreen(
              categorySlug: 'instant-win',
              title: 'Instant Win',
              gameType: GameType.instant,
            ),
          ),
        ),
      ],
    ),
  ],
);
