import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/lobby/lobby_renderer.dart';
import '../widgets/game/play_modal.dart';
import '../models/game.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  void _onGameTap(BuildContext context, Game game) {
    showPlayModal(context, game);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Content is now scrollable, top/bottom bars are handled by MainScaffold
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          LobbyRenderer(
            onGameTap: (game) => _onGameTap(context, game),
          ),
          const SizedBox(height: 100), // Space for chat widget
        ],
      ),
    );
  }
}
