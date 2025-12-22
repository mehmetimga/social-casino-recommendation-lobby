import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';
import '../../config/theme/app_colors.dart';
import '../../models/promotion.dart';
import '../../models/lobby_layout.dart';
import '../common/gradient_button.dart';
import 'countdown_timer.dart';

class PromotionBanner extends StatelessWidget {
  final Promotion promotion;
  final BannerSize size;
  final BannerAlignment alignment;
  final bool showCountdown;
  final bool rounded;
  final bool showOverlay;
  final double marginTop;
  final double marginBottom;

  const PromotionBanner({
    super.key,
    required this.promotion,
    this.size = BannerSize.medium,
    this.alignment = BannerAlignment.center,
    this.showCountdown = false,
    this.rounded = true,
    this.showOverlay = true,
    this.marginTop = 16,
    this.marginBottom = 16,
  });

  double _getHeight() {
    switch (size) {
      case BannerSize.small:
        return 100;
      case BannerSize.medium:
        return 140;
      case BannerSize.large:
        return 180;
    }
  }

  CrossAxisAlignment _getAlignment() {
    switch (alignment) {
      case BannerAlignment.left:
        return CrossAxisAlignment.start;
      case BannerAlignment.center:
        return CrossAxisAlignment.center;
      case BannerAlignment.right:
        return CrossAxisAlignment.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = promotion.backgroundImage != null
        ? ApiConfig.getMediaUrl(promotion.backgroundImage!.url)
        : promotion.image != null
            ? ApiConfig.getMediaUrl(promotion.image!.url)
            : null;

    return Container(
      margin: EdgeInsets.only(
        top: marginTop,
        bottom: marginBottom,
        left: 16,
        right: 16,
      ),
      height: _getHeight(),
      decoration: BoxDecoration(
        borderRadius: rounded ? BorderRadius.circular(12) : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.casinoPurple.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: rounded ? BorderRadius.circular(12) : BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientCard,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.gradientCard,
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientPurple,
                ),
              ),

            // Overlay gradient - only show when showOverlay is true
            if (showOverlay)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),

            // Content - only show when showOverlay is true
            if (showOverlay)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: _getAlignment(),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            promotion.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size == BannerSize.small ? 14 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: alignment == BannerAlignment.center
                                ? TextAlign.center
                                : null,
                          ),
                          if (promotion.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              promotion.subtitle!,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: size == BannerSize.small ? 12 : 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (showCountdown &&
                              promotion.countdown?.enabled == true &&
                              promotion.countdown?.endTime != null) ...[
                            const SizedBox(height: 8),
                            CountdownTimer(
                              endTime: DateTime.parse(promotion.countdown!.endTime!),
                              compact: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (size != BannerSize.small) ...[
                      const SizedBox(width: 16),
                      GradientButton(
                        text: promotion.ctaText,
                        onPressed: () {
                          // Handle CTA tap
                        },
                      ),
                    ],
                  ],
                ),
              ),

            // Tap handler
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Handle banner tap
                },
                borderRadius: rounded ? BorderRadius.circular(12) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
