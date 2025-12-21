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
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.showProvider = true,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                if (onShowMore != null)
                  TextButton(
                    onPressed: onShowMore,
                    child: const Text('See All'),
                  ),
              ],
            ),
          ),
        if (title != null) const SizedBox(height: 12),
        if (isLoading)
          _buildLoadingGrid()
        else if (games.isEmpty)
          _buildEmptyState(context)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return GameCard(
                  game: game,
                  showProvider: showProvider,
                  showJackpot: showJackpot,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
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
              size: 48,
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

/// Horizontal scrollable game list
class HorizontalGameList extends StatelessWidget {
  final List<Game> games;
  final String? title;
  final String? subtitle;
  final bool isLoading;
  final double cardWidth;
  final double cardHeight;
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
    this.cardWidth = 140,
    this.cardHeight = 180,
    this.showProvider = true,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
                if (onShowMore != null)
                  TextButton(
                    onPressed: onShowMore,
                    child: const Text('See All'),
                  ),
              ],
            ),
          ),
        if (title != null) const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: isLoading
              ? _buildLoadingList()
              : games.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: games.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return GameCard(
                          game: game,
                          width: cardWidth,
                          height: cardHeight,
                          showProvider: showProvider,
                          showJackpot: showJackpot,
                          onTap:
                              onGameTap != null ? () => onGameTap!(game) : null,
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingList() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return GameCardShimmer(width: cardWidth, height: cardHeight);
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
