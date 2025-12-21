import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color casinoBg = Color(0xFF0A0A0A);
  static const Color casinoBgSecondary = Color(0xFF1A1A2E);
  static const Color casinoBgCard = Color(0xFF16162A);

  // Primary - Purple
  static const Color casinoPurple = Color(0xFF7C3AED);
  static const Color casinoPurpleDark = Color(0xFF5B21B6);
  static const Color casinoPurpleLight = Color(0xFFA78BFA);

  // Accent - Gold
  static const Color casinoGold = Color(0xFFFBBF24);
  static const Color casinoGoldDark = Color(0xFFD97706);
  static const Color casinoGoldLight = Color(0xFFFCD34D);

  // Accent - Red
  static const Color casinoAccent = Color(0xFFE11D48);

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradients
  static const LinearGradient gradientCasino = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF1A0A2E)],
  );

  static const LinearGradient gradientCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16162A)],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
  );

  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  );

  // Shadows
  static List<BoxShadow> get casinoShadow => [
        BoxShadow(
          color: casinoPurple.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get casinoShadowLarge => [
        BoxShadow(
          color: casinoPurple.withValues(alpha: 0.4),
          blurRadius: 40,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get goldShadow => [
        BoxShadow(
          color: casinoGold.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}
