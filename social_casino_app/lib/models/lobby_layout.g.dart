// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lobby_layout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CarouselSectionBlockImpl _$$CarouselSectionBlockImplFromJson(
  Map<String, dynamic> json,
) => _$CarouselSectionBlockImpl(
  blockType: json['blockType'] as String? ?? 'carousel-section',
  title: json['title'] as String?,
  promotions: (json['promotions'] as List<dynamic>?)
      ?.map((e) => Promotion.fromJson(e as Map<String, dynamic>))
      .toList(),
  autoPlay: json['autoPlay'] as bool? ?? true,
  autoPlayInterval: (json['autoPlayInterval'] as num?)?.toInt() ?? 5000,
  showDots: json['showDots'] as bool? ?? true,
  showArrows: json['showArrows'] as bool? ?? true,
  height:
      $enumDecodeNullable(_$CarouselHeightEnumMap, json['height']) ??
      CarouselHeight.medium,
);

Map<String, dynamic> _$$CarouselSectionBlockImplToJson(
  _$CarouselSectionBlockImpl instance,
) => <String, dynamic>{
  'blockType': instance.blockType,
  'title': instance.title,
  'promotions': instance.promotions,
  'autoPlay': instance.autoPlay,
  'autoPlayInterval': instance.autoPlayInterval,
  'showDots': instance.showDots,
  'showArrows': instance.showArrows,
  'height': _$CarouselHeightEnumMap[instance.height]!,
};

const _$CarouselHeightEnumMap = {
  CarouselHeight.small: 'small',
  CarouselHeight.medium: 'medium',
  CarouselHeight.large: 'large',
  CarouselHeight.full: 'full',
};

_$SuggestedGamesSectionBlockImpl _$$SuggestedGamesSectionBlockImplFromJson(
  Map<String, dynamic> json,
) => _$SuggestedGamesSectionBlockImpl(
  blockType: json['blockType'] as String? ?? 'suggested-games-section',
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
  mode: $enumDecode(_$SuggestedModeEnumMap, json['mode']),
  manualGames: (json['manualGames'] as List<dynamic>?)
      ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
      .toList(),
  placement: json['placement'] as String,
  limit: (json['limit'] as num?)?.toInt() ?? 12,
  fallbackToPopular: json['fallbackToPopular'] as bool? ?? true,
  showScrollButtons: json['showScrollButtons'] as bool? ?? true,
  cardSize:
      $enumDecodeNullable(_$CardSizeEnumMap, json['cardSize']) ??
      CardSize.medium,
);

Map<String, dynamic> _$$SuggestedGamesSectionBlockImplToJson(
  _$SuggestedGamesSectionBlockImpl instance,
) => <String, dynamic>{
  'blockType': instance.blockType,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'mode': _$SuggestedModeEnumMap[instance.mode]!,
  'manualGames': instance.manualGames,
  'placement': instance.placement,
  'limit': instance.limit,
  'fallbackToPopular': instance.fallbackToPopular,
  'showScrollButtons': instance.showScrollButtons,
  'cardSize': _$CardSizeEnumMap[instance.cardSize]!,
};

const _$SuggestedModeEnumMap = {
  SuggestedMode.manual: 'manual',
  SuggestedMode.personalized: 'personalized',
};

const _$CardSizeEnumMap = {
  CardSize.small: 'small',
  CardSize.medium: 'medium',
  CardSize.large: 'large',
};

_$GameGridSectionBlockImpl _$$GameGridSectionBlockImplFromJson(
  Map<String, dynamic> json,
) => _$GameGridSectionBlockImpl(
  blockType: json['blockType'] as String? ?? 'game-grid-section',
  title: json['title'] as String,
  subtitle: json['subtitle'] as String?,
  filterType: $enumDecode(_$FilterTypeEnumMap, json['filterType']),
  manualGames: (json['manualGames'] as List<dynamic>?)
      ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
      .toList(),
  gameType: json['gameType'] as String?,
  tag: json['tag'] as String?,
  displayStyle:
      $enumDecodeNullable(_$DisplayStyleEnumMap, json['displayStyle']) ??
      DisplayStyle.horizontal,
  rows: (json['rows'] as num?)?.toInt() ?? 2,
  featuredGame: json['featuredGame'] == null
      ? null
      : Game.fromJson(json['featuredGame'] as Map<String, dynamic>),
  limit: (json['limit'] as num?)?.toInt() ?? 12,
  columns: json['columns'] as String? ?? '4',
  showMore: json['showMore'] as bool? ?? true,
  moreLink: json['moreLink'] as String?,
  cardSize:
      $enumDecodeNullable(_$CardSizeEnumMap, json['cardSize']) ??
      CardSize.medium,
  showJackpot: json['showJackpot'] as bool? ?? true,
  showProvider: json['showProvider'] as bool? ?? true,
);

Map<String, dynamic> _$$GameGridSectionBlockImplToJson(
  _$GameGridSectionBlockImpl instance,
) => <String, dynamic>{
  'blockType': instance.blockType,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'filterType': _$FilterTypeEnumMap[instance.filterType]!,
  'manualGames': instance.manualGames,
  'gameType': instance.gameType,
  'tag': instance.tag,
  'displayStyle': _$DisplayStyleEnumMap[instance.displayStyle]!,
  'rows': instance.rows,
  'featuredGame': instance.featuredGame,
  'limit': instance.limit,
  'columns': instance.columns,
  'showMore': instance.showMore,
  'moreLink': instance.moreLink,
  'cardSize': _$CardSizeEnumMap[instance.cardSize]!,
  'showJackpot': instance.showJackpot,
  'showProvider': instance.showProvider,
};

const _$FilterTypeEnumMap = {
  FilterType.manual: 'manual',
  FilterType.type: 'type',
  FilterType.tag: 'tag',
  FilterType.popular: 'popular',
  FilterType.newGames: 'new',
  FilterType.jackpot: 'jackpot',
  FilterType.featured: 'featured',
};

const _$DisplayStyleEnumMap = {
  DisplayStyle.horizontal: 'horizontal',
  DisplayStyle.grid: 'grid',
  DisplayStyle.carouselRows: 'carousel-rows',
  DisplayStyle.singleRow: 'single-row',
  DisplayStyle.featuredLeft: 'featured-left',
  DisplayStyle.featuredRight: 'featured-right',
  DisplayStyle.featuredTop: 'featured-top',
};

_$BannerSectionBlockImpl _$$BannerSectionBlockImplFromJson(
  Map<String, dynamic> json,
) => _$BannerSectionBlockImpl(
  blockType: json['blockType'] as String? ?? 'banner-section',
  promotion: json['promotion'] == null
      ? null
      : Promotion.fromJson(json['promotion'] as Map<String, dynamic>),
  size:
      $enumDecodeNullable(_$BannerSizeEnumMap, json['size']) ??
      BannerSize.medium,
  alignment:
      $enumDecodeNullable(_$BannerAlignmentEnumMap, json['alignment']) ??
      BannerAlignment.center,
  showCountdown: json['showCountdown'] as bool? ?? false,
  rounded: json['rounded'] as bool? ?? true,
  showOverlay: json['showOverlay'] as bool? ?? true,
  marginTop: (json['marginTop'] as num?)?.toInt() ?? 16,
  marginBottom: (json['marginBottom'] as num?)?.toInt() ?? 16,
);

Map<String, dynamic> _$$BannerSectionBlockImplToJson(
  _$BannerSectionBlockImpl instance,
) => <String, dynamic>{
  'blockType': instance.blockType,
  'promotion': instance.promotion,
  'size': _$BannerSizeEnumMap[instance.size]!,
  'alignment': _$BannerAlignmentEnumMap[instance.alignment]!,
  'showCountdown': instance.showCountdown,
  'rounded': instance.rounded,
  'showOverlay': instance.showOverlay,
  'marginTop': instance.marginTop,
  'marginBottom': instance.marginBottom,
};

const _$BannerSizeEnumMap = {
  BannerSize.small: 'small',
  BannerSize.medium: 'medium',
  BannerSize.large: 'large',
};

const _$BannerAlignmentEnumMap = {
  BannerAlignment.left: 'left',
  BannerAlignment.center: 'center',
  BannerAlignment.right: 'right',
};

_$LobbyLayoutImpl _$$LobbyLayoutImplFromJson(Map<String, dynamic> json) =>
    _$LobbyLayoutImpl(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      platform: $enumDecode(_$PlatformEnumMap, json['platform']),
      isDefault: json['isDefault'] as bool? ?? false,
      sections: const LobbySectionBlockListConverter().fromJson(
        json['sections'] as List,
      ),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$LobbyLayoutImplToJson(
  _$LobbyLayoutImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'platform': _$PlatformEnumMap[instance.platform]!,
  'isDefault': instance.isDefault,
  'sections': const LobbySectionBlockListConverter().toJson(instance.sections),
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$PlatformEnumMap = {Platform.web: 'web', Platform.mobile: 'mobile'};
