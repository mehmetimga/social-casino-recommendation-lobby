import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback? onLoginTap;
  final VoidCallback? onJoinTap;
  final VoidCallback? onLogoutTap;

  const AppHeader({
    super.key,
    this.isLoggedIn = false,
    this.onLoginTap,
    this.onJoinTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.casinoBgSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.casinoPurpleDark,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo from asset
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/images/betrivers_banner.png',
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          if (!isLoggedIn) ...[
            // Log In button
            TextButton(
              onPressed: onLoginTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Join Now button
            ElevatedButton(
              onPressed: onJoinTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.casinoGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Join Now',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            // Logged in state - show user icon and logout
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: onLogoutTap,
            ),
          ],
        ],
      ),
    );
  }
}
