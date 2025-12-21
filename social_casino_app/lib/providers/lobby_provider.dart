import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lobby_layout.dart';
import '../models/game.dart';
import '../models/promotion.dart';
import 'services_provider.dart';
import 'user_provider.dart';

/// Lightweight layout info for category tabs (id, slug, name only)
class LayoutTabInfo {
  final String id;
  final String slug;
  final String name;
  final String platform;
  final bool isDefault;

  LayoutTabInfo({
    required this.id,
    required this.slug,
    required this.name,
    required this.platform,
    required this.isDefault,
  });

  factory LayoutTabInfo.fromMap(Map<String, dynamic> map) {
    return LayoutTabInfo(
      id: map['id'] as String,
      slug: map['slug'] as String,
      name: map['name'] as String,
      platform: map['platform'] as String? ?? 'web',
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }
}

/// All lobby layouts for tabs (lightweight - just names)
final lobbyLayoutTabsProvider = FutureProvider<List<LayoutTabInfo>>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  final layouts = await cmsService.getLobbyLayoutsForTabs();
  return layouts.map((m) => LayoutTabInfo.fromMap(m)).toList();
});

/// Selected lobby layout slug
final selectedLayoutSlugProvider = StateProvider<String?>((ref) => null);

/// Current lobby layout provider - based on selected slug or default
final currentLobbyLayoutProvider = FutureProvider<LobbyLayout?>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  final selectedSlug = ref.watch(selectedLayoutSlugProvider);

  if (selectedSlug != null) {
    return cmsService.getLobbyLayout(slug: selectedSlug);
  }

  // Default to the default layout
  return cmsService.getDefaultLobbyLayout(platform: 'mobile');
});

/// Lobby layout provider - fetches and caches the default layout
final lobbyLayoutProvider = FutureProvider<LobbyLayout?>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getDefaultLobbyLayout(platform: 'mobile');
});

/// Lobby layout by slug
final lobbyLayoutBySlugProvider = FutureProvider.family<LobbyLayout?, String>((ref, slug) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getLobbyLayout(slug: slug);
});

/// Popular games provider
final popularGamesProvider = FutureProvider<List<Game>>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getPopularGames(limit: 12);
});

/// Games by type provider
final gamesByTypeProvider = FutureProvider.family<List<Game>, GameType>((ref, type) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getGamesByType(type, limit: 20);
});

/// Games by badge provider
final gamesByBadgeProvider = FutureProvider.family<List<Game>, String>((ref, badge) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getGamesByBadge(badge, limit: 12);
});

/// New games provider
final newGamesProvider = FutureProvider<List<Game>>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getNewGames(limit: 12);
});

/// Jackpot games provider
final jackpotGamesProvider = FutureProvider<List<Game>>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getJackpotGames(limit: 12);
});

/// Promotions by placement provider
final promotionsByPlacementProvider = FutureProvider.family<List<Promotion>, String?>((ref, placement) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getPromotions(placement: placement);
});

/// Hero promotions provider
final heroPromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getPromotions(placement: 'hero');
});

/// Personalized recommendations provider
final recommendationsProvider = FutureProvider.family<List<Game>, int>((ref, limit) async {
  final userState = ref.watch(userProvider);
  final cmsService = ref.watch(cmsServiceProvider);
  final recommendationService = ref.watch(recommendationServiceProvider);

  if (userState.userId == null) {
    // Fall back to popular games
    return cmsService.getPopularGames(limit: limit);
  }

  try {
    final slugs = await recommendationService.getRecommendations(
      userId: userState.userId!,
      limit: limit,
    );

    if (slugs.isNotEmpty) {
      return cmsService.getGamesBySlugs(slugs);
    }
  } catch (e) {
    // Fall through to fallback
  }

  // Fallback to popular games
  return cmsService.getPopularGames(limit: limit);
});

/// Single game provider
final gameBySlugProvider = FutureProvider.family<Game?, String>((ref, slug) async {
  final cmsService = ref.watch(cmsServiceProvider);
  return cmsService.getGame(slug);
});
