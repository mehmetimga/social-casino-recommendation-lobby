// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameTagImpl _$$GameTagImplFromJson(Map<String, dynamic> json) =>
    _$GameTagImpl(tag: json['tag'] as String);

Map<String, dynamic> _$$GameTagImplToJson(_$GameTagImpl instance) =>
    <String, dynamic>{'tag': instance.tag};

_$GameGalleryImageImpl _$$GameGalleryImageImplFromJson(
  Map<String, dynamic> json,
) => _$GameGalleryImageImpl(
  image: Media.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$GameGalleryImageImplToJson(
  _$GameGalleryImageImpl instance,
) => <String, dynamic>{'image': instance.image};

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
  id: json['id'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  provider: json['provider'] as String,
  type: $enumDecode(_$GameTypeEnumMap, json['type']),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => GameTag.fromJson(e as Map<String, dynamic>))
      .toList(),
  thumbnail: Media.fromJson(json['thumbnail'] as Map<String, dynamic>),
  heroImage: json['heroImage'] == null
      ? null
      : Media.fromJson(json['heroImage'] as Map<String, dynamic>),
  gallery: (json['gallery'] as List<dynamic>?)
      ?.map((e) => GameGalleryImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  shortDescription: json['shortDescription'] as String?,
  fullDescription: json['fullDescription'],
  popularityScore: (json['popularityScore'] as num?)?.toInt() ?? 0,
  jackpotAmount: (json['jackpotAmount'] as num?)?.toDouble(),
  minBet: (json['minBet'] as num?)?.toDouble() ?? 0.1,
  maxBet: (json['maxBet'] as num?)?.toDouble() ?? 100,
  rtp: (json['rtp'] as num?)?.toDouble(),
  volatility: $enumDecodeNullable(_$VolatilityEnumMap, json['volatility']),
  badges: (json['badges'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$BadgeTypeEnumMap, e))
      .toList(),
  status: $enumDecode(_$GameStatusEnumMap, json['status']),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'provider': instance.provider,
      'type': _$GameTypeEnumMap[instance.type]!,
      'tags': instance.tags,
      'thumbnail': instance.thumbnail,
      'heroImage': instance.heroImage,
      'gallery': instance.gallery,
      'shortDescription': instance.shortDescription,
      'fullDescription': instance.fullDescription,
      'popularityScore': instance.popularityScore,
      'jackpotAmount': instance.jackpotAmount,
      'minBet': instance.minBet,
      'maxBet': instance.maxBet,
      'rtp': instance.rtp,
      'volatility': _$VolatilityEnumMap[instance.volatility],
      'badges': instance.badges?.map((e) => _$BadgeTypeEnumMap[e]!).toList(),
      'status': _$GameStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$GameTypeEnumMap = {
  GameType.slot: 'slot',
  GameType.table: 'table',
  GameType.live: 'live',
  GameType.instant: 'instant',
};

const _$VolatilityEnumMap = {
  Volatility.low: 'low',
  Volatility.medium: 'medium',
  Volatility.high: 'high',
};

const _$BadgeTypeEnumMap = {
  BadgeType.newBadge: 'new',
  BadgeType.exclusive: 'exclusive',
  BadgeType.hot: 'hot',
  BadgeType.jackpot: 'jackpot',
  BadgeType.featured: 'featured',
};

const _$GameStatusEnumMap = {
  GameStatus.enabled: 'enabled',
  GameStatus.disabled: 'disabled',
};

_$GameFiltersImpl _$$GameFiltersImplFromJson(Map<String, dynamic> json) =>
    _$GameFiltersImpl(
      type: $enumDecodeNullable(_$GameTypeEnumMap, json['type']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$BadgeTypeEnumMap, e))
          .toList(),
      minPopularity: (json['minPopularity'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GameFiltersImplToJson(_$GameFiltersImpl instance) =>
    <String, dynamic>{
      'type': _$GameTypeEnumMap[instance.type],
      'tags': instance.tags,
      'badges': instance.badges?.map((e) => _$BadgeTypeEnumMap[e]!).toList(),
      'minPopularity': instance.minPopularity,
      'limit': instance.limit,
      'page': instance.page,
    };

_$PaginatedGamesImpl _$$PaginatedGamesImplFromJson(Map<String, dynamic> json) =>
    _$PaginatedGamesImpl(
      docs: (json['docs'] as List<dynamic>)
          .map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDocs: (json['totalDocs'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
    );

Map<String, dynamic> _$$PaginatedGamesImplToJson(
  _$PaginatedGamesImpl instance,
) => <String, dynamic>{
  'docs': instance.docs,
  'totalDocs': instance.totalDocs,
  'limit': instance.limit,
  'page': instance.page,
  'totalPages': instance.totalPages,
  'hasNextPage': instance.hasNextPage,
  'hasPrevPage': instance.hasPrevPage,
};
