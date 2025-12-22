import 'package:flutter/material.dart';

class AppColors {
  // Background colors - Pure black for premium casino feel
  static const Color casinoBg = Color(0xFF000000);
  static const Color casinoBgSecondary = Color(0xFF121212);
  static const Color casinoBgCard = Color(0xFF1A1A1A);
  static const Color casinoBgElevated = Color(0xFF242424);

  // Category pill backgrounds
  static const Color pillBg = Color(0xFF2A2A2A);
  static const Color pillBgActive = Color(0xFF3A3A3A);

  // Primary - Gold
  static const Color casinoGold = Color(0xFFD4AF37);
  static const Color casinoGoldDark = Color(0xFFB8860B);
  static const Color casinoGoldLight = Color(0xFFE6C762);
  static const Color casinoGoldMuted = Color(0xFF8B7355);

  // Secondary - Purple (accent)
  static const Color casinoPurple = Color(0xFF9333EA);
  static const Color casinoPurpleDark = Color(0xFF7C3AED);
  static const Color casinoPurpleLight = Color(0xFFA78BFA);

  // Accent - Red for hot/live
  static const Color casinoAccent = Color(0xFFDC2626);
  static const Color casinoRed = Color(0xFFEF4444);

  // Success/Live green
  static const Color casinoGreen = Color(0xFF22C55E);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textDark = Color(0xFF1A1A1A);

  // Gradients
  static const LinearGradient gradientCasino = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF000000), Color(0xFF0A0A0A)],
  );

  static const LinearGradient gradientCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F1F1F), Color(0xFF141414)],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
  );

  static const LinearGradient gradientGoldSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE6C762), Color(0xFFD4AF37)],
  );

  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
  );

  static const LinearGradient gradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  // Shadows
  static List<BoxShadow> get casinoShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get casinoShadowLarge => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get goldShadow => [
        BoxShadow(
          color: casinoGold.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get goldGlow => [
        BoxShadow(
          color: casinoGold.withValues(alpha: 0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];
}
