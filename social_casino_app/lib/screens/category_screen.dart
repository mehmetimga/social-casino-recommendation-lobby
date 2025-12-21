import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../providers/lobby_provider.dart';
import '../widgets/game/play_modal.dart';
import '../widgets/lobby/game_grid.dart';

class CategoryScreen extends ConsumerWidget {
  final String categorySlug;
  final String title;
  final GameType? gameType;

  const CategoryScreen({
    super.key,
    required this.categorySlug,
    required this.title,
    this.gameType,
  });

  void _onGameTap(BuildContext context, Game game) {
    showPlayModal(context, game);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get games based on game type
    final gamesAsync = gameType != null
        ? ref.watch(gamesByTypeProvider(gameType!))
        : ref.watch(popularGamesProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          gamesAsync.when(
            loading: () => GameGrid(
              games: const [],
              title: title,
              isLoading: true,
            ),
            error: (error, stack) => GameGrid(
              games: const [],
              title: title,
            ),
            data: (games) => GameGrid(
              games: games,
              title: title,
              subtitle: '${games.length} games available',
              onGameTap: (game) => _onGameTap(context, game),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
