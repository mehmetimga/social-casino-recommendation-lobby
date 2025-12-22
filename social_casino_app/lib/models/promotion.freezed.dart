// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promotion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CtaLink _$CtaLinkFromJson(Map<String, dynamic> json) {
  return _CtaLink.fromJson(json);
}

/// @nodoc
mixin _$CtaLink {
  CtaLinkType get type => throw _privateConstructorUsedError;
  String? get game => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  /// Serializes this CtaLink to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CtaLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CtaLinkCopyWith<CtaLink> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CtaLinkCopyWith<$Res> {
  factory $CtaLinkCopyWith(CtaLink value, $Res Function(CtaLink) then) =
      _$CtaLinkCopyWithImpl<$Res, CtaLink>;
  @useResult
  $Res call({CtaLinkType type, String? game, String? url, String? category});
}

/// @nodoc
class _$CtaLinkCopyWithImpl<$Res, $Val extends CtaLink>
    implements $CtaLinkCopyWith<$Res> {
  _$CtaLinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CtaLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? game = freezed,
    Object? url = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as CtaLinkType,
            game: freezed == game
                ? _value.game
                : game // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CtaLinkImplCopyWith<$Res> implements $CtaLinkCopyWith<$Res> {
  factory _$$CtaLinkImplCopyWith(
    _$CtaLinkImpl value,
    $Res Function(_$CtaLinkImpl) then,
  ) = __$$CtaLinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CtaLinkType type, String? game, String? url, String? category});
}

/// @nodoc
class __$$CtaLinkImplCopyWithImpl<$Res>
    extends _$CtaLinkCopyWithImpl<$Res, _$CtaLinkImpl>
    implements _$$CtaLinkImplCopyWith<$Res> {
  __$$CtaLinkImplCopyWithImpl(
    _$CtaLinkImpl _value,
    $Res Function(_$CtaLinkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CtaLink
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? game = freezed,
    Object? url = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _$CtaLinkImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CtaLinkType,
        game: freezed == game
            ? _value.game
            : game // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CtaLinkImpl implements _CtaLink {
  const _$CtaLinkImpl({required this.type, this.game, this.url, this.category});

  factory _$CtaLinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$CtaLinkImplFromJson(json);

  @override
  final CtaLinkType type;
  @override
  final String? game;
  @override
  final String? url;
  @override
  final String? category;

  @override
  String toString() {
    return 'CtaLink(type: $type, game: $game, url: $url, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CtaLinkImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.game, game) || other.game == game) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, game, url, category);

  /// Create a copy of CtaLink
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CtaLinkImplCopyWith<_$CtaLinkImpl> get copyWith =>
      __$$CtaLinkImplCopyWithImpl<_$CtaLinkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CtaLinkImplToJson(this);
  }
}

abstract class _CtaLink implements CtaLink {
  const factory _CtaLink({
    required final CtaLinkType type,
    final String? game,
    final String? url,
    final String? category,
  }) = _$CtaLinkImpl;

  factory _CtaLink.fromJson(Map<String, dynamic> json) = _$CtaLinkImpl.fromJson;

  @override
  CtaLinkType get type;
  @override
  String? get game;
  @override
  String? get url;
  @override
  String? get category;

  /// Create a copy of CtaLink
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CtaLinkImplCopyWith<_$CtaLinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PromotionSchedule _$PromotionScheduleFromJson(Map<String, dynamic> json) {
  return _PromotionSchedule.fromJson(json);
}

/// @nodoc
mixin _$PromotionSchedule {
  String? get startDate => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;

  /// Serializes this PromotionSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromotionSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromotionScheduleCopyWith<PromotionSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromotionScheduleCopyWith<$Res> {
  factory $PromotionScheduleCopyWith(
    PromotionSchedule value,
    $Res Function(PromotionSchedule) then,
  ) = _$PromotionScheduleCopyWithImpl<$Res, PromotionSchedule>;
  @useResult
  $Res call({String? startDate, String? endDate});
}

/// @nodoc
class _$PromotionScheduleCopyWithImpl<$Res, $Val extends PromotionSchedule>
    implements $PromotionScheduleCopyWith<$Res> {
  _$PromotionScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromotionSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? startDate = freezed, Object? endDate = freezed}) {
    return _then(
      _value.copyWith(
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromotionScheduleImplCopyWith<$Res>
    implements $PromotionScheduleCopyWith<$Res> {
  factory _$$PromotionScheduleImplCopyWith(
    _$PromotionScheduleImpl value,
    $Res Function(_$PromotionScheduleImpl) then,
  ) = __$$PromotionScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? startDate, String? endDate});
}

/// @nodoc
class __$$PromotionScheduleImplCopyWithImpl<$Res>
    extends _$PromotionScheduleCopyWithImpl<$Res, _$PromotionScheduleImpl>
    implements _$$PromotionScheduleImplCopyWith<$Res> {
  __$$PromotionScheduleImplCopyWithImpl(
    _$PromotionScheduleImpl _value,
    $Res Function(_$PromotionScheduleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PromotionSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? startDate = freezed, Object? endDate = freezed}) {
    return _then(
      _$PromotionScheduleImpl(
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromotionScheduleImpl implements _PromotionSchedule {
  const _$PromotionScheduleImpl({this.startDate, this.endDate});

  factory _$PromotionScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromotionScheduleImplFromJson(json);

  @override
  final String? startDate;
  @override
  final String? endDate;

  @override
  String toString() {
    return 'PromotionSchedule(startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromotionScheduleImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate);

  /// Create a copy of PromotionSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromotionScheduleImplCopyWith<_$PromotionScheduleImpl> get copyWith =>
      __$$PromotionScheduleImplCopyWithImpl<_$PromotionScheduleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PromotionScheduleImplToJson(this);
  }
}

abstract class _PromotionSchedule implements PromotionSchedule {
  const factory _PromotionSchedule({
    final String? startDate,
    final String? endDate,
  }) = _$PromotionScheduleImpl;

  factory _PromotionSchedule.fromJson(Map<String, dynamic> json) =
      _$PromotionScheduleImpl.fromJson;

  @override
  String? get startDate;
  @override
  String? get endDate;

  /// Create a copy of PromotionSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromotionScheduleImplCopyWith<_$PromotionScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PromotionCountdown _$PromotionCountdownFromJson(Map<String, dynamic> json) {
  return _PromotionCountdown.fromJson(json);
}

/// @nodoc
mixin _$PromotionCountdown {
  bool get enabled => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;

  /// Serializes this PromotionCountdown to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromotionCountdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromotionCountdownCopyWith<PromotionCountdown> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromotionCountdownCopyWith<$Res> {
  factory $PromotionCountdownCopyWith(
    PromotionCountdown value,
    $Res Function(PromotionCountdown) then,
  ) = _$PromotionCountdownCopyWithImpl<$Res, PromotionCountdown>;
  @useResult
  $Res call({bool enabled, String? endTime, String? label});
}

/// @nodoc
class _$PromotionCountdownCopyWithImpl<$Res, $Val extends PromotionCountdown>
    implements $PromotionCountdownCopyWith<$Res> {
  _$PromotionCountdownCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromotionCountdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? endTime = freezed,
    Object? label = freezed,
  }) {
    return _then(
      _value.copyWith(
            enabled: null == enabled
                ? _value.enabled
                : enabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromotionCountdownImplCopyWith<$Res>
    implements $PromotionCountdownCopyWith<$Res> {
  factory _$$PromotionCountdownImplCopyWith(
    _$PromotionCountdownImpl value,
    $Res Function(_$PromotionCountdownImpl) then,
  ) = __$$PromotionCountdownImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool enabled, String? endTime, String? label});
}

/// @nodoc
class __$$PromotionCountdownImplCopyWithImpl<$Res>
    extends _$PromotionCountdownCopyWithImpl<$Res, _$PromotionCountdownImpl>
    implements _$$PromotionCountdownImplCopyWith<$Res> {
  __$$PromotionCountdownImplCopyWithImpl(
    _$PromotionCountdownImpl _value,
    $Res Function(_$PromotionCountdownImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PromotionCountdown
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
    Object? endTime = freezed,
    Object? label = freezed,
  }) {
    return _then(
      _$PromotionCountdownImpl(
        enabled: null == enabled
            ? _value.enabled
            : enabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromotionCountdownImpl implements _PromotionCountdown {
  const _$PromotionCountdownImpl({
    this.enabled = false,
    this.endTime,
    this.label,
  });

  factory _$PromotionCountdownImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromotionCountdownImplFromJson(json);

  @override
  @JsonKey()
  final bool enabled;
  @override
  final String? endTime;
  @override
  final String? label;

  @override
  String toString() {
    return 'PromotionCountdown(enabled: $enabled, endTime: $endTime, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromotionCountdownImpl &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, enabled, endTime, label);

  /// Create a copy of PromotionCountdown
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromotionCountdownImplCopyWith<_$PromotionCountdownImpl> get copyWith =>
      __$$PromotionCountdownImplCopyWithImpl<_$PromotionCountdownImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PromotionCountdownImplToJson(this);
  }
}

abstract class _PromotionCountdown implements PromotionCountdown {
  const factory _PromotionCountdown({
    final bool enabled,
    final String? endTime,
    final String? label,
  }) = _$PromotionCountdownImpl;

  factory _PromotionCountdown.fromJson(Map<String, dynamic> json) =
      _$PromotionCountdownImpl.fromJson;

  @override
  bool get enabled;
  @override
  String? get endTime;
  @override
  String? get label;

  /// Create a copy of PromotionCountdown
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromotionCountdownImplCopyWith<_$PromotionCountdownImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Promotion _$PromotionFromJson(Map<String, dynamic> json) {
  return _Promotion.fromJson(json);
}

/// @nodoc
mixin _$Promotion {
  String get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Media? get image => throw _privateConstructorUsedError;
  Media? get backgroundImage => throw _privateConstructorUsedError;
  bool get showOverlay => throw _privateConstructorUsedError;
  String get ctaText => throw _privateConstructorUsedError;
  CtaLink? get ctaLink => throw _privateConstructorUsedError;
  PromotionSchedule? get schedule => throw _privateConstructorUsedError;
  PromotionCountdown? get countdown => throw _privateConstructorUsedError;
  PromotionStatus get status => throw _privateConstructorUsedError;
  PromotionPlacement get placement => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Promotion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromotionCopyWith<Promotion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromotionCopyWith<$Res> {
  factory $PromotionCopyWith(Promotion value, $Res Function(Promotion) then) =
      _$PromotionCopyWithImpl<$Res, Promotion>;
  @useResult
  $Res call({
    String id,
    String slug,
    String title,
    String? subtitle,
    String? description,
    Media? image,
    Media? backgroundImage,
    bool showOverlay,
    String ctaText,
    CtaLink? ctaLink,
    PromotionSchedule? schedule,
    PromotionCountdown? countdown,
    PromotionStatus status,
    PromotionPlacement placement,
    int priority,
    String? createdAt,
    String? updatedAt,
  });

  $MediaCopyWith<$Res>? get image;
  $MediaCopyWith<$Res>? get backgroundImage;
  $CtaLinkCopyWith<$Res>? get ctaLink;
  $PromotionScheduleCopyWith<$Res>? get schedule;
  $PromotionCountdownCopyWith<$Res>? get countdown;
}

/// @nodoc
class _$PromotionCopyWithImpl<$Res, $Val extends Promotion>
    implements $PromotionCopyWith<$Res> {
  _$PromotionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? backgroundImage = freezed,
    Object? showOverlay = null,
    Object? ctaText = null,
    Object? ctaLink = freezed,
    Object? schedule = freezed,
    Object? countdown = freezed,
    Object? status = null,
    Object? placement = null,
    Object? priority = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
            subtitle: freezed == subtitle
                ? _value.subtitle
                : subtitle // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as Media?,
            backgroundImage: freezed == backgroundImage
                ? _value.backgroundImage
                : backgroundImage // ignore: cast_nullable_to_non_nullable
                      as Media?,
            showOverlay: null == showOverlay
                ? _value.showOverlay
                : showOverlay // ignore: cast_nullable_to_non_nullable
                      as bool,
            ctaText: null == ctaText
                ? _value.ctaText
                : ctaText // ignore: cast_nullable_to_non_nullable
                      as String,
            ctaLink: freezed == ctaLink
                ? _value.ctaLink
                : ctaLink // ignore: cast_nullable_to_non_nullable
                      as CtaLink?,
            schedule: freezed == schedule
                ? _value.schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                      as PromotionSchedule?,
            countdown: freezed == countdown
                ? _value.countdown
                : countdown // ignore: cast_nullable_to_non_nullable
                      as PromotionCountdown?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PromotionStatus,
            placement: null == placement
                ? _value.placement
                : placement // ignore: cast_nullable_to_non_nullable
                      as PromotionPlacement,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaCopyWith<$Res>? get image {
    if (_value.image == null) {
      return null;
    }

    return $MediaCopyWith<$Res>(_value.image!, (value) {
      return _then(_value.copyWith(image: value) as $Val);
    });
  }

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaCopyWith<$Res>? get backgroundImage {
    if (_value.backgroundImage == null) {
      return null;
    }

    return $MediaCopyWith<$Res>(_value.backgroundImage!, (value) {
      return _then(_value.copyWith(backgroundImage: value) as $Val);
    });
  }

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CtaLinkCopyWith<$Res>? get ctaLink {
    if (_value.ctaLink == null) {
      return null;
    }

    return $CtaLinkCopyWith<$Res>(_value.ctaLink!, (value) {
      return _then(_value.copyWith(ctaLink: value) as $Val);
    });
  }

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PromotionScheduleCopyWith<$Res>? get schedule {
    if (_value.schedule == null) {
      return null;
    }

    return $PromotionScheduleCopyWith<$Res>(_value.schedule!, (value) {
      return _then(_value.copyWith(schedule: value) as $Val);
    });
  }

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PromotionCountdownCopyWith<$Res>? get countdown {
    if (_value.countdown == null) {
      return null;
    }

    return $PromotionCountdownCopyWith<$Res>(_value.countdown!, (value) {
      return _then(_value.copyWith(countdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PromotionImplCopyWith<$Res>
    implements $PromotionCopyWith<$Res> {
  factory _$$PromotionImplCopyWith(
    _$PromotionImpl value,
    $Res Function(_$PromotionImpl) then,
  ) = __$$PromotionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String slug,
    String title,
    String? subtitle,
    String? description,
    Media? image,
    Media? backgroundImage,
    bool showOverlay,
    String ctaText,
    CtaLink? ctaLink,
    PromotionSchedule? schedule,
    PromotionCountdown? countdown,
    PromotionStatus status,
    PromotionPlacement placement,
    int priority,
    String? createdAt,
    String? updatedAt,
  });

  @override
  $MediaCopyWith<$Res>? get image;
  @override
  $MediaCopyWith<$Res>? get backgroundImage;
  @override
  $CtaLinkCopyWith<$Res>? get ctaLink;
  @override
  $PromotionScheduleCopyWith<$Res>? get schedule;
  @override
  $PromotionCountdownCopyWith<$Res>? get countdown;
}

/// @nodoc
class __$$PromotionImplCopyWithImpl<$Res>
    extends _$PromotionCopyWithImpl<$Res, _$PromotionImpl>
    implements _$$PromotionImplCopyWith<$Res> {
  __$$PromotionImplCopyWithImpl(
    _$PromotionImpl _value,
    $Res Function(_$PromotionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? title = null,
    Object? subtitle = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? backgroundImage = freezed,
    Object? showOverlay = null,
    Object? ctaText = null,
    Object? ctaLink = freezed,
    Object? schedule = freezed,
    Object? countdown = freezed,
    Object? status = null,
    Object? placement = null,
    Object? priority = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PromotionImpl(
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
        subtitle: freezed == subtitle
            ? _value.subtitle
            : subtitle // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as Media?,
        backgroundImage: freezed == backgroundImage
            ? _value.backgroundImage
            : backgroundImage // ignore: cast_nullable_to_non_nullable
                  as Media?,
        showOverlay: null == showOverlay
            ? _value.showOverlay
            : showOverlay // ignore: cast_nullable_to_non_nullable
                  as bool,
        ctaText: null == ctaText
            ? _value.ctaText
            : ctaText // ignore: cast_nullable_to_non_nullable
                  as String,
        ctaLink: freezed == ctaLink
            ? _value.ctaLink
            : ctaLink // ignore: cast_nullable_to_non_nullable
                  as CtaLink?,
        schedule: freezed == schedule
            ? _value.schedule
            : schedule // ignore: cast_nullable_to_non_nullable
                  as PromotionSchedule?,
        countdown: freezed == countdown
            ? _value.countdown
            : countdown // ignore: cast_nullable_to_non_nullable
                  as PromotionCountdown?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PromotionStatus,
        placement: null == placement
            ? _value.placement
            : placement // ignore: cast_nullable_to_non_nullable
                  as PromotionPlacement,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromotionImpl implements _Promotion {
  const _$PromotionImpl({
    required this.id,
    required this.slug,
    required this.title,
    this.subtitle,
    this.description,
    this.image,
    this.backgroundImage,
    this.showOverlay = true,
    this.ctaText = 'Play Now',
    this.ctaLink,
    this.schedule,
    this.countdown,
    required this.status,
    required this.placement,
    this.priority = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory _$PromotionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromotionImplFromJson(json);

  @override
  final String id;
  @override
  final String slug;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String? description;
  @override
  final Media? image;
  @override
  final Media? backgroundImage;
  @override
  @JsonKey()
  final bool showOverlay;
  @override
  @JsonKey()
  final String ctaText;
  @override
  final CtaLink? ctaLink;
  @override
  final PromotionSchedule? schedule;
  @override
  final PromotionCountdown? countdown;
  @override
  final PromotionStatus status;
  @override
  final PromotionPlacement placement;
  @override
  @JsonKey()
  final int priority;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'Promotion(id: $id, slug: $slug, title: $title, subtitle: $subtitle, description: $description, image: $image, backgroundImage: $backgroundImage, showOverlay: $showOverlay, ctaText: $ctaText, ctaLink: $ctaLink, schedule: $schedule, countdown: $countdown, status: $status, placement: $placement, priority: $priority, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromotionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.backgroundImage, backgroundImage) ||
                other.backgroundImage == backgroundImage) &&
            (identical(other.showOverlay, showOverlay) ||
                other.showOverlay == showOverlay) &&
            (identical(other.ctaText, ctaText) || other.ctaText == ctaText) &&
            (identical(other.ctaLink, ctaLink) || other.ctaLink == ctaLink) &&
            (identical(other.schedule, schedule) ||
                other.schedule == schedule) &&
            (identical(other.countdown, countdown) ||
                other.countdown == countdown) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.placement, placement) ||
                other.placement == placement) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    slug,
    title,
    subtitle,
    description,
    image,
    backgroundImage,
    showOverlay,
    ctaText,
    ctaLink,
    schedule,
    countdown,
    status,
    placement,
    priority,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromotionImplCopyWith<_$PromotionImpl> get copyWith =>
      __$$PromotionImplCopyWithImpl<_$PromotionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromotionImplToJson(this);
  }
}

abstract class _Promotion implements Promotion {
  const factory _Promotion({
    required final String id,
    required final String slug,
    required final String title,
    final String? subtitle,
    final String? description,
    final Media? image,
    final Media? backgroundImage,
    final bool showOverlay,
    final String ctaText,
    final CtaLink? ctaLink,
    final PromotionSchedule? schedule,
    final PromotionCountdown? countdown,
    required final PromotionStatus status,
    required final PromotionPlacement placement,
    final int priority,
    final String? createdAt,
    final String? updatedAt,
  }) = _$PromotionImpl;

  factory _Promotion.fromJson(Map<String, dynamic> json) =
      _$PromotionImpl.fromJson;

  @override
  String get id;
  @override
  String get slug;
  @override
  String get title;
  @override
  String? get subtitle;
  @override
  String? get description;
  @override
  Media? get image;
  @override
  Media? get backgroundImage;
  @override
  bool get showOverlay;
  @override
  String get ctaText;
  @override
  CtaLink? get ctaLink;
  @override
  PromotionSchedule? get schedule;
  @override
  PromotionCountdown? get countdown;
  @override
  PromotionStatus get status;
  @override
  PromotionPlacement get placement;
  @override
  int get priority;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of Promotion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromotionImplCopyWith<_$PromotionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaginatedPromotions _$PaginatedPromotionsFromJson(Map<String, dynamic> json) {
  return _PaginatedPromotions.fromJson(json);
}

/// @nodoc
mixin _$PaginatedPromotions {
  List<Promotion> get docs => throw _privateConstructorUsedError;
  int get totalDocs => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;
  bool get hasPrevPage => throw _privateConstructorUsedError;

  /// Serializes this PaginatedPromotions to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedPromotions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedPromotionsCopyWith<PaginatedPromotions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedPromotionsCopyWith<$Res> {
  factory $PaginatedPromotionsCopyWith(
    PaginatedPromotions value,
    $Res Function(PaginatedPromotions) then,
  ) = _$PaginatedPromotionsCopyWithImpl<$Res, PaginatedPromotions>;
  @useResult
  $Res call({
    List<Promotion> docs,
    int totalDocs,
    int limit,
    int page,
    int totalPages,
    bool hasNextPage,
    bool hasPrevPage,
  });
}

/// @nodoc
class _$PaginatedPromotionsCopyWithImpl<$Res, $Val extends PaginatedPromotions>
    implements $PaginatedPromotionsCopyWith<$Res> {
  _$PaginatedPromotionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedPromotions
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
                      as List<Promotion>,
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
abstract class _$$PaginatedPromotionsImplCopyWith<$Res>
    implements $PaginatedPromotionsCopyWith<$Res> {
  factory _$$PaginatedPromotionsImplCopyWith(
    _$PaginatedPromotionsImpl value,
    $Res Function(_$PaginatedPromotionsImpl) then,
  ) = __$$PaginatedPromotionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Promotion> docs,
    int totalDocs,
    int limit,
    int page,
    int totalPages,
    bool hasNextPage,
    bool hasPrevPage,
  });
}

/// @nodoc
class __$$PaginatedPromotionsImplCopyWithImpl<$Res>
    extends _$PaginatedPromotionsCopyWithImpl<$Res, _$PaginatedPromotionsImpl>
    implements _$$PaginatedPromotionsImplCopyWith<$Res> {
  __$$PaginatedPromotionsImplCopyWithImpl(
    _$PaginatedPromotionsImpl _value,
    $Res Function(_$PaginatedPromotionsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedPromotions
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
      _$PaginatedPromotionsImpl(
        docs: null == docs
            ? _value._docs
            : docs // ignore: cast_nullable_to_non_nullable
                  as List<Promotion>,
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
class _$PaginatedPromotionsImpl implements _PaginatedPromotions {
  const _$PaginatedPromotionsImpl({
    required final List<Promotion> docs,
    required this.totalDocs,
    required this.limit,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  }) : _docs = docs;

  factory _$PaginatedPromotionsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginatedPromotionsImplFromJson(json);

  final List<Promotion> _docs;
  @override
  List<Promotion> get docs {
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
    return 'PaginatedPromotions(docs: $docs, totalDocs: $totalDocs, limit: $limit, page: $page, totalPages: $totalPages, hasNextPage: $hasNextPage, hasPrevPage: $hasPrevPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedPromotionsImpl &&
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

  /// Create a copy of PaginatedPromotions
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedPromotionsImplCopyWith<_$PaginatedPromotionsImpl> get copyWith =>
      __$$PaginatedPromotionsImplCopyWithImpl<_$PaginatedPromotionsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginatedPromotionsImplToJson(this);
  }
}

abstract class _PaginatedPromotions implements PaginatedPromotions {
  const factory _PaginatedPromotions({
    required final List<Promotion> docs,
    required final int totalDocs,
    required final int limit,
    required final int page,
    required final int totalPages,
    required final bool hasNextPage,
    required final bool hasPrevPage,
  }) = _$PaginatedPromotionsImpl;

  factory _PaginatedPromotions.fromJson(Map<String, dynamic> json) =
      _$PaginatedPromotionsImpl.fromJson;

  @override
  List<Promotion> get docs;
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

  /// Create a copy of PaginatedPromotions
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedPromotionsImplCopyWith<_$PaginatedPromotionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
