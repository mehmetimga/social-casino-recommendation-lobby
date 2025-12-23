import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat.dart';
import 'services_provider.dart';
import 'user_provider.dart';

/// Chat UI state
class ChatState {
  final ChatSession? session;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isOpen;
  final bool isMaximized;
  final ChatContext? context;
  final String? error;

  const ChatState({
    this.session,
    this.messages = const [],
    this.isLoading = false,
    this.isOpen = false,
    this.isMaximized = false,
    this.context,
    this.error,
  });

  ChatState copyWith({
    ChatSession? session,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isOpen,
    bool? isMaximized,
    ChatContext? context,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isOpen: isOpen ?? this.isOpen,
      isMaximized: isMaximized ?? this.isMaximized,
      context: context ?? this.context,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Chat notifier for managing chat state
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref) : super(const ChatState());

  /// Open the chat widget
  void openChat() {
    state = state.copyWith(isOpen: true, clearError: true);
  }

  /// Close the chat widget
  void closeChat() {
    state = state.copyWith(isOpen: false);
  }

  /// Toggle chat open/closed
  void toggleChat() {
    state = state.copyWith(isOpen: !state.isOpen, clearError: true);
  }

  /// Toggle maximize/minimize
  void toggleMaximize() {
    state = state.copyWith(isMaximized: !state.isMaximized);
  }

  /// Set the chat context (current game, page, etc.)
  void setContext(ChatContext context) {
    state = state.copyWith(context: context);
  }

  /// Send a message and get AI response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userState = _ref.read(userProvider);
    final chatService = _ref.read(chatServiceProvider);

    // Create session if needed
    if (state.session == null) {
      state = state.copyWith(isLoading: true, clearError: true);

      try {
        // Include vipLevel in context when creating session
        final contextWithVip = state.context != null
            ? state.context!.copyWith(vipLevel: userState.vipLevel.name)
            : ChatContext(vipLevel: userState.vipLevel.name);

        final session = await chatService.createSession(
          userId: userState.userId,
          context: contextWithVip,
        );
        state = state.copyWith(session: session, context: contextWithVip);
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to start chat session',
        );
        return;
      }
    }

    // Add user message to UI immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: state.session!.id,
      role: MessageRole.user,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    // Send to API and get response
    try {
      final response = await chatService.sendMessage(state.session!.id, content);

      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: state.session!.id,
        role: MessageRole.assistant,
        content: response.content,
        citations: response.citations,
        createdAt: DateTime.now().toIso8601String(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get response',
      );
    }
  }

  /// Clear chat history and session
  void clearChat() {
    state = const ChatState();
  }

  /// Open chat with a specific game context
  /// Updates context without clearing chat history
  Future<void> openWithGame(String gameSlug, String gameTitle) async {
    final userState = _ref.read(userProvider);
    final newContext = ChatContext(
      currentPage: 'game',
      currentGame: gameTitle,
      gameSlug: gameSlug,
      vipLevel: userState.vipLevel.name,
    );

    // Update local context state
    state = state.copyWith(context: newContext, isOpen: true);

    // If session exists, update the context on the server
    if (state.session != null) {
      try {
        final chatService = _ref.read(chatServiceProvider);
        await chatService.updateContext(state.session!.id, newContext);
      } catch (e) {
        // Log error but don't fail - context will be used on next message
        debugPrint('Failed to update chat context: $e');
      }
    }
  }
}

/// Chat provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
