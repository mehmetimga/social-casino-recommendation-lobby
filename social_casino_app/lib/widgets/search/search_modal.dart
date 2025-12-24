import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/lobby_provider.dart';
import '../lobby/game_card.dart';
import '../game/play_modal.dart';

class SearchModal extends ConsumerStatefulWidget {
  final GameType? gameType;

  const SearchModal({super.key, this.gameType});

  @override
  ConsumerState<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends ConsumerState<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPlaceholder() {
    switch (widget.gameType) {
      case GameType.slot:
        return 'Search slots...';
      case GameType.live:
        return 'Search live casino...';
      case GameType.table:
        return 'Search table games...';
      case GameType.instant:
        return 'Search instant win...';
      default:
        return 'Search all games...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.casinoBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.pillBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: _getPlaceholder(),
                        hintStyle: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.casinoGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Search results
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildRecentSearches()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Searches',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip('Slots'),
              _buildSearchChip('Blackjack'),
              _buildSearchChip('Roulette'),
              _buildSearchChip('Jackpot'),
              _buildSearchChip('Live Casino'),
              _buildSearchChip('Table Games'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        setState(() => _searchQuery = text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pillBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchQuery = SearchQuery(query: _searchQuery, type: widget.gameType);
    final gamesAsync = ref.watch(searchGamesProvider(searchQuery));

    return gamesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.casinoGold),
      ),
      error: (error, stack) => Center(
        child: Text(
          'Error searching games',
          style: TextStyle(color: AppColors.textMuted),
        ),
      ),
      data: (games) {
        if (games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'No games found for "$_searchQuery"',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return GameCard(
              game: game,
              compact: true,
              onTap: () {
                Navigator.of(context).pop();
                showPlayModal(context, game);
              },
            );
          },
        );
      },
    );
  }
}

void showSearchModal(BuildContext context, {GameType? gameType}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SearchModal(gameType: gameType),
  );
}
