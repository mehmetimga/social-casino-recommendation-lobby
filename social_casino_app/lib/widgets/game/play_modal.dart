import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/api_config.dart';
import '../../config/routes.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/chat_provider.dart';
import '../common/gradient_button.dart';
import '../game/game_badge.dart';
import 'game_play_dialog.dart';
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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleReviewForm() {
    setState(() => _showReviewForm = !_showReviewForm);
    if (!_showReviewForm) return;

    // Scroll to review section after animation
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_reviewKey.currentContext != null) {
        Scrollable.ensureVisible(
          _reviewKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.casinoBg,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Minimal safe area bar
          Container(
            color: AppColors.casinoBg,
            height: MediaQuery.of(context).padding.top,
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image with close button overlay
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: game.heroImage != null
                                  ? ApiConfig.getMediaUrl(game.heroImage!.url)
                                  : ApiConfig.getMediaUrl(game.thumbnail.url),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.casinoBgSecondary,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.casinoGold,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.casinoBgSecondary,
                                child: const Icon(Icons.casino, size: 48, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        // Close button on top right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

              // Content padding
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${game.provider}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.casinoPurple,
                          ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    if (game.shortDescription != null) ...[
                      Text(
                        game.shortDescription!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stats grid
                    _buildStatsGrid(context, game, currencyFormat),

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
                              // Open game play dialog with time tracking
                              showGamePlayDialog(context, game);
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

                    const SizedBox(height: 24),

                    // Review section
                    Container(
                      key: _reviewKey,
                      decoration: BoxDecoration(
                        color: AppColors.casinoBgSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Review header
                          InkWell(
                            onTap: _toggleReviewForm,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.casinoGold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.star_outline,
                                          size: 20,
                                          color: AppColors.casinoGold,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Rate & Review',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    _showReviewForm
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Review form (expandable)
                          AnimatedCrossFade(
                            firstChild: const SizedBox.shrink(),
                            secondChild: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: ReviewForm(
                                game: game,
                                onSubmitted: () {
                                  setState(() => _showReviewForm = false);
                                },
                              ),
                            ),
                            crossFadeState: _showReviewForm
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    ),

                    // Extra padding at bottom for keyboard
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 200 : 40),
                  ],
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

  Widget _buildStatsGrid(
    BuildContext context,
    Game game,
    NumberFormat currencyFormat,
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

/// Show the play modal as a full-screen page using root navigator
void showPlayModal(BuildContext context, Game game) {
  rootNavigatorKey.currentState?.push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => PlayModal(game: game),
    ),
  );
}
