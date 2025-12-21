import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/chat_provider.dart';
import '../common/gradient_button.dart';
import '../game/game_badge.dart';
import 'review_form.dart';

class PlayModal extends ConsumerStatefulWidget {
  final Game game;

  const PlayModal({
    super.key,
    required this.game,
  });

  @override
  ConsumerState<PlayModal> createState() => _PlayModalState();
}

class _PlayModalState extends ConsumerState<PlayModal> {
  bool _showReviewForm = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final percentFormat = NumberFormat.percentPattern();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.casinoBgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CachedNetworkImage(
                            imageUrl: game.heroImage != null
                                ? ApiConfig.getMediaUrl(game.heroImage!.url)
                                : ApiConfig.getMediaUrl(game.thumbnail.url),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.casinoBgSecondary,
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.casinoBgSecondary,
                              child: const Icon(Icons.casino, size: 48),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Badges
                      if (game.badges != null && game.badges!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: game.badges!
                              .map((badge) => GameBadge(badge: badge))
                              .toList(),
                        ),

                      const SizedBox(height: 12),

                      // Title and provider
                      Text(
                        game.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${game.provider}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),

                      const SizedBox(height: 16),

                      // Description
                      if (game.shortDescription != null) ...[
                        Text(
                          game.shortDescription!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Stats grid
                      _buildStatsGrid(context, game, currencyFormat, percentFormat),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: GradientButton(
                              text: 'Play Now',
                              onPressed: () {
                                Navigator.pop(context);
                                // Handle play
                              },
                              icon: Icons.play_arrow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ref.read(chatProvider.notifier).openWithGame(
                                  game.slug,
                                  game.title,
                                );
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Ask'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.casinoPurple,
                                side: const BorderSide(color: AppColors.casinoPurple),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Review section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rate & Review',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _showReviewForm = !_showReviewForm);
                            },
                            icon: Icon(
                              _showReviewForm
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                          ),
                        ],
                      ),

                      if (_showReviewForm) ...[
                        const SizedBox(height: 12),
                        ReviewForm(
                          game: game,
                          onSubmitted: () {
                            setState(() => _showReviewForm = false);
                          },
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    Game game,
    NumberFormat currencyFormat,
    NumberFormat percentFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.casinoBgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Min Bet',
                  '\$${game.minBet.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Max Bet',
                  '\$${game.maxBet.toStringAsFixed(0)}',
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (game.rtp != null)
                Expanded(
                  child: _buildStatItem(
                    context,
                    'RTP',
                    '${game.rtp!.toStringAsFixed(1)}%',
                    Icons.percent,
                  ),
                ),
              if (game.volatility != null)
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Volatility',
                    game.volatility!.name.toUpperCase(),
                    Icons.show_chart,
                  ),
                ),
            ],
          ),
          if (game.jackpotAmount != null && game.jackpotAmount! > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.gradientGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Jackpot: ${currencyFormat.format(game.jackpotAmount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.casinoPurple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.casinoPurple),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Show the play modal
void showPlayModal(BuildContext context, Game game) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PlayModal(game: game),
  );
}
