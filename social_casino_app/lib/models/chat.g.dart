// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatContextImpl _$$ChatContextImplFromJson(Map<String, dynamic> json) =>
    _$ChatContextImpl(
      currentPage: json['currentPage'] as String?,
      currentGame: json['currentGame'] as String?,
      gameSlug: json['gameSlug'] as String?,
      vipLevel: json['vipLevel'] as String?,
    );

Map<String, dynamic> _$$ChatContextImplToJson(_$ChatContextImpl instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'currentGame': instance.currentGame,
      'gameSlug': instance.gameSlug,
      'vipLevel': instance.vipLevel,
    };

_$ChatSessionImpl _$$ChatSessionImplFromJson(Map<String, dynamic> json) =>
    _$ChatSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      context: json['context'] == null
          ? null
          : ChatContext.fromJson(json['context'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$ChatSessionImplToJson(_$ChatSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'context': instance.context,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$CitationImpl _$$CitationImplFromJson(Map<String, dynamic> json) =>
    _$CitationImpl(
      source: json['source'] as String,
      excerpt: json['excerpt'] as String,
      score: (json['score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CitationImplToJson(_$CitationImpl instance) =>
    <String, dynamic>{
      'source': instance.source,
      'excerpt': instance.excerpt,
      'score': instance.score,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      content: json['content'] as String,
      citations: (json['citations'] as List<dynamic>?)
          ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'citations': instance.citations,
      'createdAt': instance.createdAt,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
};

_$ChatResponseImpl _$$ChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$ChatResponseImpl(
      content: json['content'] as String,
      citations: (json['citations'] as List<dynamic>?)
          ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ChatResponseImplToJson(_$ChatResponseImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
      'citations': instance.citations,
    };

_$SendMessageRequestImpl _$$SendMessageRequestImplFromJson(
  Map<String, dynamic> json,
) => _$SendMessageRequestImpl(content: json['content'] as String);

Map<String, dynamic> _$$SendMessageRequestImplToJson(
  _$SendMessageRequestImpl instance,
) => <String, dynamic>{'content': instance.content};

_$CreateSessionRequestImpl _$$CreateSessionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateSessionRequestImpl(
  userId: json['userId'] as String?,
  context: json['context'] == null
      ? null
      : ChatContext.fromJson(json['context'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CreateSessionRequestImplToJson(
  _$CreateSessionRequestImpl instance,
) => <String, dynamic>{'userId': instance.userId, 'context': instance.context};
