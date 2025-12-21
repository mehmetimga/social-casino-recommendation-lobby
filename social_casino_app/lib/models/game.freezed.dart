// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameTag _$GameTagFromJson(Map<String, dynamic> json) {
  return _GameTag.fromJson(json);
}

/// @nodoc
mixin _$GameTag {
  String get tag => throw _privateConstructorUsedError;

  /// Serializes this GameTag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameTagCopyWith<GameTag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameTagCopyWith<$Res> {
  factory $GameTagCopyWith(GameTag value, $Res Function(GameTag) then) =
      _$GameTagCopyWithImpl<$Res, GameTag>;
  @useResult
  $Res call({String tag});
}

/// @nodoc
class _$GameTagCopyWithImpl<$Res, $Val extends GameTag>
    implements $GameTagCopyWith<$Res> {
  _$GameTagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tag = null}) {
    return _then(
      _value.copyWith(
            tag: null == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameTagImplCopyWith<$Res> implements $GameTagCopyWith<$Res> {
  factory _$$GameTagImplCopyWith(
    _$GameTagImpl value,
    $Res Function(_$GameTagImpl) then,
  ) = __$$GameTagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tag});
}

/// @nodoc
class __$$GameTagImplCopyWithImpl<$Res>
    extends _$GameTagCopyWithImpl<$Res, _$GameTagImpl>
    implements _$$GameTagImplCopyWith<$Res> {
  __$$GameTagImplCopyWithImpl(
    _$GameTagImpl _value,
    $Res Function(_$GameTagImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameTag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? tag = null}) {
    return _then(
      _$GameTagImpl(
        tag: null == tag
            ? _value.tag
            : tag // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameTagImpl implements _GameTag {
  const _$GameTagImpl({required this.tag});

  factory _$GameTagImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameTagImplFromJson(json);

  @override
  final String tag;

  @override
  String toString() {
    return 'GameTag(tag: $tag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameTagImpl &&
            (identical(other.tag, tag) || other.tag == tag));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tag);

  /// Create a copy of GameTag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameTagImplCopyWith<_$GameTagImpl> get copyWith =>
      __$$GameTagImplCopyWithImpl<_$GameTagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameTagImplToJson(this);
  }
}

abstract class _GameTag implements GameTag {
  const factory _GameTag({required final String tag}) = _$GameTagImpl;

  factory _GameTag.fromJson(Map<String, dynamic> json) = _$GameTagImpl.fromJson;

  @override
  String get tag;

  /// Create a copy of GameTag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameTagImplCopyWith<_$GameTagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameGalleryImage _$GameGalleryImageFromJson(Map<String, dynamic> json) {
  return _GameGalleryImage.fromJson(json);
}

/// @nodoc
mixin _$GameGalleryImage {
  Media get image => throw _privateConstructorUsedError;

  /// Serializes this GameGalleryImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameGalleryImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameGalleryImageCopyWith<GameGalleryImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameGalleryImageCopyWith<$Res> {
  factory $GameGalleryImageCopyWith(
    GameGalleryImage value,
    $Res Function(GameGalleryImage) then,
  ) = _$GameGalleryImageCopyWithImpl<$Res, GameGalleryImage>;
  @useResult
  $Res call({Media image});

  $MediaCopyWith<$Res> get image;
}

/// @nodoc
class _$GameGalleryImageCopyWithImpl<$Res, $Val extends GameGalleryImage>
    implements $GameGalleryImageCopyWith<$Res> {
  _$GameGalleryImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameGalleryImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? image = null}) {
    return _then(
      _value.copyWith(
            image: null == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as Media,
          )
          as $Val,
    );
  }

  /// Create a copy of GameGalleryImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaCopyWith<$Res> get image {
    return $MediaCopyWith<$Res>(_value.image, (value) {
      return _then(_value.copyWith(image: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameGalleryImageImplCopyWith<$Res>
    implements $GameGalleryImageCopyWith<$Res> {
  factory _$$GameGalleryImageImplCopyWith(
    _$GameGalleryImageImpl value,
    $Res Function(_$GameGalleryImageImpl) then,
  ) = __$$GameGalleryImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Media image});

  @override
  $MediaCopyWith<$Res> get image;
}

/// @nodoc
class __$$GameGalleryImageImplCopyWithImpl<$Res>
    extends _$GameGalleryImageCopyWithImpl<$Res, _$GameGalleryImageImpl>
    implements _$$GameGalleryImageImplCopyWith<$Res> {
  __$$GameGalleryImageImplCopyWithImpl(
    _$GameGalleryImageImpl _value,
    $Res Function(_$GameGalleryImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameGalleryImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? image = null}) {
    return _then(
      _$GameGalleryImageImpl(
        image: null == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as Media,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameGalleryImageImpl implements _GameGalleryImage {
  const _$GameGalleryImageImpl({required this.image});

  factory _$GameGalleryImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameGalleryImageImplFromJson(json);

  @override
  final Media image;

  @override
  String toString() {
    return 'GameGalleryImage(image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameGalleryImageImpl &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, image);

  /// Create a copy of GameGalleryImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameGalleryImageImplCopyWith<_$GameGalleryImageImpl> get copyWith =>
      __$$GameGalleryImageImplCopyWithImpl<_$GameGalleryImageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameGalleryImageImplToJson(this);
  }
}

abstract class _GameGalleryImage implements GameGalleryImage {
  const factory _GameGalleryImage({required final Media image}) =
      _$GameGalleryImageImpl;

  factory _GameGalleryImage.fromJson(Map<String, dynamic> json) =
      _$GameGalleryImageImpl.fromJson;

  @override
  Media get image;

  /// Create a copy of GameGalleryImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameGalleryImageImplCopyWith<_$GameGalleryImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  String get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  GameType get type => throw _privateConstructorUsedError;
  List<GameTag>? get tags => throw _privateConstructorUsedError;
  Media get thumbnail => throw _privateConstructorUsedError;
  Media? get heroImage => throw _privateConstructorUsedError;
  List<GameGalleryImage>? get gallery => throw _privateConstructorUsedError;
  String? get shortDescription => throw _privateConstructorUsedError;
  dynamic get fullDescription => throw _privateConstructorUsedError;
  int get popularityScore => throw _privateConstructorUsedError;
  double? get jackpotAmount => throw _privateConstructorUsedError;
  double get minBet => throw _privateConstructorUsedError;
  double get maxBet => throw _privateConstructorUsedError;
  double? get rtp => throw _privateConstructorUsedError;
  Volatility? get volatility => throw _privateConstructorUsedError;
  List<BadgeType>? get badges => throw _privateConstructorUsedError;
  GameStatus get status => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call({
    String id,
    String slug,
    String title,
    String provider,
    GameType type,
    List<GameTag>? tags,
    Media thumbnail,
    Media? heroImage,
    List<GameGalleryImage>? gallery,
    String? shortDescription,
    dynamic fullDescription,
    int popularityScore,
    double? jackpotAmount,
    double minBet,
    double maxBet,
    double? rtp,
    Volatility? volatility,
    List<BadgeType>? badges,
    GameStatus status,
    String createdAt,
    String updatedAt,
  });

  $MediaCopyWith<$Res> get thumbnail;
  $MediaCopyWith<$Res>? get heroImage;
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? title = null,
    Object? provider = null,
    Object? type = null,
    Object? tags = freezed,
    Object? thumbnail = null,
    Object? heroImage = freezed,
    Object? gallery = freezed,
    Object? shortDescription = freezed,
    Object? fullDescription = freezed,
    Object? popularityScore = null,
    Object? jackpotAmount = freezed,
    Object? minBet = null,
    Object? maxBet = null,
    Object? rtp = freezed,
    Object? volatility = freezed,
    Object? badges = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            slug: null == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as GameType,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<GameTag>?,
            thumbnail: null == thumbnail
                ? _value.thumbnail
                : thumbnail // ignore: cast_nullable_to_non_nullable
                      as Media,
            heroImage: freezed == heroImage
                ? _value.heroImage
                : heroImage // ignore: cast_nullable_to_non_nullable
                      as Media?,
            gallery: freezed == gallery
                ? _value.gallery
                : gallery // ignore: cast_nullable_to_non_nullable
                      as List<GameGalleryImage>?,
            shortDescription: freezed == shortDescription
                ? _value.shortDescription
                : shortDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            fullDescription: freezed == fullDescription
                ? _value.fullDescription
                : fullDescription // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            popularityScore: null == popularityScore
                ? _value.popularityScore
                : popularityScore // ignore: cast_nullable_to_non_nullable
                      as int,
            jackpotAmount: freezed == jackpotAmount
                ? _value.jackpotAmount
                : jackpotAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            minBet: null == minBet
                ? _value.minBet
                : minBet // ignore: cast_nullable_to_non_nullable
                      as double,
            maxBet: null == maxBet
                ? _value.maxBet
                : maxBet // ignore: cast_nullable_to_non_nullable
                      as double,
            rtp: freezed == rtp
                ? _value.rtp
                : rtp // ignore: cast_nullable_to_non_nullable
                      as double?,
            volatility: freezed == volatility
                ? _value.volatility
                : volatility // ignore: cast_nullable_to_non_nullable
                      as Volatility?,
            badges: freezed == badges
                ? _value.badges
                : badges // ignore: cast_nullable_to_non_nullable
                      as List<BadgeType>?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GameStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaCopyWith<$Res> get thumbnail {
    return $MediaCopyWith<$Res>(_value.thumbnail, (value) {
      return _then(_value.copyWith(thumbnail: value) as $Val);
    });
  }

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaCopyWith<$Res>? get heroImage {
    if (_value.heroImage == null) {
      return null;
    }

    return $MediaCopyWith<$Res>(_value.heroImage!, (value) {
      return _then(_value.copyWith(heroImage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
    _$GameImpl value,
    $Res Function(_$GameImpl) then,
  ) = __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String slug,
    String title,
    String provider,
    GameType type,
    List<GameTag>? tags,
    Media thumbnail,
    Media? heroImage,
    List<GameGalleryImage>? gallery,
    String? shortDescription,
    dynamic fullDescription,
    int popularityScore,
    double? jackpotAmount,
    double minBet,
    double maxBet,
    double? rtp,
    Volatility? volatility,
    List<BadgeType>? badges,
    GameStatus status,
    String createdAt,
    String updatedAt,
  });

  @override
  $MediaCopyWith<$Res> get thumbnail;
  @override
  $MediaCopyWith<$Res>? get heroImage;
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
    : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? title = null,
    Object? provider = null,
    Object? type = null,
    Object? tags = freezed,
    Object? thumbnail = null,
    Object? heroImage = freezed,
    Object? gallery = freezed,
    Object? shortDescription = freezed,
    Object? fullDescription = freezed,
    Object? popularityScore = null,
    Object? jackpotAmount = freezed,
    Object? minBet = null,
    Object? maxBet = null,
    Object? rtp = freezed,
    Object? volatility = freezed,
    Object? badges = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$GameImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        slug: null == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as GameType,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<GameTag>?,
        thumbnail: null == thumbnail
            ? _value.thumbnail
            : thumbnail // ignore: cast_nullable_to_non_nullable
                  as Media,
        heroImage: freezed == heroImage
            ? _value.heroImage
            : heroImage // ignore: cast_nullable_to_non_nullable
                  as Media?,
        gallery: freezed == gallery
            ? _value._gallery
            : gallery // ignore: cast_nullable_to_non_nullable
                  as List<GameGalleryImage>?,
        shortDescription: freezed == shortDescription
            ? _value.shortDescription
            : shortDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        fullDescription: freezed == fullDescription
            ? _value.fullDescription
            : fullDescription // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        popularityScore: null == popularityScore
            ? _value.popularityScore
            : popularityScore // ignore: cast_nullable_to_non_nullable
                  as int,
        jackpotAmount: freezed == jackpotAmount
            ? _value.jackpotAmount
            : jackpotAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        minBet: null == minBet
            ? _value.minBet
            : minBet // ignore: cast_nullable_to_non_nullable
                  as double,
        maxBet: null == maxBet
            ? _value.maxBet
            : maxBet // ignore: cast_nullable_to_non_nullable
                  as double,
        rtp: freezed == rtp
            ? _value.rtp
            : rtp // ignore: cast_nullable_to_non_nullable
                  as double?,
        volatility: freezed == volatility
            ? _value.volatility
            : volatility // ignore: cast_nullable_to_non_nullable
                  as Volatility?,
        badges: freezed == badges
            ? _value._badges
            : badges // ignore: cast_nullable_to_non_nullable
                  as List<BadgeType>?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GameStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameImpl implements _Game {
  const _$GameImpl({
    required this.id,
    required this.slug,
    required this.title,
    required this.provider,
    required this.type,
    final List<GameTag>? tags,
    required this.thumbnail,
    this.heroImage,
    final List<GameGalleryImage>? gallery,
    this.shortDescription,
    this.fullDescription,
    this.popularityScore = 0,
    this.jackpotAmount,
    this.minBet = 0.1,
    this.maxBet = 100,
    this.rtp,
    this.volatility,
    final List<BadgeType>? badges,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags,
       _gallery = gallery,
       _badges = badges;

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  @override
  final String id;
  @override
  final String slug;
  @override
  final String title;
  @override
  final String provider;
  @override
  final GameType type;
  final List<GameTag>? _tags;
  @override
  List<GameTag>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Media thumbnail;
  @override
  final Media? heroImage;
  final List<GameGalleryImage>? _gallery;
  @override
  List<GameGalleryImage>? get gallery {
    final value = _gallery;
    if (value == null) return null;
    if (_gallery is EqualUnmodifiableListView) return _gallery;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? shortDescription;
  @override
  final dynamic fullDescription;
  @override
  @JsonKey()
  final int popularityScore;
  @override
  final double? jackpotAmount;
  @override
  @JsonKey()
  final double minBet;
  @override
  @JsonKey()
  final double maxBet;
  @override
  final double? rtp;
  @override
  final Volatility? volatility;
  final List<BadgeType>? _badges;
  @override
  List<BadgeType>? get badges {
    final value = _badges;
    if (value == null) return null;
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final GameStatus status;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'Game(id: $id, slug: $slug, title: $title, provider: $provider, type: $type, tags: $tags, thumbnail: $thumbnail, heroImage: $heroImage, gallery: $gallery, shortDescription: $shortDescription, fullDescription: $fullDescription, popularityScore: $popularityScore, jackpotAmount: $jackpotAmount, minBet: $minBet, maxBet: $maxBet, rtp: $rtp, volatility: $volatility, badges: $badges, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.heroImage, heroImage) ||
                other.heroImage == heroImage) &&
            const DeepCollectionEquality().equals(other._gallery, _gallery) &&
            (identical(other.shortDescription, shortDescription) ||
                other.shortDescription == shortDescription) &&
            const DeepCollectionEquality().equals(
              other.fullDescription,
              fullDescription,
            ) &&
            (identical(other.popularityScore, popularityScore) ||
                other.popularityScore == popularityScore) &&
            (identical(other.jackpotAmount, jackpotAmount) ||
                other.jackpotAmount == jackpotAmount) &&
            (identical(other.minBet, minBet) || other.minBet == minBet) &&
            (identical(other.maxBet, maxBet) || other.maxBet == maxBet) &&
            (identical(other.rtp, rtp) || other.rtp == rtp) &&
            (identical(other.volatility, volatility) ||
                other.volatility == volatility) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    slug,
    title,
    provider,
    type,
    const DeepCollectionEquality().hash(_tags),
    thumbnail,
    heroImage,
    const DeepCollectionEquality().hash(_gallery),
    shortDescription,
    const DeepCollectionEquality().hash(fullDescription),
    popularityScore,
    jackpotAmount,
    minBet,
    maxBet,
    rtp,
    volatility,
    const DeepCollectionEquality().hash(_badges),
    status,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(this);
  }
}

abstract class _Game implements Game {
  const factory _Game({
    required final String id,
    required final String slug,
    required final String title,
    required final String provider,
    required final GameType type,
    final List<GameTag>? tags,
    required final Media thumbnail,
    final Media? heroImage,
    final List<GameGalleryImage>? gallery,
    final String? shortDescription,
    final dynamic fullDescription,
    final int popularityScore,
    final double? jackpotAmount,
    final double minBet,
    final double maxBet,
    final double? rtp,
    final Volatility? volatility,
    final List<BadgeType>? badges,
    required final GameStatus status,
    required final String createdAt,
    required final String updatedAt,
  }) = _$GameImpl;

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  @override
  String get id;
  @override
  String get slug;
  @override
  String get title;
  @override
  String get provider;
  @override
  GameType get type;
  @override
  List<GameTag>? get tags;
  @override
  Media get thumbnail;
  @override
  Media? get heroImage;
  @override
  List<GameGalleryImage>? get gallery;
  @override
  String? get shortDescription;
  @override
  dynamic get fullDescription;
  @override
  int get popularityScore;
  @override
  double? get jackpotAmount;
  @override
  double get minBet;
  @override
  double get maxBet;
  @override
  double? get rtp;
  @override
  Volatility? get volatility;
  @override
  List<BadgeType>? get badges;
  @override
  GameStatus get status;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameFilters _$GameFiltersFromJson(Map<String, dynamic> json) {
  return _GameFilters.fromJson(json);
}

/// @nodoc
mixin _$GameFilters {
  GameType? get type => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  List<BadgeType>? get badges => throw _privateConstructorUsedError;
  int? get minPopularity => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  int? get page => throw _privateConstructorUsedError;

  /// Serializes this GameFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameFiltersCopyWith<GameFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameFiltersCopyWith<$Res> {
  factory $GameFiltersCopyWith(
    GameFilters value,
    $Res Function(GameFilters) then,
  ) = _$GameFiltersCopyWithImpl<$Res, GameFilters>;
  @useResult
  $Res call({
    GameType? type,
    List<String>? tags,
    List<BadgeType>? badges,
    int? minPopularity,
    int? limit,
    int? page,
  });
}

/// @nodoc
class _$GameFiltersCopyWithImpl<$Res, $Val extends GameFilters>
    implements $GameFiltersCopyWith<$Res> {
  _$GameFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? tags = freezed,
    Object? badges = freezed,
    Object? minPopularity = freezed,
    Object? limit = freezed,
    Object? page = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as GameType?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            badges: freezed == badges
                ? _value.badges
                : badges // ignore: cast_nullable_to_non_nullable
                      as List<BadgeType>?,
            minPopularity: freezed == minPopularity
                ? _value.minPopularity
                : minPopularity // ignore: cast_nullable_to_non_nullable
                      as int?,
            limit: freezed == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int?,
            page: freezed == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameFiltersImplCopyWith<$Res>
    implements $GameFiltersCopyWith<$Res> {
  factory _$$GameFiltersImplCopyWith(
    _$GameFiltersImpl value,
    $Res Function(_$GameFiltersImpl) then,
  ) = __$$GameFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    GameType? type,
    List<String>? tags,
    List<BadgeType>? badges,
    int? minPopularity,
    int? limit,
    int? page,
  });
}

/// @nodoc
class __$$GameFiltersImplCopyWithImpl<$Res>
    extends _$GameFiltersCopyWithImpl<$Res, _$GameFiltersImpl>
    implements _$$GameFiltersImplCopyWith<$Res> {
  __$$GameFiltersImplCopyWithImpl(
    _$GameFiltersImpl _value,
    $Res Function(_$GameFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
    Object? tags = freezed,
    Object? badges = freezed,
    Object? minPopularity = freezed,
    Object? limit = freezed,
    Object? page = freezed,
  }) {
    return _then(
      _$GameFiltersImpl(
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as GameType?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        badges: freezed == badges
            ? _value._badges
            : badges // ignore: cast_nullable_to_non_nullable
                  as List<BadgeType>?,
        minPopularity: freezed == minPopularity
            ? _value.minPopularity
            : minPopularity // ignore: cast_nullable_to_non_nullable
                  as int?,
        limit: freezed == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int?,
        page: freezed == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameFiltersImpl implements _GameFilters {
  const _$GameFiltersImpl({
    this.type,
    final List<String>? tags,
    final List<BadgeType>? badges,
    this.minPopularity,
    this.limit,
    this.page,
  }) : _tags = tags,
       _badges = badges;

  factory _$GameFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameFiltersImplFromJson(json);

  @override
  final GameType? type;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<BadgeType>? _badges;
  @override
  List<BadgeType>? get badges {
    final value = _badges;
    if (value == null) return null;
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? minPopularity;
  @override
  final int? limit;
  @override
  final int? page;

  @override
  String toString() {
    return 'GameFilters(type: $type, tags: $tags, badges: $badges, minPopularity: $minPopularity, limit: $limit, page: $page)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameFiltersImpl &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            (identical(other.minPopularity, minPopularity) ||
                other.minPopularity == minPopularity) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.page, page) || other.page == page));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_badges),
    minPopularity,
    limit,
    page,
  );

  /// Create a copy of GameFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameFiltersImplCopyWith<_$GameFiltersImpl> get copyWith =>
      __$$GameFiltersImplCopyWithImpl<_$GameFiltersImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameFiltersImplToJson(this);
  }
}

abstract class _GameFilters implements GameFilters {
  const factory _GameFilters({
    final GameType? type,
    final List<String>? tags,
    final List<BadgeType>? badges,
    final int? minPopularity,
    final int? limit,
    final int? page,
  }) = _$GameFiltersImpl;

  factory _GameFilters.fromJson(Map<String, dynamic> json) =
      _$GameFiltersImpl.fromJson;

  @override
  GameType? get type;
  @override
  List<String>? get tags;
  @override
  List<BadgeType>? get badges;
  @override
  int? get minPopularity;
  @override
  int? get limit;
  @override
  int? get page;

  /// Create a copy of GameFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameFiltersImplCopyWith<_$GameFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaginatedGames _$PaginatedGamesFromJson(Map<String, dynamic> json) {
  return _PaginatedGames.fromJson(json);
}

/// @nodoc
mixin _$PaginatedGames {
  List<Game> get docs => throw _privateConstructorUsedError;
  int get totalDocs => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;
  bool get hasPrevPage => throw _privateConstructorUsedError;

  /// Serializes this PaginatedGames to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedGames
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedGamesCopyWith<PaginatedGames> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedGamesCopyWith<$Res> {
  factory $PaginatedGamesCopyWith(
    PaginatedGames value,
    $Res Function(PaginatedGames) then,
  ) = _$PaginatedGamesCopyWithImpl<$Res, PaginatedGames>;
  @useResult
  $Res call({
    List<Game> docs,
    int totalDocs,
    int limit,
    int page,
    int totalPages,
    bool hasNextPage,
    bool hasPrevPage,
  });
}

/// @nodoc
class _$PaginatedGamesCopyWithImpl<$Res, $Val extends PaginatedGames>
    implements $PaginatedGamesCopyWith<$Res> {
  _$PaginatedGamesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedGames
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? docs = null,
    Object? totalDocs = null,
    Object? limit = null,
    Object? page = null,
    Object? totalPages = null,
    Object? hasNextPage = null,
    Object? hasPrevPage = null,
  }) {
    return _then(
      _value.copyWith(
            docs: null == docs
                ? _value.docs
                : docs // ignore: cast_nullable_to_non_nullable
                      as List<Game>,
            totalDocs: null == totalDocs
                ? _value.totalDocs
                : totalDocs // ignore: cast_nullable_to_non_nullable
                      as int,
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNextPage: null == hasNextPage
                ? _value.hasNextPage
                : hasNextPage // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPrevPage: null == hasPrevPage
                ? _value.hasPrevPage
                : hasPrevPage // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginatedGamesImplCopyWith<$Res>
    implements $PaginatedGamesCopyWith<$Res> {
  factory _$$PaginatedGamesImplCopyWith(
    _$PaginatedGamesImpl value,
    $Res Function(_$PaginatedGamesImpl) then,
  ) = __$$PaginatedGamesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Game> docs,
    int totalDocs,
    int limit,
    int page,
    int totalPages,
    bool hasNextPage,
    bool hasPrevPage,
  });
}

/// @nodoc
class __$$PaginatedGamesImplCopyWithImpl<$Res>
    extends _$PaginatedGamesCopyWithImpl<$Res, _$PaginatedGamesImpl>
    implements _$$PaginatedGamesImplCopyWith<$Res> {
  __$$PaginatedGamesImplCopyWithImpl(
    _$PaginatedGamesImpl _value,
    $Res Function(_$PaginatedGamesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedGames
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? docs = null,
    Object? totalDocs = null,
    Object? limit = null,
    Object? page = null,
    Object? totalPages = null,
    Object? hasNextPage = null,
    Object? hasPrevPage = null,
  }) {
    return _then(
      _$PaginatedGamesImpl(
        docs: null == docs
            ? _value._docs
            : docs // ignore: cast_nullable_to_non_nullable
                  as List<Game>,
        totalDocs: null == totalDocs
            ? _value.totalDocs
            : totalDocs // ignore: cast_nullable_to_non_nullable
                  as int,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNextPage: null == hasNextPage
            ? _value.hasNextPage
            : hasNextPage // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPrevPage: null == hasPrevPage
            ? _value.hasPrevPage
            : hasPrevPage // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaginatedGamesImpl implements _PaginatedGames {
  const _$PaginatedGamesImpl({
    required final List<Game> docs,
    required this.totalDocs,
    required this.limit,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  }) : _docs = docs;

  factory _$PaginatedGamesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginatedGamesImplFromJson(json);

  final List<Game> _docs;
  @override
  List<Game> get docs {
    if (_docs is EqualUnmodifiableListView) return _docs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_docs);
  }

  @override
  final int totalDocs;
  @override
  final int limit;
  @override
  final int page;
  @override
  final int totalPages;
  @override
  final bool hasNextPage;
  @override
  final bool hasPrevPage;

  @override
  String toString() {
    return 'PaginatedGames(docs: $docs, totalDocs: $totalDocs, limit: $limit, page: $page, totalPages: $totalPages, hasNextPage: $hasNextPage, hasPrevPage: $hasPrevPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedGamesImpl &&
            const DeepCollectionEquality().equals(other._docs, _docs) &&
            (identical(other.totalDocs, totalDocs) ||
                other.totalDocs == totalDocs) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage) &&
            (identical(other.hasPrevPage, hasPrevPage) ||
                other.hasPrevPage == hasPrevPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_docs),
    totalDocs,
    limit,
    page,
    totalPages,
    hasNextPage,
    hasPrevPage,
  );

  /// Create a copy of PaginatedGames
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedGamesImplCopyWith<_$PaginatedGamesImpl> get copyWith =>
      __$$PaginatedGamesImplCopyWithImpl<_$PaginatedGamesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginatedGamesImplToJson(this);
  }
}

abstract class _PaginatedGames implements PaginatedGames {
  const factory _PaginatedGames({
    required final List<Game> docs,
    required final int totalDocs,
    required final int limit,
    required final int page,
    required final int totalPages,
    required final bool hasNextPage,
    required final bool hasPrevPage,
  }) = _$PaginatedGamesImpl;

  factory _PaginatedGames.fromJson(Map<String, dynamic> json) =
      _$PaginatedGamesImpl.fromJson;

  @override
  List<Game> get docs;
  @override
  int get totalDocs;
  @override
  int get limit;
  @override
  int get page;
  @override
  int get totalPages;
  @override
  bool get hasNextPage;
  @override
  bool get hasPrevPage;

  /// Create a copy of PaginatedGames
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedGamesImplCopyWith<_$PaginatedGamesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
