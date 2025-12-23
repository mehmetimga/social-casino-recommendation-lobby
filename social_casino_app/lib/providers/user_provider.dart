import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/game.dart';
import '../models/recommendation.dart';
import 'services_provider.dart';

const _userIdKey = 'user_id';
const _vipLevelKey = 'vip_level';

/// User state
class UserState {
  final String? userId;
  final VipLevel vipLevel;
  final bool isInitialized;

  const UserState({
    this.userId,
    this.vipLevel = VipLevel.bronze,
    this.isInitialized = false,
  });

  UserState copyWith({
    String? userId,
    VipLevel? vipLevel,
    bool? isInitialized,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      vipLevel: vipLevel ?? this.vipLevel,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// User notifier for managing user ID and tracking events
class UserNotifier extends StateNotifier<UserState> {
  final Ref _ref;

  UserNotifier(this._ref) : super(const UserState()) {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString(_userIdKey, userId);
    }

    // Load VIP level from storage (default to bronze)
    final vipLevelStr = prefs.getString(_vipLevelKey) ?? 'bronze';
    final vipLevel = VipLevel.values.firstWhere(
      (e) => e.name == vipLevelStr,
      orElse: () => VipLevel.bronze,
    );

    state = state.copyWith(userId: userId, vipLevel: vipLevel, isInitialized: true);
  }

  /// Set the user's VIP level
  Future<void> setVipLevel(VipLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vipLevelKey, level.name);
    state = state.copyWith(vipLevel: level);
  }

  /// Track an impression event
  Future<void> trackImpression(String gameSlug) async {
    if (state.userId == null) return;

    try {
      final recommendationService = _ref.read(recommendationServiceProvider);
      await recommendationService.trackEvent(
        UserEvent(
          userId: state.userId!,
          gameSlug: gameSlug,
          eventType: EventType.impression,
        ),
      );
    } catch (e) {
      // Silently fail - tracking shouldn't break the app
    }
  }

  /// Track game time event
  Future<void> trackGameTime(String gameSlug, int durationSeconds) async {
    if (state.userId == null) return;

    try {
      final recommendationService = _ref.read(recommendationServiceProvider);
      await recommendationService.trackEvent(
        UserEvent(
          userId: state.userId!,
          gameSlug: gameSlug,
          eventType: EventType.gameTime,
          durationSeconds: durationSeconds,
        ),
      );
    } catch (e) {
      // Silently fail - tracking shouldn't break the app
    }
  }

  /// Submit a rating
  Future<void> submitRating(String gameSlug, int rating) async {
    if (state.userId == null) return;

    try {
      final recommendationService = _ref.read(recommendationServiceProvider);
      await recommendationService.submitRating(
        RatingInput(
          userId: state.userId!,
          gameSlug: gameSlug,
          rating: rating,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Submit a review with rating
  Future<void> submitReview(String gameSlug, int rating, String? reviewText) async {
    if (state.userId == null) return;

    try {
      final recommendationService = _ref.read(recommendationServiceProvider);
      await recommendationService.submitReview(
        RecommendationReviewInput(
          userId: state.userId!,
          gameSlug: gameSlug,
          rating: rating,
          reviewText: reviewText,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }
}

/// User provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});
