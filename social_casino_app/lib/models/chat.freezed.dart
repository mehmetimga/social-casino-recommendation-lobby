// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatContext _$ChatContextFromJson(Map<String, dynamic> json) {
  return _ChatContext.fromJson(json);
}

/// @nodoc
mixin _$ChatContext {
  String? get currentPage => throw _privateConstructorUsedError;
  String? get currentGame => throw _privateConstructorUsedError;
  String? get gameSlug => throw _privateConstructorUsedError;
  String? get vipLevel => throw _privateConstructorUsedError;

  /// Serializes this ChatContext to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatContextCopyWith<ChatContext> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatContextCopyWith<$Res> {
  factory $ChatContextCopyWith(
    ChatContext value,
    $Res Function(ChatContext) then,
  ) = _$ChatContextCopyWithImpl<$Res, ChatContext>;
  @useResult
  $Res call({
    String? currentPage,
    String? currentGame,
    String? gameSlug,
    String? vipLevel,
  });
}

/// @nodoc
class _$ChatContextCopyWithImpl<$Res, $Val extends ChatContext>
    implements $ChatContextCopyWith<$Res> {
  _$ChatContextCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? currentGame = freezed,
    Object? gameSlug = freezed,
    Object? vipLevel = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPage: freezed == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentGame: freezed == currentGame
                ? _value.currentGame
                : currentGame // ignore: cast_nullable_to_non_nullable
                      as String?,
            gameSlug: freezed == gameSlug
                ? _value.gameSlug
                : gameSlug // ignore: cast_nullable_to_non_nullable
                      as String?,
            vipLevel: freezed == vipLevel
                ? _value.vipLevel
                : vipLevel // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatContextImplCopyWith<$Res>
    implements $ChatContextCopyWith<$Res> {
  factory _$$ChatContextImplCopyWith(
    _$ChatContextImpl value,
    $Res Function(_$ChatContextImpl) then,
  ) = __$$ChatContextImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? currentPage,
    String? currentGame,
    String? gameSlug,
    String? vipLevel,
  });
}

/// @nodoc
class __$$ChatContextImplCopyWithImpl<$Res>
    extends _$ChatContextCopyWithImpl<$Res, _$ChatContextImpl>
    implements _$$ChatContextImplCopyWith<$Res> {
  __$$ChatContextImplCopyWithImpl(
    _$ChatContextImpl _value,
    $Res Function(_$ChatContextImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatContext
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentPage = freezed,
    Object? currentGame = freezed,
    Object? gameSlug = freezed,
    Object? vipLevel = freezed,
  }) {
    return _then(
      _$ChatContextImpl(
        currentPage: freezed == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentGame: freezed == currentGame
            ? _value.currentGame
            : currentGame // ignore: cast_nullable_to_non_nullable
                  as String?,
        gameSlug: freezed == gameSlug
            ? _value.gameSlug
            : gameSlug // ignore: cast_nullable_to_non_nullable
                  as String?,
        vipLevel: freezed == vipLevel
            ? _value.vipLevel
            : vipLevel // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatContextImpl implements _ChatContext {
  const _$ChatContextImpl({
    this.currentPage,
    this.currentGame,
    this.gameSlug,
    this.vipLevel,
  });

  factory _$ChatContextImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatContextImplFromJson(json);

  @override
  final String? currentPage;
  @override
  final String? currentGame;
  @override
  final String? gameSlug;
  @override
  final String? vipLevel;

  @override
  String toString() {
    return 'ChatContext(currentPage: $currentPage, currentGame: $currentGame, gameSlug: $gameSlug, vipLevel: $vipLevel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatContextImpl &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.currentGame, currentGame) ||
                other.currentGame == currentGame) &&
            (identical(other.gameSlug, gameSlug) ||
                other.gameSlug == gameSlug) &&
            (identical(other.vipLevel, vipLevel) ||
                other.vipLevel == vipLevel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentPage, currentGame, gameSlug, vipLevel);

  /// Create a copy of ChatContext
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatContextImplCopyWith<_$ChatContextImpl> get copyWith =>
      __$$ChatContextImplCopyWithImpl<_$ChatContextImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatContextImplToJson(this);
  }
}

abstract class _ChatContext implements ChatContext {
  const factory _ChatContext({
    final String? currentPage,
    final String? currentGame,
    final String? gameSlug,
    final String? vipLevel,
  }) = _$ChatContextImpl;

  factory _ChatContext.fromJson(Map<String, dynamic> json) =
      _$ChatContextImpl.fromJson;

  @override
  String? get currentPage;
  @override
  String? get currentGame;
  @override
  String? get gameSlug;
  @override
  String? get vipLevel;

  /// Create a copy of ChatContext
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatContextImplCopyWith<_$ChatContextImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) {
  return _ChatSession.fromJson(json);
}

/// @nodoc
mixin _$ChatSession {
  String get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  ChatContext? get context => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChatSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatSessionCopyWith<ChatSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatSessionCopyWith<$Res> {
  factory $ChatSessionCopyWith(
    ChatSession value,
    $Res Function(ChatSession) then,
  ) = _$ChatSessionCopyWithImpl<$Res, ChatSession>;
  @useResult
  $Res call({
    String id,
    String? userId,
    ChatContext? context,
    String createdAt,
    String? updatedAt,
  });

  $ChatContextCopyWith<$Res>? get context;
}

/// @nodoc
class _$ChatSessionCopyWithImpl<$Res, $Val extends ChatSession>
    implements $ChatSessionCopyWith<$Res> {
  _$ChatSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? context = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as ChatContext?,
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

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatContextCopyWith<$Res>? get context {
    if (_value.context == null) {
      return null;
    }

    return $ChatContextCopyWith<$Res>(_value.context!, (value) {
      return _then(_value.copyWith(context: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatSessionImplCopyWith<$Res>
    implements $ChatSessionCopyWith<$Res> {
  factory _$$ChatSessionImplCopyWith(
    _$ChatSessionImpl value,
    $Res Function(_$ChatSessionImpl) then,
  ) = __$$ChatSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? userId,
    ChatContext? context,
    String createdAt,
    String? updatedAt,
  });

  @override
  $ChatContextCopyWith<$Res>? get context;
}

/// @nodoc
class __$$ChatSessionImplCopyWithImpl<$Res>
    extends _$ChatSessionCopyWithImpl<$Res, _$ChatSessionImpl>
    implements _$$ChatSessionImplCopyWith<$Res> {
  __$$ChatSessionImplCopyWithImpl(
    _$ChatSessionImpl _value,
    $Res Function(_$ChatSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = freezed,
    Object? context = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ChatSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        context: freezed == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as ChatContext?,
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
class _$ChatSessionImpl implements _ChatSession {
  const _$ChatSessionImpl({
    required this.id,
    this.userId,
    this.context,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$ChatSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String? userId;
  @override
  final ChatContext? context;
  @override
  final String createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'ChatSession(id: $id, userId: $userId, context: $context, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, context, createdAt, updatedAt);

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      __$$ChatSessionImplCopyWithImpl<_$ChatSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatSessionImplToJson(this);
  }
}

abstract class _ChatSession implements ChatSession {
  const factory _ChatSession({
    required final String id,
    final String? userId,
    final ChatContext? context,
    required final String createdAt,
    final String? updatedAt,
  }) = _$ChatSessionImpl;

  factory _ChatSession.fromJson(Map<String, dynamic> json) =
      _$ChatSessionImpl.fromJson;

  @override
  String get id;
  @override
  String? get userId;
  @override
  ChatContext? get context;
  @override
  String get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of ChatSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatSessionImplCopyWith<_$ChatSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Citation _$CitationFromJson(Map<String, dynamic> json) {
  return _Citation.fromJson(json);
}

/// @nodoc
mixin _$Citation {
  String get source => throw _privateConstructorUsedError;
  String get excerpt => throw _privateConstructorUsedError;
  double? get score => throw _privateConstructorUsedError;

  /// Serializes this Citation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Citation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CitationCopyWith<Citation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CitationCopyWith<$Res> {
  factory $CitationCopyWith(Citation value, $Res Function(Citation) then) =
      _$CitationCopyWithImpl<$Res, Citation>;
  @useResult
  $Res call({String source, String excerpt, double? score});
}

/// @nodoc
class _$CitationCopyWithImpl<$Res, $Val extends Citation>
    implements $CitationCopyWith<$Res> {
  _$CitationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Citation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? excerpt = null,
    Object? score = freezed,
  }) {
    return _then(
      _value.copyWith(
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            excerpt: null == excerpt
                ? _value.excerpt
                : excerpt // ignore: cast_nullable_to_non_nullable
                      as String,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CitationImplCopyWith<$Res>
    implements $CitationCopyWith<$Res> {
  factory _$$CitationImplCopyWith(
    _$CitationImpl value,
    $Res Function(_$CitationImpl) then,
  ) = __$$CitationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String source, String excerpt, double? score});
}

/// @nodoc
class __$$CitationImplCopyWithImpl<$Res>
    extends _$CitationCopyWithImpl<$Res, _$CitationImpl>
    implements _$$CitationImplCopyWith<$Res> {
  __$$CitationImplCopyWithImpl(
    _$CitationImpl _value,
    $Res Function(_$CitationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Citation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? source = null,
    Object? excerpt = null,
    Object? score = freezed,
  }) {
    return _then(
      _$CitationImpl(
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        excerpt: null == excerpt
            ? _value.excerpt
            : excerpt // ignore: cast_nullable_to_non_nullable
                  as String,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CitationImpl implements _Citation {
  const _$CitationImpl({
    required this.source,
    required this.excerpt,
    this.score,
  });

  factory _$CitationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CitationImplFromJson(json);

  @override
  final String source;
  @override
  final String excerpt;
  @override
  final double? score;

  @override
  String toString() {
    return 'Citation(source: $source, excerpt: $excerpt, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CitationImpl &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.excerpt, excerpt) || other.excerpt == excerpt) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, source, excerpt, score);

  /// Create a copy of Citation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CitationImplCopyWith<_$CitationImpl> get copyWith =>
      __$$CitationImplCopyWithImpl<_$CitationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CitationImplToJson(this);
  }
}

abstract class _Citation implements Citation {
  const factory _Citation({
    required final String source,
    required final String excerpt,
    final double? score,
  }) = _$CitationImpl;

  factory _Citation.fromJson(Map<String, dynamic> json) =
      _$CitationImpl.fromJson;

  @override
  String get source;
  @override
  String get excerpt;
  @override
  double? get score;

  /// Create a copy of Citation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CitationImplCopyWith<_$CitationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  MessageRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<Citation>? get citations => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
    ChatMessage value,
    $Res Function(ChatMessage) then,
  ) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    MessageRole role,
    String content,
    List<Citation>? citations,
    String createdAt,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? role = null,
    Object? content = null,
    Object? citations = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as MessageRole,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            citations: freezed == citations
                ? _value.citations
                : citations // ignore: cast_nullable_to_non_nullable
                      as List<Citation>?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
    _$ChatMessageImpl value,
    $Res Function(_$ChatMessageImpl) then,
  ) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    MessageRole role,
    String content,
    List<Citation>? citations,
    String createdAt,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
    _$ChatMessageImpl _value,
    $Res Function(_$ChatMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? role = null,
    Object? content = null,
    Object? citations = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ChatMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as MessageRole,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        citations: freezed == citations
            ? _value._citations
            : citations // ignore: cast_nullable_to_non_nullable
                  as List<Citation>?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    final List<Citation>? citations,
    required this.createdAt,
  }) : _citations = citations;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final MessageRole role;
  @override
  final String content;
  final List<Citation>? _citations;
  @override
  List<Citation>? get citations {
    final value = _citations;
    if (value == null) return null;
    if (_citations is EqualUnmodifiableListView) return _citations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String createdAt;

  @override
  String toString() {
    return 'ChatMessage(id: $id, sessionId: $sessionId, role: $role, content: $content, citations: $citations, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._citations,
              _citations,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    role,
    content,
    const DeepCollectionEquality().hash(_citations),
    createdAt,
  );

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String sessionId,
    required final MessageRole role,
    required final String content,
    final List<Citation>? citations,
    required final String createdAt,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  MessageRole get role;
  @override
  String get content;
  @override
  List<Citation>? get citations;
  @override
  String get createdAt;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) {
  return _ChatResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatResponse {
  String get content => throw _privateConstructorUsedError;
  List<Citation>? get citations => throw _privateConstructorUsedError;

  /// Serializes this ChatResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatResponseCopyWith<ChatResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatResponseCopyWith<$Res> {
  factory $ChatResponseCopyWith(
    ChatResponse value,
    $Res Function(ChatResponse) then,
  ) = _$ChatResponseCopyWithImpl<$Res, ChatResponse>;
  @useResult
  $Res call({String content, List<Citation>? citations});
}

/// @nodoc
class _$ChatResponseCopyWithImpl<$Res, $Val extends ChatResponse>
    implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null, Object? citations = freezed}) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            citations: freezed == citations
                ? _value.citations
                : citations // ignore: cast_nullable_to_non_nullable
                      as List<Citation>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatResponseImplCopyWith<$Res>
    implements $ChatResponseCopyWith<$Res> {
  factory _$$ChatResponseImplCopyWith(
    _$ChatResponseImpl value,
    $Res Function(_$ChatResponseImpl) then,
  ) = __$$ChatResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content, List<Citation>? citations});
}

/// @nodoc
class __$$ChatResponseImplCopyWithImpl<$Res>
    extends _$ChatResponseCopyWithImpl<$Res, _$ChatResponseImpl>
    implements _$$ChatResponseImplCopyWith<$Res> {
  __$$ChatResponseImplCopyWithImpl(
    _$ChatResponseImpl _value,
    $Res Function(_$ChatResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null, Object? citations = freezed}) {
    return _then(
      _$ChatResponseImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        citations: freezed == citations
            ? _value._citations
            : citations // ignore: cast_nullable_to_non_nullable
                  as List<Citation>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatResponseImpl implements _ChatResponse {
  const _$ChatResponseImpl({
    required this.content,
    final List<Citation>? citations,
  }) : _citations = citations;

  factory _$ChatResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatResponseImplFromJson(json);

  @override
  final String content;
  final List<Citation>? _citations;
  @override
  List<Citation>? get citations {
    final value = _citations;
    if (value == null) return null;
    if (_citations is EqualUnmodifiableListView) return _citations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ChatResponse(content: $content, citations: $citations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatResponseImpl &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(
              other._citations,
              _citations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    content,
    const DeepCollectionEquality().hash(_citations),
  );

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      __$$ChatResponseImplCopyWithImpl<_$ChatResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatResponseImplToJson(this);
  }
}

abstract class _ChatResponse implements ChatResponse {
  const factory _ChatResponse({
    required final String content,
    final List<Citation>? citations,
  }) = _$ChatResponseImpl;

  factory _ChatResponse.fromJson(Map<String, dynamic> json) =
      _$ChatResponseImpl.fromJson;

  @override
  String get content;
  @override
  List<Citation>? get citations;

  /// Create a copy of ChatResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) {
  return _SendMessageRequest.fromJson(json);
}

/// @nodoc
mixin _$SendMessageRequest {
  String get content => throw _privateConstructorUsedError;

  /// Serializes this SendMessageRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SendMessageRequestCopyWith<SendMessageRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SendMessageRequestCopyWith<$Res> {
  factory $SendMessageRequestCopyWith(
    SendMessageRequest value,
    $Res Function(SendMessageRequest) then,
  ) = _$SendMessageRequestCopyWithImpl<$Res, SendMessageRequest>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$SendMessageRequestCopyWithImpl<$Res, $Val extends SendMessageRequest>
    implements $SendMessageRequestCopyWith<$Res> {
  _$SendMessageRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null}) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SendMessageRequestImplCopyWith<$Res>
    implements $SendMessageRequestCopyWith<$Res> {
  factory _$$SendMessageRequestImplCopyWith(
    _$SendMessageRequestImpl value,
    $Res Function(_$SendMessageRequestImpl) then,
  ) = __$$SendMessageRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$SendMessageRequestImplCopyWithImpl<$Res>
    extends _$SendMessageRequestCopyWithImpl<$Res, _$SendMessageRequestImpl>
    implements _$$SendMessageRequestImplCopyWith<$Res> {
  __$$SendMessageRequestImplCopyWithImpl(
    _$SendMessageRequestImpl _value,
    $Res Function(_$SendMessageRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? content = null}) {
    return _then(
      _$SendMessageRequestImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SendMessageRequestImpl implements _SendMessageRequest {
  const _$SendMessageRequestImpl({required this.content});

  factory _$SendMessageRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SendMessageRequestImplFromJson(json);

  @override
  final String content;

  @override
  String toString() {
    return 'SendMessageRequest(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SendMessageRequestImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content);

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SendMessageRequestImplCopyWith<_$SendMessageRequestImpl> get copyWith =>
      __$$SendMessageRequestImplCopyWithImpl<_$SendMessageRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SendMessageRequestImplToJson(this);
  }
}

abstract class _SendMessageRequest implements SendMessageRequest {
  const factory _SendMessageRequest({required final String content}) =
      _$SendMessageRequestImpl;

  factory _SendMessageRequest.fromJson(Map<String, dynamic> json) =
      _$SendMessageRequestImpl.fromJson;

  @override
  String get content;

  /// Create a copy of SendMessageRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SendMessageRequestImplCopyWith<_$SendMessageRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateSessionRequest _$CreateSessionRequestFromJson(Map<String, dynamic> json) {
  return _CreateSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateSessionRequest {
  String? get userId => throw _privateConstructorUsedError;
  ChatContext? get context => throw _privateConstructorUsedError;

  /// Serializes this CreateSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSessionRequestCopyWith<CreateSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSessionRequestCopyWith<$Res> {
  factory $CreateSessionRequestCopyWith(
    CreateSessionRequest value,
    $Res Function(CreateSessionRequest) then,
  ) = _$CreateSessionRequestCopyWithImpl<$Res, CreateSessionRequest>;
  @useResult
  $Res call({String? userId, ChatContext? context});

  $ChatContextCopyWith<$Res>? get context;
}

/// @nodoc
class _$CreateSessionRequestCopyWithImpl<
  $Res,
  $Val extends CreateSessionRequest
>
    implements $CreateSessionRequestCopyWith<$Res> {
  _$CreateSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = freezed, Object? context = freezed}) {
    return _then(
      _value.copyWith(
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            context: freezed == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as ChatContext?,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatContextCopyWith<$Res>? get context {
    if (_value.context == null) {
      return null;
    }

    return $ChatContextCopyWith<$Res>(_value.context!, (value) {
      return _then(_value.copyWith(context: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateSessionRequestImplCopyWith<$Res>
    implements $CreateSessionRequestCopyWith<$Res> {
  factory _$$CreateSessionRequestImplCopyWith(
    _$CreateSessionRequestImpl value,
    $Res Function(_$CreateSessionRequestImpl) then,
  ) = __$$CreateSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? userId, ChatContext? context});

  @override
  $ChatContextCopyWith<$Res>? get context;
}

/// @nodoc
class __$$CreateSessionRequestImplCopyWithImpl<$Res>
    extends _$CreateSessionRequestCopyWithImpl<$Res, _$CreateSessionRequestImpl>
    implements _$$CreateSessionRequestImplCopyWith<$Res> {
  __$$CreateSessionRequestImplCopyWithImpl(
    _$CreateSessionRequestImpl _value,
    $Res Function(_$CreateSessionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = freezed, Object? context = freezed}) {
    return _then(
      _$CreateSessionRequestImpl(
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        context: freezed == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as ChatContext?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSessionRequestImpl implements _CreateSessionRequest {
  const _$CreateSessionRequestImpl({this.userId, this.context});

  factory _$CreateSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSessionRequestImplFromJson(json);

  @override
  final String? userId;
  @override
  final ChatContext? context;

  @override
  String toString() {
    return 'CreateSessionRequest(userId: $userId, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSessionRequestImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.context, context) || other.context == context));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, context);

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSessionRequestImplCopyWith<_$CreateSessionRequestImpl>
  get copyWith =>
      __$$CreateSessionRequestImplCopyWithImpl<_$CreateSessionRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSessionRequestImplToJson(this);
  }
}

abstract class _CreateSessionRequest implements CreateSessionRequest {
  const factory _CreateSessionRequest({
    final String? userId,
    final ChatContext? context,
  }) = _$CreateSessionRequestImpl;

  factory _CreateSessionRequest.fromJson(Map<String, dynamic> json) =
      _$CreateSessionRequestImpl.fromJson;

  @override
  String? get userId;
  @override
  ChatContext? get context;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSessionRequestImplCopyWith<_$CreateSessionRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
