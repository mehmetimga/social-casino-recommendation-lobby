import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';

class GameBadge extends StatelessWidget {
  final BadgeType badge;
  final bool small;

  const GameBadge({
    super.key,
    required this.badge,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig(badge);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: config.gradient,
        borderRadius: BorderRadius.circular(small ? 4 : 6),
        boxShadow: [
          BoxShadow(
            color: config.shadowColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _BadgeConfig _getBadgeConfig(BadgeType badge) {
    switch (badge) {
      case BadgeType.newBadge:
        return _BadgeConfig(
          label: 'NEW',
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          shadowColor: const Color(0xFF10B981),
        );
      case BadgeType.exclusive:
        return _BadgeConfig(
          label: 'EXCLUSIVE',
          gradient: AppColors.gradientPurple,
          shadowColor: AppColors.casinoPurple,
        );
      case BadgeType.hot:
        return _BadgeConfig(
          label: 'HOT',
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          shadowColor: const Color(0xFFEF4444),
        );
      case BadgeType.jackpot:
        return _BadgeConfig(
          label: 'JACKPOT',
          gradient: AppColors.gradientGold,
          shadowColor: AppColors.casinoGold,
        );
      case BadgeType.featured:
        return _BadgeConfig(
          label: 'FEATURED',
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          ),
          shadowColor: const Color(0xFF3B82F6),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final LinearGradient gradient;
  final Color shadowColor;

  _BadgeConfig({
    required this.label,
    required this.gradient,
    required this.shadowColor,
  });
}
