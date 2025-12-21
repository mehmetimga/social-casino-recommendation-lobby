import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game.dart';
import '../providers/lobby_provider.dart';
import '../widgets/layout/app_header.dart';
import '../widgets/lobby/game_grid.dart';

class TableGamesScreen extends ConsumerWidget {
  const TableGamesScreen({super.key});

  void _onGameTap(BuildContext context, Game game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickGameInfo(context, game),
    );
  }

  Widget _buildQuickGameInfo(BuildContext context, Game game) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Color(0xFF16162A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${game.provider}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (game.shortDescription != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      game.shortDescription!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Play Now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesByTypeProvider(GameType.table));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: AppHeader(title: 'Table Games'),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: gamesAsync.when(
              loading: () => const GameGrid(
                games: [],
                title: 'All Table Games',
                isLoading: true,
              ),
              error: (error, stack) => const GameGrid(
                games: [],
                title: 'All Table Games',
              ),
              data: (games) => GameGrid(
                games: games,
                title: 'All Table Games',
                subtitle: '${games.length} games available',
                onGameTap: (game) => _onGameTap(context, game),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}
