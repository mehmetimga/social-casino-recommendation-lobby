import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final bool showOverlay; // Show text and button overlay on banners

  const HeroCarousel({
    super.key,
    required this.promotions,
    this.autoPlay = true,
    this.autoPlayInterval = 3000,
    this.showDots = true,
    this.showArrows = false, // Hidden by default for cleaner look
    this.height = CarouselHeight.medium,
    this.isLoading = false,
    this.showOverlay = false, // Hide text/button by default
  });

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.autoPlay && widget.promotions.length > 1) {
      _autoPlayTimer = Timer.periodic(
        Duration(milliseconds: widget.autoPlayInterval),
        (_) => _nextPage(),
      );
    }
  }

  void _nextPage() {
    if (!mounted || widget.promotions.isEmpty) return;
    final nextIndex = (_currentIndex + 1) % widget.promotions.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  double _getHeight() {
    // Heights matching CMS values (adjusted for mobile)
    switch (widget.height) {
      case CarouselHeight.small:
        return 150;
      case CarouselHeight.medium:
        return 200;
      case CarouselHeight.large:
        return 250; // CMS says 500px but we scale for mobile
      case CarouselHeight.full:
        return 300;
    }
  }

  void _previousPage() {
    if (!mounted || widget.promotions.isEmpty) return;
    final prevIndex = (_currentIndex - 1 + widget.promotions.length) % widget.promotions.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
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
        SizedBox(
          height: _getHeight(),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.promotions.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildSlide(widget.promotions[index]),
                    ),
                  );
                },
              ),
              // Navigation arrows
              if (widget.showArrows && widget.promotions.length > 1) ...[
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      icon: Icons.chevron_left,
                      onTap: _previousPage,
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      icon: Icons.chevron_right,
                      onTap: _nextPage,
                    ),
                  ),
                ),
              ],
            ],
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

    return Stack(
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

        // Gradient overlay for text readability (only if showing overlay)
        if (widget.showOverlay)
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

        // Content (only if showing overlay)
        if (widget.showOverlay)
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
    );
  }
}

/// Arrow button for carousel navigation
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
