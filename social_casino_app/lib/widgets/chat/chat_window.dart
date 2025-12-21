import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import 'message_bubble.dart';
import 'chat_input.dart';

class ChatWindow extends ConsumerStatefulWidget {
  const ChatWindow({super.key});

  @override
  ConsumerState<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends ConsumerState<ChatWindow> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    // Scroll to bottom when new messages arrive
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.casinoBgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context, chatState, chatNotifier),

          // Context indicator
          if (chatState.context?.currentGame != null)
            _buildContextBanner(chatState.context!.currentGame!),

          // Messages area
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(chatState),
          ),

          // Error banner
          if (chatState.error != null) _buildErrorBanner(chatState.error!),

          // Input
          ChatInput(
            onSend: (message) => chatNotifier.sendMessage(message),
            isLoading: chatState.isLoading,
            placeholder: chatState.context?.currentGame != null
                ? 'Ask about ${chatState.context!.currentGame}...'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ChatState chatState,
    ChatNotifier chatNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.casinoBgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPurple,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Casino Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  chatState.isLoading ? 'Typing...' : 'Online',
                  style: TextStyle(
                    color: chatState.isLoading
                        ? AppColors.casinoGold
                        : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Toggle maximize
          IconButton(
            onPressed: () => chatNotifier.toggleMaximize(),
            icon: Icon(
              chatState.isMaximized
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
              color: AppColors.textMuted,
            ),
            tooltip: chatState.isMaximized ? 'Minimize' : 'Maximize',
          ),
          // Clear chat
          if (chatState.messages.isNotEmpty)
            IconButton(
              onPressed: () => _showClearConfirmation(context, chatNotifier),
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.textMuted,
              ),
              tooltip: 'Clear chat',
            ),
          // Close button
          IconButton(
            onPressed: () => chatNotifier.closeChat(),
            icon: const Icon(
              Icons.close,
              color: AppColors.textMuted,
            ),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildContextBanner(String gameName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.casinoPurple.withValues(alpha: 0.2),
      child: Row(
        children: [
          const Icon(
            Icons.casino,
            size: 16,
            color: AppColors.casinoPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Asking about: $gameName',
              style: const TextStyle(
                color: AppColors.casinoPurple,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.casinoPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: AppColors.casinoPurple,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start a conversation',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about games,\npromotions, or recommendations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'Show me popular slots',
      'What games have jackpots?',
      'High RTP games',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () {
            ref.read(chatProvider.notifier).sendMessage(suggestion);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.casinoBgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.casinoPurple.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Text(
              suggestion,
              style: const TextStyle(
                color: AppColors.casinoPurple,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isLoading) {
          return _buildTypingIndicator();
        }
        return MessageBubble(message: chatState.messages[index]);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.casinoGold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 18,
              color: AppColors.casinoGold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.casinoBgSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.casinoAccent.withValues(alpha: 0.2),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: AppColors.casinoAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: AppColors.casinoAccent,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(chatProvider.notifier).clearChat();
            },
            child: const Text(
              'Retry',
              style: TextStyle(
                color: AppColors.casinoAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, ChatNotifier chatNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.casinoBgCard,
        title: const Text(
          'Clear Chat',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to clear the chat history?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              chatNotifier.clearChat();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.casinoAccent),
            ),
          ),
        ],
      ),
    );
  }
}
