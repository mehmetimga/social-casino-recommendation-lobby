import 'package:freezed_annotation/freezed_annotation.dart';
import 'media.dart';

part 'game.freezed.dart';
part 'game.g.dart';

enum GameType {
  @JsonValue('slot')
  slot,
  @JsonValue('table')
  table,
  @JsonValue('live')
  live,
  @JsonValue('instant')
  instant,
}

enum GameStatus {
  @JsonValue('enabled')
  enabled,
  @JsonValue('disabled')
  disabled,
}

enum BadgeType {
  @JsonValue('new')
  newBadge,
  @JsonValue('exclusive')
  exclusive,
  @JsonValue('hot')
  hot,
  @JsonValue('jackpot')
  jackpot,
  @JsonValue('featured')
  featured,
}

enum Volatility {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

@freezed
class GameTag with _$GameTag {
  const factory GameTag({
    required String tag,
  }) = _GameTag;

  factory GameTag.fromJson(Map<String, dynamic> json) =>
      _$GameTagFromJson(json);
}

@freezed
class GameGalleryImage with _$GameGalleryImage {
  const factory GameGalleryImage({
    required Media image,
  }) = _GameGalleryImage;

  factory GameGalleryImage.fromJson(Map<String, dynamic> json) =>
      _$GameGalleryImageFromJson(json);
}

@freezed
class Game with _$Game {
  const factory Game({
    required String id,
    required String slug,
    required String title,
    required String provider,
    required GameType type,
    List<GameTag>? tags,
    required Media thumbnail,
    Media? heroImage,
    List<GameGalleryImage>? gallery,
    String? shortDescription,
    dynamic fullDescription,
    @Default(0) int popularityScore,
    double? jackpotAmount,
    @Default(0.1) double minBet,
    @Default(100) double maxBet,
    double? rtp,
    Volatility? volatility,
    List<BadgeType>? badges,
    required GameStatus status,
    required String createdAt,
    required String updatedAt,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

@freezed
class GameFilters with _$GameFilters {
  const factory GameFilters({
    GameType? type,
    List<String>? tags,
    List<BadgeType>? badges,
    int? minPopularity,
    int? limit,
    int? page,
  }) = _GameFilters;

  factory GameFilters.fromJson(Map<String, dynamic> json) =>
      _$GameFiltersFromJson(json);
}

@freezed
class PaginatedGames with _$PaginatedGames {
  const factory PaginatedGames({
    required List<Game> docs,
    required int totalDocs,
    required int limit,
    required int page,
    required int totalPages,
    required bool hasNextPage,
    required bool hasPrevPage,
  }) = _PaginatedGames;

  factory PaginatedGames.fromJson(Map<String, dynamic> json) =>
      _$PaginatedGamesFromJson(json);
}
