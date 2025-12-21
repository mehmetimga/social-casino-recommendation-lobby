import 'package:freezed_annotation/freezed_annotation.dart';
import 'media.dart';

part 'promotion.freezed.dart';
part 'promotion.g.dart';

enum PromotionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('live')
  live,
}

enum PromotionPlacement {
  @JsonValue('hero')
  hero,
  @JsonValue('banner')
  banner,
  @JsonValue('featured')
  featured,
}

enum CtaLinkType {
  @JsonValue('game')
  game,
  @JsonValue('url')
  url,
  @JsonValue('category')
  category,
}

@freezed
class CtaLink with _$CtaLink {
  const factory CtaLink({
    required CtaLinkType type,
    String? game,
    String? url,
    String? category,
  }) = _CtaLink;

  factory CtaLink.fromJson(Map<String, dynamic> json) =>
      _$CtaLinkFromJson(json);
}

@freezed
class PromotionSchedule with _$PromotionSchedule {
  const factory PromotionSchedule({
    String? startDate,
    String? endDate,
  }) = _PromotionSchedule;

  factory PromotionSchedule.fromJson(Map<String, dynamic> json) =>
      _$PromotionScheduleFromJson(json);
}

@freezed
class PromotionCountdown with _$PromotionCountdown {
  const factory PromotionCountdown({
    @Default(false) bool enabled,
    String? endTime,
    String? label,
  }) = _PromotionCountdown;

  factory PromotionCountdown.fromJson(Map<String, dynamic> json) =>
      _$PromotionCountdownFromJson(json);
}

@freezed
class Promotion with _$Promotion {
  const factory Promotion({
    required String id,
    required String slug,
    required String title,
    String? subtitle,
    String? description,
    Media? image,
    Media? backgroundImage,
    @Default('Play Now') String ctaText,
    CtaLink? ctaLink,
    PromotionSchedule? schedule,
    PromotionCountdown? countdown,
    required PromotionStatus status,
    required PromotionPlacement placement,
    @Default(0) int priority,
    String? createdAt,
    String? updatedAt,
  }) = _Promotion;

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);
}

@freezed
class PaginatedPromotions with _$PaginatedPromotions {
  const factory PaginatedPromotions({
    required List<Promotion> docs,
    required int totalDocs,
    required int limit,
    required int page,
    required int totalPages,
    required bool hasNextPage,
    required bool hasPrevPage,
  }) = _PaginatedPromotions;

  factory PaginatedPromotions.fromJson(Map<String, dynamic> json) =>
      _$PaginatedPromotionsFromJson(json);
}
