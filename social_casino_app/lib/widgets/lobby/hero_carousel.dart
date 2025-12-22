import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../config/api_config.dart';
import '../../config/theme/app_colors.dart';
import '../../models/promotion.dart';
import '../../models/lobby_layout.dart';
import '../common/loading_shimmer.dart';
import '../common/gradient_button.dart';
import 'countdown_timer.dart';

class HeroCarousel extends StatefulWidget {
  final List<Promotion> promotions;
  final bool autoPlay;
  final int autoPlayInterval;
  final bool showDots;
  final bool showArrows;
  final CarouselHeight height;
  final bool isLoading;

  const HeroCarousel({
    super.key,
    required this.promotions,
    this.autoPlay = true,
    this.autoPlayInterval = 5000,
    this.showDots = true,
    this.showArrows = false, // Hidden by default for cleaner look
    this.height = CarouselHeight.medium,
    this.isLoading = false,
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  double _getHeight() {
    switch (widget.height) {
      case CarouselHeight.small:
        return 140;
      case CarouselHeight.medium:
        return 180;
      case CarouselHeight.large:
        return 220;
      case CarouselHeight.full:
        return 280;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return CarouselShimmer(height: _getHeight());
    }

    if (widget.promotions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: _getHeight(),
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.92),
              itemCount: widget.promotions.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildSlide(widget.promotions[index]),
                );
              },
            ),
          ),
        ),
        if (widget.showDots && widget.promotions.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildDotIndicators(),
          ),
      ],
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.promotions.length,
        (index) {
          final isActive = _currentIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? AppColors.textPrimary
                  : AppColors.textMuted.withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlide(Promotion promo) {
    final imageUrl = promo.backgroundImage != null
        ? ApiConfig.getMediaUrl(promo.backgroundImage!.url)
        : promo.image != null
            ? ApiConfig.getMediaUrl(promo.image!.url)
            : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientCard,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientCard,
                  ),
                  child: const Icon(
                    Icons.casino,
                    color: AppColors.casinoGold,
                    size: 48,
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientCard,
                ),
              ),

            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Countdown timer (if enabled)
                  if (promo.countdown?.enabled == true &&
                      promo.countdown?.endTime != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CountdownTimer(
                        endTime: DateTime.parse(promo.countdown!.endTime!),
                        label: promo.countdown?.label,
                        compact: true,
                      ),
                    ),

                  // Title
                  Text(
                    promo.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Subtitle
                  if (promo.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      promo.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // CTA Button
                  GradientButton(
                    text: promo.ctaText,
                    onPressed: () {
                      // Handle CTA tap
                    },
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
