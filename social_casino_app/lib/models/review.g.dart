// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameReviewImpl _$$GameReviewImplFromJson(Map<String, dynamic> json) =>
    _$GameReviewImpl(
      id: json['id'] as String,
      visitorId: json['visitorId'] as String,
      game: json['game'] as String,
      rating: (json['rating'] as num).toInt(),
      reviewText: json['reviewText'] as String?,
      status:
          $enumDecodeNullable(_$ReviewStatusEnumMap, json['status']) ??
          ReviewStatus.published,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$GameReviewImplToJson(_$GameReviewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visitorId': instance.visitorId,
      'game': instance.game,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
      'status': _$ReviewStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$ReviewStatusEnumMap = {
  ReviewStatus.published: 'published',
  ReviewStatus.hidden: 'hidden',
  ReviewStatus.pending: 'pending',
};

_$ReviewInputImpl _$$ReviewInputImplFromJson(Map<String, dynamic> json) =>
    _$ReviewInputImpl(
      visitorId: json['visitorId'] as String,
      game: json['game'] as String,
      rating: (json['rating'] as num).toInt(),
      reviewText: json['reviewText'] as String?,
    );

Map<String, dynamic> _$$ReviewInputImplToJson(_$ReviewInputImpl instance) =>
    <String, dynamic>{
      'visitorId': instance.visitorId,
      'game': instance.game,
      'rating': instance.rating,
      'reviewText': instance.reviewText,
    };

_$PaginatedReviewsImpl _$$PaginatedReviewsImplFromJson(
  Map<String, dynamic> json,
) => _$PaginatedReviewsImpl(
  docs: (json['docs'] as List<dynamic>)
      .map((e) => GameReview.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalDocs: (json['totalDocs'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNextPage: json['hasNextPage'] as bool,
  hasPrevPage: json['hasPrevPage'] as bool,
);

Map<String, dynamic> _$$PaginatedReviewsImplToJson(
  _$PaginatedReviewsImpl instance,
) => <String, dynamic>{
  'docs': instance.docs,
  'totalDocs': instance.totalDocs,
  'limit': instance.limit,
  'page': instance.page,
  'totalPages': instance.totalPages,
  'hasNextPage': instance.hasNextPage,
  'hasPrevPage': instance.hasPrevPage,
};
