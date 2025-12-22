import 'package:freezed_annotation/freezed_annotation.dart';
import 'game.dart';
import 'promotion.dart';

part 'lobby_layout.freezed.dart';
part 'lobby_layout.g.dart';

enum Platform {
  @JsonValue('web')
  web,
  @JsonValue('mobile')
  mobile,
}

enum CardSize {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
}

enum CarouselHeight {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
  @JsonValue('full')
  full,
}

enum BannerSize {
  @JsonValue('small')
  small,
  @JsonValue('medium')
  medium,
  @JsonValue('large')
  large,
}

enum FilterType {
  @JsonValue('manual')
  manual,
  @JsonValue('type')
  type,
  @JsonValue('tag')
  tag,
  @JsonValue('popular')
  popular,
  @JsonValue('new')
  newGames,
  @JsonValue('jackpot')
  jackpot,
  @JsonValue('featured')
  featured,
}

enum SuggestedMode {
  @JsonValue('manual')
  manual,
  @JsonValue('personalized')
  personalized,
}

enum DisplayStyle {
  @JsonValue('horizontal')
  horizontal,
  @JsonValue('grid')
  grid,
  @JsonValue('single-row')
  singleRow,
  @JsonValue('featured-left')
  featuredLeft,
  @JsonValue('featured-right')
  featuredRight,
  @JsonValue('featured-top')
  featuredTop,
}

enum BannerAlignment {
  @JsonValue('left')
  left,
  @JsonValue('center')
  center,
  @JsonValue('right')
  right,
}

@freezed
class CarouselSectionBlock with _$CarouselSectionBlock {
  const factory CarouselSectionBlock({
    @Default('carousel-section') String blockType,
    String? title,
    List<Promotion>? promotions,
    @Default(true) bool autoPlay,
    @Default(5000) int autoPlayInterval,
    @Default(true) bool showDots,
    @Default(true) bool showArrows,
    @Default(CarouselHeight.medium) CarouselHeight height,
  }) = _CarouselSectionBlock;

  factory CarouselSectionBlock.fromJson(Map<String, dynamic> json) =>
      _$CarouselSectionBlockFromJson(json);
}

@freezed
class SuggestedGamesSectionBlock with _$SuggestedGamesSectionBlock {
  const factory SuggestedGamesSectionBlock({
    @Default('suggested-games-section') String blockType,
    required String title,
    String? subtitle,
    required SuggestedMode mode,
    List<Game>? manualGames,
    required String placement,
    @Default(12) int limit,
    @Default(true) bool fallbackToPopular,
    @Default(true) bool showScrollButtons,
    @Default(CardSize.medium) CardSize cardSize,
  }) = _SuggestedGamesSectionBlock;

  factory SuggestedGamesSectionBlock.fromJson(Map<String, dynamic> json) =>
      _$SuggestedGamesSectionBlockFromJson(json);
}

@freezed
class GameGridSectionBlock with _$GameGridSectionBlock {
  const factory GameGridSectionBlock({
    @Default('game-grid-section') String blockType,
    required String title,
    String? subtitle,
    required FilterType filterType,
    List<Game>? manualGames,
    String? gameType,
    String? tag,
    @Default(DisplayStyle.horizontal) DisplayStyle displayStyle,
    @Default(2) int rows,
    Game? featuredGame,
    @Default(12) int limit,
    @Default('4') String columns,
    @Default(true) bool showMore,
    String? moreLink,
    @Default(CardSize.medium) CardSize cardSize,
    @Default(true) bool showJackpot,
    @Default(true) bool showProvider,
  }) = _GameGridSectionBlock;

  factory GameGridSectionBlock.fromJson(Map<String, dynamic> json) =>
      _$GameGridSectionBlockFromJson(json);
}

@freezed
class BannerSectionBlock with _$BannerSectionBlock {
  const factory BannerSectionBlock({
    @Default('banner-section') String blockType,
    Promotion? promotion,
    @Default(BannerSize.medium) BannerSize size,
    @Default(BannerAlignment.center) BannerAlignment alignment,
    @Default(false) bool showCountdown,
    @Default(true) bool rounded,
    @Default(16) int marginTop,
    @Default(16) int marginBottom,
  }) = _BannerSectionBlock;

  factory BannerSectionBlock.fromJson(Map<String, dynamic> json) =>
      _$BannerSectionBlockFromJson(json);
}

/// Union type for lobby sections - uses custom fromJson/toJson
sealed class LobbySectionBlock {
  const LobbySectionBlock();

  factory LobbySectionBlock.fromJson(Map<String, dynamic> json) {
    final blockType = json['blockType'] as String?;
    switch (blockType) {
      case 'carousel-section':
        return CarouselSection(CarouselSectionBlock.fromJson(json));
      case 'suggested-games-section':
        return SuggestedGamesSection(SuggestedGamesSectionBlock.fromJson(json));
      case 'game-grid-section':
        return GameGridSection(GameGridSectionBlock.fromJson(json));
      case 'banner-section':
        return BannerSection(BannerSectionBlock.fromJson(json));
      default:
        throw ArgumentError('Unknown block type: $blockType');
    }
  }

  Map<String, dynamic> toJson();
}

class CarouselSection extends LobbySectionBlock {
  final CarouselSectionBlock data;
  const CarouselSection(this.data);

  @override
  Map<String, dynamic> toJson() => data.toJson();
}

class SuggestedGamesSection extends LobbySectionBlock {
  final SuggestedGamesSectionBlock data;
  const SuggestedGamesSection(this.data);

  @override
  Map<String, dynamic> toJson() => data.toJson();
}

class GameGridSection extends LobbySectionBlock {
  final GameGridSectionBlock data;
  const GameGridSection(this.data);

  @override
  Map<String, dynamic> toJson() => data.toJson();
}

class BannerSection extends LobbySectionBlock {
  final BannerSectionBlock data;
  const BannerSection(this.data);

  @override
  Map<String, dynamic> toJson() => data.toJson();
}

/// JSON converter for List<LobbySectionBlock>
class LobbySectionBlockListConverter
    implements JsonConverter<List<LobbySectionBlock>, List<dynamic>> {
  const LobbySectionBlockListConverter();

  @override
  List<LobbySectionBlock> fromJson(List<dynamic> json) {
    return json
        .map((e) => LobbySectionBlock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<dynamic> toJson(List<LobbySectionBlock> object) {
    return object.map((e) => e.toJson()).toList();
  }
}

@freezed
class LobbyLayout with _$LobbyLayout {
  const factory LobbyLayout({
    required String id,
    required String slug,
    required String name,
    required Platform platform,
    @Default(false) bool isDefault,
    @LobbySectionBlockListConverter() required List<LobbySectionBlock> sections,
    String? createdAt,
    String? updatedAt,
  }) = _LobbyLayout;

  factory LobbyLayout.fromJson(Map<String, dynamic> json) =>
      _$LobbyLayoutFromJson(json);
}
