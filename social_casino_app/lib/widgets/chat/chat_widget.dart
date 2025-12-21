import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import 'chat_window.dart';

class ChatWidget extends ConsumerWidget {
  const ChatWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final chatNotifier = ref.read(chatProvider.notifier);

    return Stack(
      children: [
        // Chat window overlay
        if (chatState.isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => chatNotifier.closeChat(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ),

        // Chat window
        if (chatState.isOpen)
          Positioned(
            left: chatState.isMaximized ? 0 : 16,
            right: chatState.isMaximized ? 0 : 16,
            bottom: chatState.isMaximized ? 0 : 80,
            top: chatState.isMaximized ? 0 : null,
            height: chatState.isMaximized
                ? null
                : MediaQuery.of(context).size.height * 0.6,
            child: Material(
              color: Colors.transparent,
              child: const ChatWindow(),
            ),
          ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: _ChatFAB(
            isOpen: chatState.isOpen,
            hasUnread: chatState.messages.isNotEmpty && !chatState.isOpen,
            onTap: () => chatNotifier.toggleChat(),
          ),
        ),
      ],
    );
  }
}

class _ChatFAB extends StatefulWidget {
  final bool isOpen;
  final bool hasUnread;
  final VoidCallback onTap;

  const _ChatFAB({
    required this.isOpen,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  State<_ChatFAB> createState() => _ChatFABState();
}

class _ChatFABState extends State<_ChatFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ChatFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: widget.isOpen
                    ? null
                    : AppColors.gradientPurple,
                color: widget.isOpen
                    ? AppColors.casinoBgSecondary
                    : null,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: widget.isOpen
                        ? Colors.black.withValues(alpha: 0.3)
                        : AppColors.casinoPurple.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isOpen ? Icons.close : Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            // Unread indicator
            if (widget.hasUnread && !widget.isOpen)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.casinoAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.casinoBg,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A wrapper to add ChatWidget to any screen
class ChatOverlay extends StatelessWidget {
  final Widget child;

  const ChatOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const ChatWidget(),
      ],
    );
  }
}
