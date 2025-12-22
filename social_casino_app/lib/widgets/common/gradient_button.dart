import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

enum GradientButtonVariant { gold, purple }

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final GradientButtonVariant variant;
  final bool isLoading;
  final double? width;
  final IconData? icon;
  final bool compact;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = GradientButtonVariant.gold,
    this.isLoading = false,
    this.width,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = variant == GradientButtonVariant.gold
        ? AppColors.gradientGold
        : AppColors.gradientPurple;

    final shadow = variant == GradientButtonVariant.gold
        ? AppColors.goldShadow
        : AppColors.casinoShadow;

    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(compact ? 6 : 8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 20,
              vertical: compact ? 8 : 12,
            ),
            child: isLoading
                ? SizedBox(
                    height: compact ? 16 : 20,
                    width: compact ? 16 : 20,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: compact ? 14 : 18),
                        SizedBox(width: compact ? 6 : 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 12 : 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
