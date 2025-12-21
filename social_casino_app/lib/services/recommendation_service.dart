import 'package:dio/dio.dart';
import '../models/recommendation.dart';
import 'api_client.dart';

class RecommendationService {
  final Dio _dio;

  RecommendationService(ApiClient client) : _dio = client.recommendationDio;

  /// Track a user event (impression, game_time)
  Future<void> trackEvent(UserEvent event) async {
    try {
      await _dio.post('/v1/events', data: {
        'userId': event.userId,
        'gameSlug': event.gameSlug,
        'eventType': event.eventType == EventType.impression ? 'impression' : 'game_time',
        if (event.durationSeconds != null) 'durationSeconds': event.durationSeconds,
        if (event.metadata != null) 'metadata': event.metadata,
      });
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to track event',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Submit a rating
  Future<void> submitRating(RatingInput rating) async {
    try {
      await _dio.post('/v1/feedback/rating', data: {
        'userId': rating.userId,
        'gameSlug': rating.gameSlug,
        'rating': rating.rating,
      });
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to submit rating',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Submit a review with rating and optional text
  Future<void> submitReview(RecommendationReviewInput review) async {
    try {
      await _dio.post('/v1/feedback/review', data: {
        'userId': review.userId,
        'gameSlug': review.gameSlug,
        'rating': review.rating,
        if (review.reviewText != null) 'reviewText': review.reviewText,
      });
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to submit review',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Get personalized recommendations
  Future<List<String>> getRecommendations({
    required String userId,
    String? placement,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
      };
      if (placement != null) {
        queryParams['placement'] = placement;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      final response = await _dio.get('/v1/recommendations', queryParameters: queryParams);

      // Handle both array response and object with gameSlugs
      if (response.data is List) {
        return List<String>.from(response.data);
      } else if (response.data is Map && response.data['gameSlugs'] != null) {
        return List<String>.from(response.data['gameSlugs']);
      }
      return [];
    } on DioException {
      // Return empty list on error to allow fallback to popular games
      return [];
    }
  }
}
