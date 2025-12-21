import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../config/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (interactive) {
      return RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: size,
        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: AppColors.casinoGold,
        ),
        unratedColor: AppColors.textMuted.withValues(alpha: 0.3),
        onRatingUpdate: onRatingChanged ?? (_) {},
      );
    }

    return RatingBarIndicator(
      rating: rating,
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: AppColors.casinoGold,
      ),
      itemCount: 5,
      itemSize: size,
      unratedColor: AppColors.textMuted.withValues(alpha: 0.3),
    );
  }
}
