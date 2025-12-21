import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../config/api_config.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/user_provider.dart';
import '../game/game_badge.dart';
import 'package:intl/intl.dart';

class GameCard extends ConsumerStatefulWidget {
  final Game game;
  final double width;
  final double height;
  final bool showProvider;
  final bool showJackpot;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.width = 160,
    this.height = 200,
    this.showProvider = true,
    this.showJackpot = true,
    this.onTap,
  });

  @override
  ConsumerState<GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<GameCard> {
  bool _hasTrackedImpression = false;

  void _trackImpression() {
    if (!_hasTrackedImpression) {
      _hasTrackedImpression = true;
      ref.read(userProvider.notifier).trackImpression(widget.game.slug);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final thumbnailUrl = ApiConfig.getMediaUrl(game.thumbnail.url);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return VisibilityDetector(
      key: Key('game-card-${game.slug}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= 0.5) {
          _trackImpression();
        }
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail image
                CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.casinoBgCard,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.casinoPurple,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.casinoBgCard,
                    child: const Icon(
                      Icons.casino,
                      color: AppColors.casinoPurple,
                      size: 48,
                    ),
                  ),
                ),

                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Badges
                if (game.badges != null && game.badges!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: game.badges!
                          .take(2)
                          .map((badge) => GameBadge(badge: badge, small: true))
                          .toList(),
                    ),
                  ),

                // Jackpot amount
                if (widget.showJackpot &&
                    game.jackpotAmount != null &&
                    game.jackpotAmount! > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientGold,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: AppColors.goldShadow,
                      ),
                      child: Text(
                        currencyFormat.format(game.jackpotAmount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Game info at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          game.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.showProvider) ...[
                          const SizedBox(height: 2),
                          Text(
                            game.provider,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Play button overlay on hover/tap
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(12),
                      splashColor: AppColors.casinoPurple.withValues(alpha: 0.3),
                      highlightColor: AppColors.casinoPurple.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
