// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CtaLinkImpl _$$CtaLinkImplFromJson(Map<String, dynamic> json) =>
    _$CtaLinkImpl(
      type: $enumDecode(_$CtaLinkTypeEnumMap, json['type']),
      game: json['game'] as String?,
      url: json['url'] as String?,
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$CtaLinkImplToJson(_$CtaLinkImpl instance) =>
    <String, dynamic>{
      'type': _$CtaLinkTypeEnumMap[instance.type]!,
      'game': instance.game,
      'url': instance.url,
      'category': instance.category,
    };

const _$CtaLinkTypeEnumMap = {
  CtaLinkType.game: 'game',
  CtaLinkType.url: 'url',
  CtaLinkType.category: 'category',
};

_$PromotionScheduleImpl _$$PromotionScheduleImplFromJson(
  Map<String, dynamic> json,
) => _$PromotionScheduleImpl(
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
);

Map<String, dynamic> _$$PromotionScheduleImplToJson(
  _$PromotionScheduleImpl instance,
) => <String, dynamic>{
  'startDate': instance.startDate,
  'endDate': instance.endDate,
};

_$PromotionCountdownImpl _$$PromotionCountdownImplFromJson(
  Map<String, dynamic> json,
) => _$PromotionCountdownImpl(
  enabled: json['enabled'] as bool? ?? false,
  endTime: json['endTime'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$$PromotionCountdownImplToJson(
  _$PromotionCountdownImpl instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'endTime': instance.endTime,
  'label': instance.label,
};

_$PromotionImpl _$$PromotionImplFromJson(
  Map<String, dynamic> json,
) => _$PromotionImpl(
  id: json['id'] as String,
  slug: json['slug'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
  description: json['description'] as String?,
  image: json['image'] == null
      ? null
      : Media.fromJson(json['image'] as Map<String, dynamic>),
  backgroundImage: json['backgroundImage'] == null
      ? null
      : Media.fromJson(json['backgroundImage'] as Map<String, dynamic>),
  ctaText: json['ctaText'] as String? ?? 'Play Now',
  ctaLink: json['ctaLink'] == null
      ? null
      : CtaLink.fromJson(json['ctaLink'] as Map<String, dynamic>),
  schedule: json['schedule'] == null
      ? null
      : PromotionSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
  countdown: json['countdown'] == null
      ? null
      : PromotionCountdown.fromJson(json['countdown'] as Map<String, dynamic>),
  status: $enumDecode(_$PromotionStatusEnumMap, json['status']),
  placement: $enumDecode(_$PromotionPlacementEnumMap, json['placement']),
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$$PromotionImplToJson(_$PromotionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'description': instance.description,
      'image': instance.image,
      'backgroundImage': instance.backgroundImage,
      'ctaText': instance.ctaText,
      'ctaLink': instance.ctaLink,
      'schedule': instance.schedule,
      'countdown': instance.countdown,
      'status': _$PromotionStatusEnumMap[instance.status]!,
      'placement': _$PromotionPlacementEnumMap[instance.placement]!,
      'priority': instance.priority,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$PromotionStatusEnumMap = {
  PromotionStatus.draft: 'draft',
  PromotionStatus.live: 'live',
};

const _$PromotionPlacementEnumMap = {
  PromotionPlacement.hero: 'hero',
  PromotionPlacement.banner: 'banner',
  PromotionPlacement.featured: 'featured',
};

_$PaginatedPromotionsImpl _$$PaginatedPromotionsImplFromJson(
  Map<String, dynamic> json,
) => _$PaginatedPromotionsImpl(
  docs: (json['docs'] as List<dynamic>)
      .map((e) => Promotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalDocs: (json['totalDocs'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNextPage: json['hasNextPage'] as bool,
  hasPrevPage: json['hasPrevPage'] as bool,
);

Map<String, dynamic> _$$PaginatedPromotionsImplToJson(
  _$PaginatedPromotionsImpl instance,
) => <String, dynamic>{
  'docs': instance.docs,
  'totalDocs': instance.totalDocs,
  'limit': instance.limit,
  'page': instance.page,
  'totalPages': instance.totalPages,
  'hasNextPage': instance.hasNextPage,
  'hasPrevPage': instance.hasPrevPage,
};
