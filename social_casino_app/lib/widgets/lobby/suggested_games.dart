import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game.dart';
import '../../models/lobby_layout.dart';
import '../../providers/lobby_provider.dart';
import 'game_grid.dart';

class SuggestedGames extends ConsumerWidget {
  final SuggestedGamesSectionBlock section;
  final Function(Game game)? onGameTap;

  const SuggestedGames({
    super.key,
    required this.section,
    this.onGameTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For manual mode, use the manually selected games
    if (section.mode == SuggestedMode.manual && section.manualGames != null) {
      return HorizontalGameList(
        games: section.manualGames!,
        title: section.title,
        subtitle: section.subtitle,
        showProvider: true,
        showJackpot: true,
        onGameTap: onGameTap,
      );
    }

    // For personalized mode, fetch recommendations
    final recommendationsAsync = ref.watch(recommendationsProvider(section.limit));

    return recommendationsAsync.when(
      loading: () => HorizontalGameList(
        games: const [],
        title: section.title,
        subtitle: section.subtitle,
        isLoading: true,
        onGameTap: onGameTap,
      ),
      error: (error, stack) => _buildFallback(ref),
      data: (games) {
        if (games.isEmpty && section.fallbackToPopular) {
          return _buildFallback(ref);
        }
        return HorizontalGameList(
          games: games,
          title: section.title,
          subtitle: section.subtitle,
          showProvider: true,
          showJackpot: true,
          onGameTap: onGameTap,
        );
      },
    );
  }

  Widget _buildFallback(WidgetRef ref) {
    final popularGamesAsync = ref.watch(popularGamesProvider);

    return popularGamesAsync.when(
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
      data: (games) => HorizontalGameList(
        games: games.take(section.limit).toList(),
        title: section.title,
        subtitle: section.subtitle,
        showProvider: true,
        showJackpot: true,
        onGameTap: onGameTap,
      ),
    );
  }
}
