import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';
import '../../config/theme/app_colors.dart';
import '../../models/game.dart';
import '../../providers/user_provider.dart';

class GamePlayDialog extends ConsumerStatefulWidget {
  final Game game;

  const GamePlayDialog({
    super.key,
    required this.game,
  });

  @override
  ConsumerState<GamePlayDialog> createState() => _GamePlayDialogState();
}

class _GamePlayDialogState extends ConsumerState<GamePlayDialog> {
  late DateTime _playStartTime;

  @override
  void initState() {
    super.initState();
    _playStartTime = DateTime.now();
    debugPrint('Started tracking play time for: ${widget.game.slug}');
  }

  void _handleClose() {
    // Calculate play duration in seconds
    final duration = DateTime.now().difference(_playStartTime).inSeconds;
    debugPrint('Tracking game_time for: ${widget.game.slug}, duration: $duration seconds');

    // Track game_time event
    ref.read(userProvider.notifier).trackGameTime(widget.game.slug, duration);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final imageUrl = game.heroImage?.url ?? game.thumbnail.url;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game image - full screen
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: ApiConfig.getMediaUrl(imageUrl),
                fit: BoxFit.contain,
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
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🎰', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 8),
                        Text(
                          'No image available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _handleClose,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Game title overlay at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black,
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                48,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.provider,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Demo mode indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: AppColors.casinoGold,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Demo Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
}

/// Show the game play dialog
Future<void> showGamePlayDialog(BuildContext context, Game game) async {
  await Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => GamePlayDialog(game: game),
    ),
  );
}
