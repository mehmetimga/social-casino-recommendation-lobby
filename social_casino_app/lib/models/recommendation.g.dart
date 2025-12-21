// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEventImpl _$$UserEventImplFromJson(Map<String, dynamic> json) =>
    _$UserEventImpl(
      userId: json['userId'] as String,
      gameSlug: json['gameSlug'] as String,
      eventType: $enumDecode(_$EventTypeEnumMap, json['eventType']),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$UserEventImplToJson(_$UserEventImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'gameSlug': instance.gameSlug,
      'eventType': _$EventTypeEnumMap[instance.eventType]!,
      'durationSeconds': instance.durationSeconds,
      'metadata': instance.metadata,
    };

const _$EventTypeEnumMap = {
  EventType.impression: 'impression',
  EventType.gameTime: 'game_time',
};

_$RatingInputImpl _$$RatingInputImplFromJson(Map<String, dynamic> json) =>
    _$RatingInputImpl(
      userId: json['userId'] as String,
      gameSlug: json['gameSlug'] as String,
      rating: (json['rating'] as num).toInt(),
    );

Map<String, dynamic> _$$RatingInputImplToJson(_$RatingInputImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'gameSlug': instance.gameSlug,
      'rating': instance.rating,
    };

_$RecommendationReviewInputImpl _$$RecommendationReviewInputImplFromJson(
  Map<String, dynamic> json,
) => _$RecommendationReviewInputImpl(
  userId: json['userId'] as String,
  gameSlug: json['gameSlug'] as String,
  rating: (json['rating'] as num).toInt(),
  reviewText: json['reviewText'] as String?,
);

Map<String, dynamic> _$$RecommendationReviewInputImplToJson(
  _$RecommendationReviewInputImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'gameSlug': instance.gameSlug,
  'rating': instance.rating,
  'reviewText': instance.reviewText,
};

_$RecommendationResponseImpl _$$RecommendationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RecommendationResponseImpl(
  gameSlugs: (json['gameSlugs'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$RecommendationResponseImplToJson(
  _$RecommendationResponseImpl instance,
) => <String, dynamic>{'gameSlugs': instance.gameSlugs};
