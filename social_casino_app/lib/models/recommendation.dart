import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

enum EventType {
  @JsonValue('impression')
  impression,
  @JsonValue('game_time')
  gameTime,
}

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent({
    required String userId,
    required String gameSlug,
    required EventType eventType,
    int? durationSeconds,
    Map<String, dynamic>? metadata,
  }) = _UserEvent;

  factory UserEvent.fromJson(Map<String, dynamic> json) =>
      _$UserEventFromJson(json);
}

@freezed
class RatingInput with _$RatingInput {
  const factory RatingInput({
    required String userId,
    required String gameSlug,
    required int rating,
  }) = _RatingInput;

  factory RatingInput.fromJson(Map<String, dynamic> json) =>
      _$RatingInputFromJson(json);
}

@freezed
class RecommendationReviewInput with _$RecommendationReviewInput {
  const factory RecommendationReviewInput({
    required String userId,
    required String gameSlug,
    required int rating,
    String? reviewText,
  }) = _RecommendationReviewInput;

  factory RecommendationReviewInput.fromJson(Map<String, dynamic> json) =>
      _$RecommendationReviewInputFromJson(json);
}

@freezed
class RecommendationResponse with _$RecommendationResponse {
  const factory RecommendationResponse({
    required List<String> gameSlugs,
  }) = _RecommendationResponse;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResponseFromJson(json);
}
