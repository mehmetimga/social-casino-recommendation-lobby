import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../config/api_config.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/user_provider.dart';
import 'package:intl/intl.dart';

class GameCard extends ConsumerStatefulWidget {
  final Game game;
  final double? width;
  final double? height;
  final bool showProvider;
  final bool showJackpot;
  final bool compact;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.width,
    this.height,
    this.showProvider = false, // Hide by default for cleaner look
    this.showJackpot = true,
    this.compact = false,
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
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                        color: AppColors.casinoGold,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.casinoBgCard,
                    child: const Icon(
                      Icons.casino,
                      color: AppColors.casinoGold,
                      size: 40,
                    ),
                  ),
                ),

                // Gradient overlay for text (subtle)
                if (widget.showProvider)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                // Exclusive / Featured badge
                if (game.badges != null && game.badges!.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _BadgeChip(badge: game.badges!.first.name),
                  ),

                // Jackpot amount
                if (widget.showJackpot &&
                    game.jackpotAmount != null &&
                    game.jackpotAmount! > 0)
                  Positioned(
                    bottom: widget.showProvider ? 36 : 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currencyFormat.format(game.jackpotAmount),
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Game info at bottom (optional)
                if (widget.showProvider)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            game.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            game.provider,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                      splashColor: AppColors.casinoGold.withValues(alpha: 0.2),
                      highlightColor: AppColors.casinoGold.withValues(alpha: 0.1),
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

class _BadgeChip extends StatelessWidget {
  final String badge;

  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    // Determine badge style based on type
    Color bgColor;
    Color textColor;
    String displayText;

    switch (badge.toLowerCase()) {
      case 'exclusive':
        bgColor = AppColors.textDark.withValues(alpha: 0.85);
        textColor = Colors.white;
        displayText = 'Exclusive';
        break;
      case 'newbadge':
      case 'new':
        bgColor = AppColors.casinoGreen;
        textColor = Colors.white;
        displayText = 'New';
        break;
      case 'hot':
        bgColor = AppColors.casinoRed;
        textColor = Colors.white;
        displayText = 'Hot';
        break;
      case 'jackpot':
        bgColor = AppColors.casinoGold;
        textColor = AppColors.textDark;
        displayText = 'Jackpot';
        break;
      case 'featured':
        bgColor = AppColors.casinoGold;
        textColor = AppColors.textDark;
        displayText = 'Featured';
        break;
      default:
        bgColor = AppColors.textDark.withValues(alpha: 0.85);
        textColor = Colors.white;
        displayText = _formatBadgeText(badge);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _formatBadgeText(String badge) {
    return badge[0].toUpperCase() + badge.substring(1).toLowerCase();
  }
}
