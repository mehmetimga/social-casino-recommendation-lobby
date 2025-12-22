import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback? onLoginTap;
  final VoidCallback? onJoinTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMenuTap;

  const AppHeader({
    super.key,
    this.isLoggedIn = false,
    this.onLoginTap,
    this.onJoinTap,
    this.onLogoutTap,
    this.onSearchTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.casinoBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Logo + Login/Join buttons
          Row(
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/betrivers_banner.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              if (!isLoggedIn) ...[
                // Log In button
                _OutlinedButton(
                  text: 'Log In',
                  onPressed: onLoginTap,
                ),
                const SizedBox(width: 8),
                // Register button
                _GoldButton(
                  text: 'Register',
                  onPressed: onJoinTap,
                ),
              ] else ...[
                // Logged in state
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                  onPressed: onLogoutTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Search bar row
          Row(
            children: [
              // Casino menu button
              GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.pillBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Casino',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Search input
              Expanded(
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.pillBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search Casino',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.mic_none,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _OutlinedButton({
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _GoldButton({
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.gradientGold,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: AppColors.casinoGold.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
