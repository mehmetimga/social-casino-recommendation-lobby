// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserEvent _$UserEventFromJson(Map<String, dynamic> json) {
  return _UserEvent.fromJson(json);
}

/// @nodoc
mixin _$UserEvent {
  String get userId => throw _privateConstructorUsedError;
  String get gameSlug => throw _privateConstructorUsedError;
  EventType get eventType => throw _privateConstructorUsedError;
  int? get durationSeconds => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this UserEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserEventCopyWith<UserEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserEventCopyWith<$Res> {
  factory $UserEventCopyWith(UserEvent value, $Res Function(UserEvent) then) =
      _$UserEventCopyWithImpl<$Res, UserEvent>;
  @useResult
  $Res call({
    String userId,
    String gameSlug,
    EventType eventType,
    int? durationSeconds,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$UserEventCopyWithImpl<$Res, $Val extends UserEvent>
    implements $UserEventCopyWith<$Res> {
  _$UserEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gameSlug = null,
    Object? eventType = null,
    Object? durationSeconds = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            gameSlug: null == gameSlug
                ? _value.gameSlug
                : gameSlug // ignore: cast_nullable_to_non_nullable
                      as String,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as EventType,
            durationSeconds: freezed == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserEventImplCopyWith<$Res>
    implements $UserEventCopyWith<$Res> {
  factory _$$UserEventImplCopyWith(
    _$UserEventImpl value,
    $Res Function(_$UserEventImpl) then,
  ) = __$$UserEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String gameSlug,
    EventType eventType,
    int? durationSeconds,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$UserEventImplCopyWithImpl<$Res>
    extends _$UserEventCopyWithImpl<$Res, _$UserEventImpl>
    implements _$$UserEventImplCopyWith<$Res> {
  __$$UserEventImplCopyWithImpl(
    _$UserEventImpl _value,
    $Res Function(_$UserEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gameSlug = null,
    Object? eventType = null,
    Object? durationSeconds = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$UserEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        gameSlug: null == gameSlug
            ? _value.gameSlug
            : gameSlug // ignore: cast_nullable_to_non_nullable
                  as String,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as EventType,
        durationSeconds: freezed == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserEventImpl implements _UserEvent {
  const _$UserEventImpl({
    required this.userId,
    required this.gameSlug,
    required this.eventType,
    this.durationSeconds,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$UserEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String gameSlug;
  @override
  final EventType eventType;
  @override
  final int? durationSeconds;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'UserEvent(userId: $userId, gameSlug: $gameSlug, eventType: $eventType, durationSeconds: $durationSeconds, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.gameSlug, gameSlug) ||
                other.gameSlug == gameSlug) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    gameSlug,
    eventType,
    durationSeconds,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserEventImplCopyWith<_$UserEventImpl> get copyWith =>
      __$$UserEventImplCopyWithImpl<_$UserEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserEventImplToJson(this);
  }
}

abstract class _UserEvent implements UserEvent {
  const factory _UserEvent({
    required final String userId,
    required final String gameSlug,
    required final EventType eventType,
    final int? durationSeconds,
    final Map<String, dynamic>? metadata,
  }) = _$UserEventImpl;

  factory _UserEvent.fromJson(Map<String, dynamic> json) =
      _$UserEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get gameSlug;
  @override
  EventType get eventType;
  @override
  int? get durationSeconds;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of UserEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserEventImplCopyWith<_$UserEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RatingInput _$RatingInputFromJson(Map<String, dynamic> json) {
  return _RatingInput.fromJson(json);
}

/// @nodoc
mixin _$RatingInput {
  String get userId => throw _privateConstructorUsedError;
  String get gameSlug => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;

  /// Serializes this RatingInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RatingInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RatingInputCopyWith<RatingInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingInputCopyWith<$Res> {
  factory $RatingInputCopyWith(
    RatingInput value,
    $Res Function(RatingInput) then,
  ) = _$RatingInputCopyWithImpl<$Res, RatingInput>;
  @useResult
  $Res call({String userId, String gameSlug, int rating});
}

/// @nodoc
class _$RatingInputCopyWithImpl<$Res, $Val extends RatingInput>
    implements $RatingInputCopyWith<$Res> {
  _$RatingInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RatingInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gameSlug = null,
    Object? rating = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            gameSlug: null == gameSlug
                ? _value.gameSlug
                : gameSlug // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RatingInputImplCopyWith<$Res>
    implements $RatingInputCopyWith<$Res> {
  factory _$$RatingInputImplCopyWith(
    _$RatingInputImpl value,
    $Res Function(_$RatingInputImpl) then,
  ) = __$$RatingInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String gameSlug, int rating});
}

/// @nodoc
class __$$RatingInputImplCopyWithImpl<$Res>
    extends _$RatingInputCopyWithImpl<$Res, _$RatingInputImpl>
    implements _$$RatingInputImplCopyWith<$Res> {
  __$$RatingInputImplCopyWithImpl(
    _$RatingInputImpl _value,
    $Res Function(_$RatingInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RatingInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gameSlug = null,
    Object? rating = null,
  }) {
    return _then(
      _$RatingInputImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        gameSlug: null == gameSlug
            ? _value.gameSlug
            : gameSlug // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RatingInputImpl implements _RatingInput {
  const _$RatingInputImpl({
    required this.userId,
    required this.gameSlug,
    required this.rating,
  });

  factory _$RatingInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatingInputImplFromJson(json);

  @override
  final String userId;
  @override
  final String gameSlug;
  @override
  final int rating;

  @override
  String toString() {
    return 'RatingInput(userId: $userId, gameSlug: $gameSlug, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingInputImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.gameSlug, gameSlug) ||
                other.gameSlug == gameSlug) &&
            (identical(other.rating, rating) || other.rating == rating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, gameSlug, rating);

  /// Create a copy of RatingInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingInputImplCopyWith<_$RatingInputImpl> get copyWith =>
      __$$RatingInputImplCopyWithImpl<_$RatingInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RatingInputImplToJson(this);
  }
}

abstract class _RatingInput implements RatingInput {
  const factory _RatingInput({
    required final String userId,
    required final String gameSlug,
    required final int rating,
  }) = _$RatingInputImpl;

  factory _RatingInput.fromJson(Map<String, dynamic> json) =
      _$RatingInputImpl.fromJson;

  @override
  String get userId;
  @override
  String get gameSlug;
  @override
  int get rating;

  /// Create a copy of RatingInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RatingInputImplCopyWith<_$RatingInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecommendationReviewInput _$RecommendationReviewInputFromJson(
  Map<String, dynamic> json,
) {
  return _RecommendationReviewInput.fromJson(json);
}

/// @nodoc
mixin _$RecommendationReviewInput {
  String get userId => throw _privateConstructorUsedError;
  String get gameSlug => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get reviewText => throw _privateConstructorUsedError;

  /// Serializes this RecommendationReviewInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationReviewInputCopyWith<RecommendationReviewInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationReviewInputCopyWith<$Res> {
  factory $RecommendationReviewInputCopyWith(
    RecommendationReviewInput value,
    $Res Function(RecommendationReviewInput) then,
  ) = _$RecommendationReviewInputCopyWithImpl<$Res, RecommendationReviewInput>;
  @useResult
  $Res call({String userId, String gameSlug, int rating, String? reviewText});
}

/// @nodoc
class _$RecommendationReviewInputCopyWithImpl<
  $Res,
  $Val extends RecommendationReviewInput
>
    implements $RecommendationReviewInputCopyWith<$Res> {
  _$RecommendationReviewInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gameSlug = null,
    Object? rating = null,
    Object? reviewText = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            gameSlug: null == gameSlug
                ? _value.gameSlug
                : gameSlug // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewText: freezed == reviewText
                ? _value.reviewText
                : reviewText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecommendationReviewInputImplCopyWith<$Res>
    implements $RecommendationReviewInputCopyWith<$Res> {
  factory _$$RecommendationReviewInputImplCopyWith(
    _$RecommendationReviewInputImpl value,
    $Res Function(_$RecommendationReviewInputImpl) then,
  ) = __$$RecommendationReviewInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String gameSlug, int rating, String? reviewText});
}

/// @nodoc
class __$$RecommendationReviewInputImplCopyWithImpl<$Res>
    extends
        _$RecommendationReviewInputCopyWithImpl<
          $Res,
          _$RecommendationReviewInputImpl
        >
    implements _$$RecommendationReviewInputImplCopyWith<$Res> {
  __$$RecommendationReviewInputImplCopyWithImpl(
    _$RecommendationReviewInputImpl _value,
    $Res Function(_$RecommendationReviewInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendationReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gameSlug = null,
    Object? rating = null,
    Object? reviewText = freezed,
  }) {
    return _then(
      _$RecommendationReviewInputImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        gameSlug: null == gameSlug
            ? _value.gameSlug
            : gameSlug // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewText: freezed == reviewText
            ? _value.reviewText
            : reviewText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationReviewInputImpl implements _RecommendationReviewInput {
  const _$RecommendationReviewInputImpl({
    required this.userId,
    required this.gameSlug,
    required this.rating,
    this.reviewText,
  });

  factory _$RecommendationReviewInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationReviewInputImplFromJson(json);

  @override
  final String userId;
  @override
  final String gameSlug;
  @override
  final int rating;
  @override
  final String? reviewText;

  @override
  String toString() {
    return 'RecommendationReviewInput(userId: $userId, gameSlug: $gameSlug, rating: $rating, reviewText: $reviewText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationReviewInputImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.gameSlug, gameSlug) ||
                other.gameSlug == gameSlug) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewText, reviewText) ||
                other.reviewText == reviewText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, gameSlug, rating, reviewText);

  /// Create a copy of RecommendationReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationReviewInputImplCopyWith<_$RecommendationReviewInputImpl>
  get copyWith =>
      __$$RecommendationReviewInputImplCopyWithImpl<
        _$RecommendationReviewInputImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationReviewInputImplToJson(this);
  }
}

abstract class _RecommendationReviewInput implements RecommendationReviewInput {
  const factory _RecommendationReviewInput({
    required final String userId,
    required final String gameSlug,
    required final int rating,
    final String? reviewText,
  }) = _$RecommendationReviewInputImpl;

  factory _RecommendationReviewInput.fromJson(Map<String, dynamic> json) =
      _$RecommendationReviewInputImpl.fromJson;

  @override
  String get userId;
  @override
  String get gameSlug;
  @override
  int get rating;
  @override
  String? get reviewText;

  /// Create a copy of RecommendationReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationReviewInputImplCopyWith<_$RecommendationReviewInputImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RecommendationResponse _$RecommendationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _RecommendationResponse.fromJson(json);
}

/// @nodoc
mixin _$RecommendationResponse {
  List<String> get gameSlugs => throw _privateConstructorUsedError;

  /// Serializes this RecommendationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationResponseCopyWith<RecommendationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationResponseCopyWith<$Res> {
  factory $RecommendationResponseCopyWith(
    RecommendationResponse value,
    $Res Function(RecommendationResponse) then,
  ) = _$RecommendationResponseCopyWithImpl<$Res, RecommendationResponse>;
  @useResult
  $Res call({List<String> gameSlugs});
}

/// @nodoc
class _$RecommendationResponseCopyWithImpl<
  $Res,
  $Val extends RecommendationResponse
>
    implements $RecommendationResponseCopyWith<$Res> {
  _$RecommendationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameSlugs = null}) {
    return _then(
      _value.copyWith(
            gameSlugs: null == gameSlugs
                ? _value.gameSlugs
                : gameSlugs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecommendationResponseImplCopyWith<$Res>
    implements $RecommendationResponseCopyWith<$Res> {
  factory _$$RecommendationResponseImplCopyWith(
    _$RecommendationResponseImpl value,
    $Res Function(_$RecommendationResponseImpl) then,
  ) = __$$RecommendationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> gameSlugs});
}

/// @nodoc
class __$$RecommendationResponseImplCopyWithImpl<$Res>
    extends
        _$RecommendationResponseCopyWithImpl<$Res, _$RecommendationResponseImpl>
    implements _$$RecommendationResponseImplCopyWith<$Res> {
  __$$RecommendationResponseImplCopyWithImpl(
    _$RecommendationResponseImpl _value,
    $Res Function(_$RecommendationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? gameSlugs = null}) {
    return _then(
      _$RecommendationResponseImpl(
        gameSlugs: null == gameSlugs
            ? _value._gameSlugs
            : gameSlugs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationResponseImpl implements _RecommendationResponse {
  const _$RecommendationResponseImpl({required final List<String> gameSlugs})
    : _gameSlugs = gameSlugs;

  factory _$RecommendationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationResponseImplFromJson(json);

  final List<String> _gameSlugs;
  @override
  List<String> get gameSlugs {
    if (_gameSlugs is EqualUnmodifiableListView) return _gameSlugs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gameSlugs);
  }

  @override
  String toString() {
    return 'RecommendationResponse(gameSlugs: $gameSlugs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationResponseImpl &&
            const DeepCollectionEquality().equals(
              other._gameSlugs,
              _gameSlugs,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_gameSlugs));

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationResponseImplCopyWith<_$RecommendationResponseImpl>
  get copyWith =>
      __$$RecommendationResponseImplCopyWithImpl<_$RecommendationResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationResponseImplToJson(this);
  }
}

abstract class _RecommendationResponse implements RecommendationResponse {
  const factory _RecommendationResponse({
    required final List<String> gameSlugs,
  }) = _$RecommendationResponseImpl;

  factory _RecommendationResponse.fromJson(Map<String, dynamic> json) =
      _$RecommendationResponseImpl.fromJson;

  @override
  List<String> get gameSlugs;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationResponseImplCopyWith<_$RecommendationResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
