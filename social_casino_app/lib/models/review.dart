import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

enum ReviewStatus {
  @JsonValue('published')
  published,
  @JsonValue('hidden')
  hidden,
  @JsonValue('pending')
  pending,
}

@freezed
class GameReview with _$GameReview {
  const factory GameReview({
    required String id,
    required String visitorId,
    required String game,
    required int rating,
    String? reviewText,
    @Default(ReviewStatus.published) ReviewStatus status,
    required String createdAt,
    String? updatedAt,
  }) = _GameReview;

  factory GameReview.fromJson(Map<String, dynamic> json) =>
      _$GameReviewFromJson(json);
}

@freezed
class ReviewInput with _$ReviewInput {
  const factory ReviewInput({
    required String visitorId,
    required String game,
    required int rating,
    String? reviewText,
  }) = _ReviewInput;

  factory ReviewInput.fromJson(Map<String, dynamic> json) =>
      _$ReviewInputFromJson(json);
}

@freezed
class PaginatedReviews with _$PaginatedReviews {
  const factory PaginatedReviews({
    required List<GameReview> docs,
    required int totalDocs,
    required int limit,
    required int page,
    required int totalPages,
    required bool hasNextPage,
    required bool hasPrevPage,
  }) = _PaginatedReviews;

  factory PaginatedReviews.fromJson(Map<String, dynamic> json) =>
      _$PaginatedReviewsFromJson(json);
}
