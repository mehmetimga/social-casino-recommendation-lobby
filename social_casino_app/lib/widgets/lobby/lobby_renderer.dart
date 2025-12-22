import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game.dart';
import '../../models/lobby_layout.dart';
import '../../providers/lobby_provider.dart';
import '../common/loading_shimmer.dart';
import 'hero_carousel.dart';
import 'game_grid.dart';
import 'suggested_games.dart';
import 'promotion_banner.dart';

class LobbyRenderer extends ConsumerWidget {
  final String? layoutSlug;
  final Function(Game game)? onGameTap;

  const LobbyRenderer({
    super.key,
    this.layoutSlug,
    this.onGameTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use current layout from CMS category selection, or specific slug, or default
    final layoutAsync = layoutSlug != null
        ? ref.watch(lobbyLayoutBySlugProvider(layoutSlug!))
        : ref.watch(currentLobbyLayoutProvider);

    return layoutAsync.when(
      loading: () => _buildLoadingSkeleton(),
      error: (error, stack) => _buildErrorState(context, error),
      data: (layout) {
        if (layout == null) {
          return _buildEmptyState(context);
        }
        return _buildLayout(context, ref, layout);
      },
    );
  }

  Widget _buildLayout(BuildContext context, WidgetRef ref, LobbyLayout layout) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: layout.sections.length,
      itemBuilder: (context, index) {
        final section = layout.sections[index];
        // Add smaller top padding for first section (carousel), more spacing between other sections
        final isFirstSection = index == 0;
        return Padding(
          padding: EdgeInsets.only(
            top: isFirstSection ? 8 : 16,
            bottom: isFirstSection ? 0 : 8,
          ),
          child: _buildSection(context, ref, section),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, WidgetRef ref, LobbySectionBlock section) {
    return switch (section) {
      CarouselSection s => _buildCarouselSection(ref, s.data),
      GameGridSection s => _buildGameGridSection(ref, s.data),
      SuggestedGamesSection s => SuggestedGames(section: s.data, onGameTap: onGameTap),
      BannerSection s => _buildBannerSection(s.data),
    };
  }

  Widget _buildCarouselSection(WidgetRef ref, CarouselSectionBlock section) {
    // If promotions are already loaded in the section, use them
    if (section.promotions != null && section.promotions!.isNotEmpty) {
      return HeroCarousel(
        promotions: section.promotions!,
        autoPlay: section.autoPlay,
        autoPlayInterval: section.autoPlayInterval,
        showDots: section.showDots,
        showArrows: section.showArrows,
        height: section.height,
      );
    }

    // Otherwise fetch hero promotions
    final promotionsAsync = ref.watch(heroPromotionsProvider);

    return promotionsAsync.when(
      loading: () => HeroCarousel(
        promotions: const [],
        isLoading: true,
        height: section.height,
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (promotions) => HeroCarousel(
        promotions: promotions,
        autoPlay: section.autoPlay,
        autoPlayInterval: section.autoPlayInterval,
        showDots: section.showDots,
        showArrows: section.showArrows,
        height: section.height,
      ),
    );
  }

  Widget _buildGameGridSection(WidgetRef ref, GameGridSectionBlock section) {
    // Get games based on filter type
    final gamesAsync = _getGamesForFilter(ref, section);

    return gamesAsync.when(
      loading: () => HorizontalGameList(
        games: const [],
        title: section.title,
        subtitle: section.subtitle,
        isLoading: true,
        onGameTap: onGameTap,
      ),
      error: (error, stack) => HorizontalGameList(
        games: const [],
        title: section.title,
        subtitle: section.subtitle,
        onGameTap: onGameTap,
      ),
      data: (games) => _buildGameGridContent(section, games),
    );
  }

  Widget _buildGameGridContent(GameGridSectionBlock section, List<Game> games) {
    final limitedGames = games.take(section.limit).toList();

    // Handle different display styles
    switch (section.displayStyle) {
      case DisplayStyle.horizontal:
        return HorizontalGameList(
          games: limitedGames,
          title: section.title,
          subtitle: section.subtitle,
          showProvider: section.showProvider,
          showJackpot: section.showJackpot,
          onGameTap: onGameTap,
        );

      case DisplayStyle.grid:
        // Calculate number of games based on rows and columns (default 3 columns on mobile)
        final columns = int.tryParse(section.columns) ?? 3;
        final gridGames = limitedGames.take(section.rows * columns).toList();
        return GameGrid(
          games: gridGames,
          title: section.title,
          subtitle: section.subtitle,
          crossAxisCount: columns > 4 ? 3 : columns, // Cap at 3 for mobile
          showProvider: section.showProvider,
          showJackpot: section.showJackpot,
          onGameTap: onGameTap,
        );

      case DisplayStyle.carouselRows:
        // Multiple rows that scroll together horizontally
        return CarouselRowsLayout(
          games: limitedGames,
          rows: section.rows,
          title: section.title,
          subtitle: section.subtitle,
          showProvider: section.showProvider,
          showJackpot: section.showJackpot,
          onGameTap: onGameTap,
        );

      case DisplayStyle.singleRow:
        // Single row with no scroll - use grid with 1 row
        final columns = int.tryParse(section.columns) ?? 3;
        final rowGames = limitedGames.take(columns > 4 ? 3 : columns).toList();
        return GameGrid(
          games: rowGames,
          title: section.title,
          subtitle: section.subtitle,
          crossAxisCount: rowGames.length,
          showProvider: section.showProvider,
          showJackpot: section.showJackpot,
          onGameTap: onGameTap,
        );

      case DisplayStyle.featuredLeft:
      case DisplayStyle.featuredRight:
      case DisplayStyle.featuredTop:
        // Get featured game - either from section or first game
        final featuredGame = section.featuredGame ?? (limitedGames.isNotEmpty ? limitedGames.first : null);
        if (featuredGame == null) {
          return HorizontalGameList(
            games: limitedGames,
            title: section.title,
            subtitle: section.subtitle,
            showProvider: section.showProvider,
            showJackpot: section.showJackpot,
            onGameTap: onGameTap,
          );
        }

        // Filter out featured game from others
        final otherGames = limitedGames.where((g) => g.id != featuredGame.id).toList();

        return FeaturedGameLayout(
          featuredGame: featuredGame,
          otherGames: otherGames,
          style: section.displayStyle,
          title: section.title,
          subtitle: section.subtitle,
          showProvider: section.showProvider,
          showJackpot: section.showJackpot,
          onGameTap: onGameTap,
        );
    }
  }

  AsyncValue<List<Game>> _getGamesForFilter(WidgetRef ref, GameGridSectionBlock section) {
    switch (section.filterType) {
      case FilterType.manual:
        if (section.manualGames != null) {
          return AsyncValue.data(section.manualGames!);
        }
        return const AsyncValue.data([]);

      case FilterType.type:
        if (section.gameType != null) {
          final type = GameType.values.firstWhere(
            (t) => t.name == section.gameType,
            orElse: () => GameType.slot,
          );
          return ref.watch(gamesByTypeProvider(type));
        }
        return ref.watch(popularGamesProvider);

      case FilterType.tag:
        if (section.tag != null) {
          return ref.watch(gamesByBadgeProvider(section.tag!));
        }
        return ref.watch(popularGamesProvider);

      case FilterType.popular:
        return ref.watch(popularGamesProvider);

      case FilterType.newGames:
        return ref.watch(newGamesProvider);

      case FilterType.jackpot:
        return ref.watch(jackpotGamesProvider);

      case FilterType.featured:
        return ref.watch(gamesByBadgeProvider('featured'));
    }
  }

  Widget _buildBannerSection(BannerSectionBlock section) {
    if (section.promotion == null) {
      return const SizedBox.shrink();
    }

    return PromotionBanner(
      promotion: section.promotion!,
      size: section.size,
      alignment: section.alignment,
      showCountdown: section.showCountdown,
      rounded: section.rounded,
      marginTop: section.marginTop.toDouble(),
      marginBottom: section.marginBottom.toDouble(),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        const CarouselShimmer(height: 200),
        const SizedBox(height: 24),
        HorizontalGameList(
          games: const [],
          title: 'Loading...',
          isLoading: true,
        ),
        const SizedBox(height: 24),
        HorizontalGameList(
          games: const [],
          title: 'Loading...',
          isLoading: true,
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load lobby',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.casino_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No layout configured',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
