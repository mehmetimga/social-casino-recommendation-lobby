import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';
import '../chat/chat_widget.dart';
import 'app_header.dart';
import 'category_tab_bar.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.casinoBg,
      body: Stack(
        children: [
          Column(
            children: [
              // Top App Bar (pinned) - Logo + Login/Join
              const AppHeader(),
              // Category Tab Bar (pinned) - Layout categories like web app
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.casinoBgSecondary,
          border: Border(
            top: BorderSide(
              color: AppColors.casinoPurpleDark,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  label: 'Casino',
                  imagePath: 'assets/images/casino_banner.png',
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  label: 'Live Casino',
                  imagePath: 'assets/images/live_casino.png',
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  label: 'Sports',
                  imagePath: 'assets/images/sports_banner.png',
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  label: 'Poker',
                  imagePath: 'assets/images/poker_banner.png',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required String imagePath,
  }) {
    final isSelected = _getSelectedBottomIndex(context) == index;

    return GestureDetector(
      onTap: () => _onBottomNavTapped(context, index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 28,
              height: 28,
              color: isSelected ? AppColors.casinoGold : AppColors.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.casinoGold : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
