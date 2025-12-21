import 'package:dio/dio.dart';
import '../models/chat.dart';
import 'api_client.dart';

class ChatService {
  final Dio _dio;

  ChatService(ApiClient client) : _dio = client.chatDio;

  /// Create a new chat session
  Future<ChatSession> createSession({
    String? userId,
    ChatContext? context,
  }) async {
    try {
      final response = await _dio.post('/v1/chat/sessions', data: {
        if (userId != null) 'userId': userId,
        if (context != null) 'context': context.toJson(),
      });
      return ChatSession.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to create chat session',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Send a message and get AI response
  Future<ChatResponse> sendMessage(String sessionId, String content) async {
    try {
      final response = await _dio.post(
        '/v1/chat/sessions/$sessionId/messages',
        data: {'content': content},
      );
      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to send message',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }

  /// Update session context
  Future<void> updateContext(String sessionId, ChatContext context) async {
    try {
      await _dio.patch(
        '/v1/chat/sessions/$sessionId',
        data: {'context': context.toJson()},
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Failed to update context',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}
