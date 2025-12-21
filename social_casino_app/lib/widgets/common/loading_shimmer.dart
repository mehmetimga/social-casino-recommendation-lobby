import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.casinoBgCard,
      highlightColor: AppColors.casinoBgSecondary,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.casinoBgCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class GameCardShimmer extends StatelessWidget {
  final double width;
  final double height;

  const GameCardShimmer({
    super.key,
    this.width = 160,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.casinoBgCard,
      highlightColor: AppColors.casinoBgSecondary,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.casinoBgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.casinoBgSecondary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: width * 0.7,
                    color: AppColors.casinoBgSecondary,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 10,
                    width: width * 0.5,
                    color: AppColors.casinoBgSecondary,
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

class CarouselShimmer extends StatelessWidget {
  final double height;

  const CarouselShimmer({
    super.key,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.casinoBgCard,
      highlightColor: AppColors.casinoBgSecondary,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.casinoBgCard,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
