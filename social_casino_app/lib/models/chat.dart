import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

enum MessageRole {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
}

@freezed
class ChatContext with _$ChatContext {
  const factory ChatContext({
    String? currentPage,
    String? currentGame,
    String? gameSlug,
    String? vipLevel,
  }) = _ChatContext;

  factory ChatContext.fromJson(Map<String, dynamic> json) =>
      _$ChatContextFromJson(json);
}

@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    String? userId,
    ChatContext? context,
    required String createdAt,
    String? updatedAt,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}

@freezed
class Citation with _$Citation {
  const factory Citation({
    required String source,
    required String excerpt,
    double? score,
  }) = _Citation;

  factory Citation.fromJson(Map<String, dynamic> json) =>
      _$CitationFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String sessionId,
    required MessageRole role,
    required String content,
    List<Citation>? citations,
    required String createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    required String content,
    List<Citation>? citations,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}

@freezed
class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String content,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}

@freezed
class CreateSessionRequest with _$CreateSessionRequest {
  const factory CreateSessionRequest({
    String? userId,
    ChatContext? context,
  }) = _CreateSessionRequest;

  factory CreateSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSessionRequestFromJson(json);
}
