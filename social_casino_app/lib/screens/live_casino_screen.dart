import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../providers/lobby_provider.dart';
import '../widgets/game/play_modal.dart';
import '../widgets/lobby/game_grid.dart';

class LiveCasinoScreen extends ConsumerWidget {
  const LiveCasinoScreen({super.key});

  void _onGameTap(BuildContext context, Game game) {
    showPlayModal(context, game);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesByTypeProvider(GameType.live));

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          gamesAsync.when(
            loading: () => const GameGrid(
              games: [],
              title: 'Live Dealer Games',
              isLoading: true,
            ),
            error: (error, stack) => const GameGrid(
              games: [],
              title: 'Live Dealer Games',
            ),
            data: (games) => GameGrid(
              games: games,
              title: 'Live Dealer Games',
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
