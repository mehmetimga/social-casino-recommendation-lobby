import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class CasinoMenuDrawer extends StatelessWidget {
  const CasinoMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.casinoBg,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: double.infinity,
        child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/betrivers_banner.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.pillBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.casinoBgSecondary, height: 1),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _MenuSection(
                    title: 'Account',
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () => _showComingSoon(context, 'Profile'),
                      ),
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Wallet',
                        onTap: () => _showComingSoon(context, 'Wallet'),
                      ),
                      _MenuItem(
                        icon: Icons.history,
                        title: 'Transaction History',
                        onTap: () => _showComingSoon(context, 'Transaction History'),
                      ),
                    ],
                  ),
                  _MenuSection(
                    title: 'Games',
                    items: [
                      _MenuItem(
                        icon: Icons.favorite_outline,
                        title: 'Favorites',
                        onTap: () => _showComingSoon(context, 'Favorites'),
                      ),
                      _MenuItem(
                        icon: Icons.access_time,
                        title: 'Recently Played',
                        onTap: () => _showComingSoon(context, 'Recently Played'),
                      ),
                    ],
                  ),
                  _MenuSection(
                    title: 'Reports',
                    items: [
                      _MenuItem(
                        icon: Icons.bar_chart_outlined,
                        title: 'Game History',
                        onTap: () => _showComingSoon(context, 'Game History'),
                      ),
                      _MenuItem(
                        icon: Icons.analytics_outlined,
                        title: 'Statistics',
                        onTap: () => _showComingSoon(context, 'Statistics'),
                      ),
                    ],
                  ),
                  _MenuSection(
                    title: 'Support',
                    items: [
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () => _showComingSoon(context, 'Help Center'),
                      ),
                      _MenuItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Live Chat',
                        onTap: () => _showComingSoon(context, 'Live Chat'),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () => _showComingSoon(context, 'About'),
                      ),
                    ],
                  ),
                  _MenuSection(
                    title: 'Settings',
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () => _showComingSoon(context, 'Notifications'),
                      ),
                      _MenuItem(
                        icon: Icons.security_outlined,
                        title: 'Security',
                        onTap: () => _showComingSoon(context, 'Security'),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Preferences',
                        onTap: () => _showComingSoon(context, 'Preferences'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer
            const Divider(color: AppColors.casinoBgSecondary, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon'),
        backgroundColor: AppColors.casinoBgSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

void showCasinoMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Menu',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const CasinoMenuDrawer();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}
