import 'package:flutter/material.dart';
import '../../models/game.dart';
import '../../config/theme/app_colors.dart';
import '../common/loading_shimmer.dart';
import 'game_card.dart';

class GameGrid extends StatelessWidget {
  final List<Game> games;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool showProvider;
  final bool showJackpot;
  final VoidCallback? onShowMore;
  final Function(Game game)? onGameTap;

  const GameGrid({
    super.key,
    required this.games,
    this.title,
    this.subtitle,
    this.isLoading = false,
    this.crossAxisCount = 3, // 3 columns
    this.childAspectRatio = 1.0, // Square aspect ratio
    this.showProvider = false,
    this.showJackpot = true,
    this.onShowMore,
    this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionHeader(
              title: title!,
              subtitle: subtitle,
              onShowMore: onShowMore,
            ),
          ),
        if (title != null) const SizedBox(height: 12),
        if (isLoading)
          _buildLoadingGrid()
        else if (games.isEmpty)
          _buildEmptyState(context)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameCard(
                  game: game,
                  showProvider: showProvider,
                  showJackpot: showJackpot,
                  compact: true,
                  onTap: onGameTap != null ? () => onGameTap!(game) : null,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9, // 3x3 grid
        itemBuilder: (context, index) {
          return const GameCardShimmer();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.casino_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No games available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable game list with 3-item visible grid
class HorizontalGameList extends StatelessWidget {
  final List<Game> games;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final double? cardWidth;
  final double? cardHeight;
  final bool showProvider;
  final bool showJackpot;
  final VoidCallback? onShowMore;
  final Function(Game game)? onGameTap;

  const HorizontalGameList({
    super.key,
    required this.games,
    this.title,
    this.subtitle,
    this.isLoading = false,
    this.cardWidth,
    this.cardHeight,
    this.showProvider = false,
    this.showJackpot = true,
    this.onShowMore,
    this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate card size based on screen width to show ~3 items
    final screenWidth = MediaQuery.of(context).size.width;
    final calculatedWidth = cardWidth ?? ((screenWidth - 40) / 3);
    final calculatedHeight = cardHeight ?? calculatedWidth; // Square

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SectionHeader(
              title: title!,
              subtitle: subtitle,
              onShowMore: onShowMore ?? () {},
            ),
          ),
        if (title != null) const SizedBox(height: 12),
        SizedBox(
          height: calculatedHeight,
          child: isLoading
              ? _buildLoadingList(calculatedWidth, calculatedHeight)
              : games.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: games.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return GameCard(
                          game: game,
                          width: calculatedWidth,
                          height: calculatedHeight,
                          showProvider: showProvider,
                          showJackpot: showJackpot,
                          compact: true,
                          onTap: onGameTap != null ? () => onGameTap!(game) : null,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingList(double width, double height) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        return GameCardShimmer(width: width, height: height);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No games available',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}

/// Section header with title and "See All" button
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onShowMore;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onShowMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onShowMore != null)
          GestureDetector(
            onTap: onShowMore,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.casinoGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.casinoGold,
                  size: 18,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
