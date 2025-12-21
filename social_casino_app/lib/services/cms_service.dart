import 'package:dio/dio.dart';
import '../models/game.dart';
import '../models/promotion.dart';
import '../models/lobby_layout.dart';
import '../models/review.dart';
import 'api_client.dart';

class CmsService {
  final Dio _dio;

  CmsService(ApiClient client) : _dio = client.cmsDio;

  /// Get games with optional filters
  Future<PaginatedGames> getGames({
    GameType? type,
    String? badge,
    int? limit,
    int? page,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (type != null) {
        queryParams['where[type][equals]'] = type.name;
      }
      if (badge != null) {
        queryParams['where[badges][contains]'] = badge;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (sort != null) {
        queryParams['sort'] = sort;
      }
      queryParams['where[status][equals]'] = 'enabled';

      final response = await _dio.get('/api/games', queryParameters: queryParams);
      return PaginatedGames.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch games',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get a single game by slug
  Future<Game?> getGame(String slug) async {
    try {
      final response = await _dio.get('/api/games', queryParameters: {
        'where[slug][equals]': slug,
        'limit': 1,
      });
      final paginated = PaginatedGames.fromJson(response.data);
      return paginated.docs.isNotEmpty ? paginated.docs.first : null;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch game',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get games by type
  Future<List<Game>> getGamesByType(GameType type, {int limit = 12}) async {
    final result = await getGames(type: type, limit: limit, sort: '-popularityScore');
    return result.docs;
  }

  /// Get games by badge
  Future<List<Game>> getGamesByBadge(String badge, {int limit = 12}) async {
    final result = await getGames(badge: badge, limit: limit, sort: '-popularityScore');
    return result.docs;
  }

  /// Get popular games
  Future<List<Game>> getPopularGames({int limit = 12}) async {
    final result = await getGames(limit: limit, sort: '-popularityScore');
    return result.docs;
  }

  /// Get new games
  Future<List<Game>> getNewGames({int limit = 12}) async {
    final result = await getGames(badge: 'new', limit: limit, sort: '-createdAt');
    return result.docs;
  }

  /// Get jackpot games
  Future<List<Game>> getJackpotGames({int limit = 12}) async {
    try {
      final response = await _dio.get('/api/games', queryParameters: {
        'where[jackpotAmount][greater_than]': 0,
        'where[status][equals]': 'enabled',
        'sort': '-jackpotAmount',
        'limit': limit,
      });
      final paginated = PaginatedGames.fromJson(response.data);
      return paginated.docs;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch jackpot games',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get games by slugs
  Future<List<Game>> getGamesBySlugs(List<String> slugs) async {
    if (slugs.isEmpty) return [];

    try {
      // Fetch games one by one and collect results
      final games = <Game>[];
      for (final slug in slugs) {
        final game = await getGame(slug);
        if (game != null) {
          games.add(game);
        }
      }
      return games;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch games by slugs',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get promotions
  Future<List<Promotion>> getPromotions({String? placement}) async {
    try {
      final queryParams = <String, dynamic>{
        'where[status][equals]': 'live',
        'sort': '-priority',
      };
      if (placement != null) {
        queryParams['where[placement][equals]'] = placement;
      }

      final response = await _dio.get('/api/promotions', queryParameters: queryParams);
      final paginated = PaginatedPromotions.fromJson(response.data);
      return paginated.docs;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch promotions',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get a single promotion by slug
  Future<Promotion?> getPromotion(String slug) async {
    try {
      final response = await _dio.get('/api/promotions', queryParameters: {
        'where[slug][equals]': slug,
        'limit': 1,
      });
      final paginated = PaginatedPromotions.fromJson(response.data);
      return paginated.docs.isNotEmpty ? paginated.docs.first : null;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch promotion',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get lobby layout by slug
  Future<LobbyLayout?> getLobbyLayout({String? slug}) async {
    try {
      final queryParams = <String, dynamic>{
        'depth': 2,
        'limit': 1,
      };
      if (slug != null) {
        queryParams['where[slug][equals]'] = slug;
      } else {
        queryParams['where[isDefault][equals]'] = true;
        queryParams['where[platform][equals]'] = 'mobile';
      }

      final response = await _dio.get('/api/lobby-layouts', queryParameters: queryParams);
      final data = response.data;

      if (data['docs'] != null && (data['docs'] as List).isNotEmpty) {
        return LobbyLayout.fromJson(data['docs'][0]);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch lobby layout',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get default lobby layout for platform
  Future<LobbyLayout?> getDefaultLobbyLayout({String platform = 'mobile'}) async {
    try {
      final response = await _dio.get('/api/lobby-layouts', queryParameters: {
        'where[platform][equals]': platform,
        'where[isDefault][equals]': true,
        'depth': 2,
        'limit': 1,
      });
      final data = response.data;

      if (data['docs'] != null && (data['docs'] as List).isNotEmpty) {
        return LobbyLayout.fromJson(data['docs'][0]);
      }
      return null;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch default lobby layout',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get game reviews
  Future<List<GameReview>> getGameReviews(String gameId) async {
    try {
      final response = await _dio.get('/api/game-reviews', queryParameters: {
        'where[game][equals]': gameId,
        'where[status][equals]': 'published',
      });
      final paginated = PaginatedReviews.fromJson(response.data);
      return paginated.docs;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch reviews',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Submit a game review
  Future<GameReview> submitReview(ReviewInput input) async {
    try {
      final response = await _dio.post('/api/game-reviews', data: input.toJson());
      return GameReview.fromJson(response.data['doc']);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to submit review',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get user's review for a game
  Future<GameReview?> getUserReview(String userId, String gameId) async {
    try {
      final response = await _dio.get('/api/game-reviews', queryParameters: {
        'where[visitorId][equals]': userId,
        'where[game][equals]': gameId,
        'limit': 1,
      });
      final paginated = PaginatedReviews.fromJson(response.data);
      return paginated.docs.isNotEmpty ? paginated.docs.first : null;
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to fetch user review',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
