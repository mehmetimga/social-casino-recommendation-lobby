// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameReview _$GameReviewFromJson(Map<String, dynamic> json) {
  return _GameReview.fromJson(json);
}

/// @nodoc
mixin _$GameReview {
  String get id => throw _privateConstructorUsedError;
  String get visitorId => throw _privateConstructorUsedError;
  String get game => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get reviewText => throw _privateConstructorUsedError;
  ReviewStatus get status => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this GameReview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameReviewCopyWith<GameReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameReviewCopyWith<$Res> {
  factory $GameReviewCopyWith(
    GameReview value,
    $Res Function(GameReview) then,
  ) = _$GameReviewCopyWithImpl<$Res, GameReview>;
  @useResult
  $Res call({
    String id,
    String visitorId,
    String game,
    int rating,
    String? reviewText,
    ReviewStatus status,
    String createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class _$GameReviewCopyWithImpl<$Res, $Val extends GameReview>
    implements $GameReviewCopyWith<$Res> {
  _$GameReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? visitorId = null,
    Object? game = null,
    Object? rating = null,
    Object? reviewText = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            visitorId: null == visitorId
                ? _value.visitorId
                : visitorId // ignore: cast_nullable_to_non_nullable
                      as String,
            game: null == game
                ? _value.game
                : game // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as int,
            reviewText: freezed == reviewText
                ? _value.reviewText
                : reviewText // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReviewStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameReviewImplCopyWith<$Res>
    implements $GameReviewCopyWith<$Res> {
  factory _$$GameReviewImplCopyWith(
    _$GameReviewImpl value,
    $Res Function(_$GameReviewImpl) then,
  ) = __$$GameReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String visitorId,
    String game,
    int rating,
    String? reviewText,
    ReviewStatus status,
    String createdAt,
    String? updatedAt,
  });
}

/// @nodoc
class __$$GameReviewImplCopyWithImpl<$Res>
    extends _$GameReviewCopyWithImpl<$Res, _$GameReviewImpl>
    implements _$$GameReviewImplCopyWith<$Res> {
  __$$GameReviewImplCopyWithImpl(
    _$GameReviewImpl _value,
    $Res Function(_$GameReviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameReview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? visitorId = null,
    Object? game = null,
    Object? rating = null,
    Object? reviewText = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$GameReviewImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        visitorId: null == visitorId
            ? _value.visitorId
            : visitorId // ignore: cast_nullable_to_non_nullable
                  as String,
        game: null == game
            ? _value.game
            : game // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as int,
        reviewText: freezed == reviewText
            ? _value.reviewText
            : reviewText // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReviewStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$GameReviewImpl implements _GameReview {
  const _$GameReviewImpl({
    required this.id,
    required this.visitorId,
    required this.game,
    required this.rating,
    this.reviewText,
    this.status = ReviewStatus.published,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$GameReviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameReviewImplFromJson(json);

  @override
  final String id;
  @override
  final String visitorId;
  @override
  final String game;
  @override
  final int rating;
  @override
  final String? reviewText;
  @override
  @JsonKey()
  final ReviewStatus status;
  @override
  final String createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'GameReview(id: $id, visitorId: $visitorId, game: $game, rating: $rating, reviewText: $reviewText, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameReviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.visitorId, visitorId) ||
                other.visitorId == visitorId) &&
            (identical(other.game, game) || other.game == game) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewText, reviewText) ||
                other.reviewText == reviewText) &&
            (identical(other.status, status) || other.status == status) &&
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
    visitorId,
    game,
    rating,
    reviewText,
    status,
    createdAt,
    updatedAt,
  );

  /// Create a copy of GameReview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameReviewImplCopyWith<_$GameReviewImpl> get copyWith =>
      __$$GameReviewImplCopyWithImpl<_$GameReviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameReviewImplToJson(this);
  }
}

abstract class _GameReview implements GameReview {
  const factory _GameReview({
    required final String id,
    required final String visitorId,
    required final String game,
    required final int rating,
    final String? reviewText,
    final ReviewStatus status,
    required final String createdAt,
    final String? updatedAt,
  }) = _$GameReviewImpl;

  factory _GameReview.fromJson(Map<String, dynamic> json) =
      _$GameReviewImpl.fromJson;

  @override
  String get id;
  @override
  String get visitorId;
  @override
  String get game;
  @override
  int get rating;
  @override
  String? get reviewText;
  @override
  ReviewStatus get status;
  @override
  String get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of GameReview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameReviewImplCopyWith<_$GameReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewInput _$ReviewInputFromJson(Map<String, dynamic> json) {
  return _ReviewInput.fromJson(json);
}

/// @nodoc
mixin _$ReviewInput {
  String get visitorId => throw _privateConstructorUsedError;
  String get game => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get reviewText => throw _privateConstructorUsedError;

  /// Serializes this ReviewInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewInputCopyWith<ReviewInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewInputCopyWith<$Res> {
  factory $ReviewInputCopyWith(
    ReviewInput value,
    $Res Function(ReviewInput) then,
  ) = _$ReviewInputCopyWithImpl<$Res, ReviewInput>;
  @useResult
  $Res call({String visitorId, String game, int rating, String? reviewText});
}

/// @nodoc
class _$ReviewInputCopyWithImpl<$Res, $Val extends ReviewInput>
    implements $ReviewInputCopyWith<$Res> {
  _$ReviewInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitorId = null,
    Object? game = null,
    Object? rating = null,
    Object? reviewText = freezed,
  }) {
    return _then(
      _value.copyWith(
            visitorId: null == visitorId
                ? _value.visitorId
                : visitorId // ignore: cast_nullable_to_non_nullable
                      as String,
            game: null == game
                ? _value.game
                : game // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ReviewInputImplCopyWith<$Res>
    implements $ReviewInputCopyWith<$Res> {
  factory _$$ReviewInputImplCopyWith(
    _$ReviewInputImpl value,
    $Res Function(_$ReviewInputImpl) then,
  ) = __$$ReviewInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String visitorId, String game, int rating, String? reviewText});
}

/// @nodoc
class __$$ReviewInputImplCopyWithImpl<$Res>
    extends _$ReviewInputCopyWithImpl<$Res, _$ReviewInputImpl>
    implements _$$ReviewInputImplCopyWith<$Res> {
  __$$ReviewInputImplCopyWithImpl(
    _$ReviewInputImpl _value,
    $Res Function(_$ReviewInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitorId = null,
    Object? game = null,
    Object? rating = null,
    Object? reviewText = freezed,
  }) {
    return _then(
      _$ReviewInputImpl(
        visitorId: null == visitorId
            ? _value.visitorId
            : visitorId // ignore: cast_nullable_to_non_nullable
                  as String,
        game: null == game
            ? _value.game
            : game // ignore: cast_nullable_to_non_nullable
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
class _$ReviewInputImpl implements _ReviewInput {
  const _$ReviewInputImpl({
    required this.visitorId,
    required this.game,
    required this.rating,
    this.reviewText,
  });

  factory _$ReviewInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewInputImplFromJson(json);

  @override
  final String visitorId;
  @override
  final String game;
  @override
  final int rating;
  @override
  final String? reviewText;

  @override
  String toString() {
    return 'ReviewInput(visitorId: $visitorId, game: $game, rating: $rating, reviewText: $reviewText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewInputImpl &&
            (identical(other.visitorId, visitorId) ||
                other.visitorId == visitorId) &&
            (identical(other.game, game) || other.game == game) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewText, reviewText) ||
                other.reviewText == reviewText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, visitorId, game, rating, reviewText);

  /// Create a copy of ReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewInputImplCopyWith<_$ReviewInputImpl> get copyWith =>
      __$$ReviewInputImplCopyWithImpl<_$ReviewInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewInputImplToJson(this);
  }
}

abstract class _ReviewInput implements ReviewInput {
  const factory _ReviewInput({
    required final String visitorId,
    required final String game,
    required final int rating,
    final String? reviewText,
  }) = _$ReviewInputImpl;

  factory _ReviewInput.fromJson(Map<String, dynamic> json) =
      _$ReviewInputImpl.fromJson;

  @override
  String get visitorId;
  @override
  String get game;
  @override
  int get rating;
  @override
  String? get reviewText;

  /// Create a copy of ReviewInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewInputImplCopyWith<_$ReviewInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaginatedReviews _$PaginatedReviewsFromJson(Map<String, dynamic> json) {
  return _PaginatedReviews.fromJson(json);
}

/// @nodoc
mixin _$PaginatedReviews {
  List<GameReview> get docs => throw _privateConstructorUsedError;
  int get totalDocs => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;
  bool get hasPrevPage => throw _privateConstructorUsedError;

  /// Serializes this PaginatedReviews to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedReviews
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedReviewsCopyWith<PaginatedReviews> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedReviewsCopyWith<$Res> {
  factory $PaginatedReviewsCopyWith(
    PaginatedReviews value,
    $Res Function(PaginatedReviews) then,
  ) = _$PaginatedReviewsCopyWithImpl<$Res, PaginatedReviews>;
  @useResult
  $Res call({
    List<GameReview> docs,
    int totalDocs,
    int limit,
    int page,
    int totalPages,
    bool hasNextPage,
    bool hasPrevPage,
  });
}

/// @nodoc
class _$PaginatedReviewsCopyWithImpl<$Res, $Val extends PaginatedReviews>
    implements $PaginatedReviewsCopyWith<$Res> {
  _$PaginatedReviewsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedReviews
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
                      as List<GameReview>,
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
abstract class _$$PaginatedReviewsImplCopyWith<$Res>
    implements $PaginatedReviewsCopyWith<$Res> {
  factory _$$PaginatedReviewsImplCopyWith(
    _$PaginatedReviewsImpl value,
    $Res Function(_$PaginatedReviewsImpl) then,
  ) = __$$PaginatedReviewsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<GameReview> docs,
    int totalDocs,
    int limit,
    int page,
    int totalPages,
    bool hasNextPage,
    bool hasPrevPage,
  });
}

/// @nodoc
class __$$PaginatedReviewsImplCopyWithImpl<$Res>
    extends _$PaginatedReviewsCopyWithImpl<$Res, _$PaginatedReviewsImpl>
    implements _$$PaginatedReviewsImplCopyWith<$Res> {
  __$$PaginatedReviewsImplCopyWithImpl(
    _$PaginatedReviewsImpl _value,
    $Res Function(_$PaginatedReviewsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedReviews
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
      _$PaginatedReviewsImpl(
        docs: null == docs
            ? _value._docs
            : docs // ignore: cast_nullable_to_non_nullable
                  as List<GameReview>,
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
class _$PaginatedReviewsImpl implements _PaginatedReviews {
  const _$PaginatedReviewsImpl({
    required final List<GameReview> docs,
    required this.totalDocs,
    required this.limit,
    required this.page,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  }) : _docs = docs;

  factory _$PaginatedReviewsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaginatedReviewsImplFromJson(json);

  final List<GameReview> _docs;
  @override
  List<GameReview> get docs {
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
    return 'PaginatedReviews(docs: $docs, totalDocs: $totalDocs, limit: $limit, page: $page, totalPages: $totalPages, hasNextPage: $hasNextPage, hasPrevPage: $hasPrevPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedReviewsImpl &&
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

  /// Create a copy of PaginatedReviews
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedReviewsImplCopyWith<_$PaginatedReviewsImpl> get copyWith =>
      __$$PaginatedReviewsImplCopyWithImpl<_$PaginatedReviewsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaginatedReviewsImplToJson(this);
  }
}

abstract class _PaginatedReviews implements PaginatedReviews {
  const factory _PaginatedReviews({
    required final List<GameReview> docs,
    required final int totalDocs,
    required final int limit,
    required final int page,
    required final int totalPages,
    required final bool hasNextPage,
    required final bool hasPrevPage,
  }) = _$PaginatedReviewsImpl;

  factory _PaginatedReviews.fromJson(Map<String, dynamic> json) =
      _$PaginatedReviewsImpl.fromJson;

  @override
  List<GameReview> get docs;
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

  /// Create a copy of PaginatedReviews
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedReviewsImplCopyWith<_$PaginatedReviewsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
