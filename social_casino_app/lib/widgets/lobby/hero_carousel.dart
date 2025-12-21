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
    this.showArrows = true,
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
        return 160;
      case CarouselHeight.medium:
        return 200;
      case CarouselHeight.large:
        return 260;
      case CarouselHeight.full:
        return 320;
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
        Stack(
          children: [
            CarouselSlider(
              carouselController: _controller,
              items: widget.promotions.map((promo) => _buildSlide(promo)).toList(),
              options: CarouselOptions(
                height: _getHeight(),
                viewportFraction: 0.92,
                enlargeCenterPage: true,
                autoPlay: widget.autoPlay,
                autoPlayInterval: Duration(milliseconds: widget.autoPlayInterval),
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
            if (widget.showArrows && widget.promotions.length > 1) ...[
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildArrowButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _controller.previousPage(),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildArrowButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _controller.nextPage(),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (widget.showDots && widget.promotions.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.promotions.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? AppColors.casinoPurple
                        : AppColors.casinoPurple.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSlide(Promotion promo) {
    final imageUrl = promo.backgroundImage != null
        ? ApiConfig.getMediaUrl(promo.backgroundImage!.url)
        : promo.image != null
            ? ApiConfig.getMediaUrl(promo.image!.url)
            : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
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
                  color: AppColors.casinoBgCard,
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.casinoBgCard,
                  child: const Icon(
                    Icons.image,
                    color: AppColors.casinoPurple,
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

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
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
                  // Countdown timer
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
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
                    icon: Icons.play_arrow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
