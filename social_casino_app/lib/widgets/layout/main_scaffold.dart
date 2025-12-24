import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/lobby_provider.dart';
import '../chat/chat_widget.dart';
import '../search/search_modal.dart';
import '../menu/casino_menu_drawer.dart';
import 'app_header.dart';
import 'category_tab_bar.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _getSelectedBottomIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0; // Casino
      case '/live-casino':
        return 1; // Live Casino
      case '/sports':
        return 2; // Sports
      case '/poker':
        return 3; // Poker
      default:
        return 0;
    }
  }

  void _onBottomNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/live-casino');
        break;
      case 2:
        context.go('/sports');
        break;
      case 3:
        context.go('/poker');
        break;
    }
  }

  void _refreshLobby() {
    // Invalidate all lobby-related providers to force refresh
    ref.invalidate(lobbyLayoutTabsProvider);
    ref.invalidate(currentLobbyLayoutProvider);
    ref.invalidate(lobbyLayoutProvider);
    ref.invalidate(popularGamesProvider);
    ref.invalidate(newGamesProvider);
    ref.invalidate(jackpotGamesProvider);
    ref.invalidate(heroPromotionsProvider);
    ref.invalidate(recommendationsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lobby refreshed'),
        backgroundColor: AppColors.casinoGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Get game type from current route for category-specific search
  GameType? _getGameTypeFromRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('slots')) return GameType.slot;
    if (location.contains('live-casino')) return GameType.live;
    if (location.contains('table-games')) return GameType.table;
    if (location.contains('instant-win')) return GameType.instant;
    return null; // My Casino or home - search all games
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedBottomIndex(context);

    return Scaffold(
      backgroundColor: AppColors.casinoBg,
      body: Stack(
        children: [
          Column(
            children: [
              // Top App Bar (pinned) - Logo + Login/Join + Search
              AppHeader(
                onSearchTap: () => showSearchModal(context, gameType: _getGameTypeFromRoute(context)),
                onMenuTap: () => showCasinoMenu(context),
                onRefreshTap: _refreshLobby,
              ),
              // Category Tab Bar (pinned) - Layout categories
              const CategoryTabBar(),
              // Scrollable content area
              Expanded(
                child: widget.child,
              ),
            ],
          ),
          // Chat widget overlay
          const ChatWidget(),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) => _onBottomNavTapped(context, index),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.casinoBgSecondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.casino_outlined,
                activeIcon: Icons.casino,
                label: 'Casino',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
                isHighlighted: true,
              ),
              _NavItem(
                icon: Icons.live_tv_outlined,
                activeIcon: Icons.live_tv,
                label: 'Live Casino',
                isSelected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.sports_basketball_outlined,
                activeIcon: Icons.sports_basketball,
                label: 'Sports',
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.style_outlined,
                activeIcon: Icons.style,
                label: 'Poker',
                isSelected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppColors.casinoGold;
    final Color inactiveColor = AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected && isHighlighted
                    ? AppColors.casinoGold.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
