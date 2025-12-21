import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/cms_service.dart';
import '../services/recommendation_service.dart';
import '../services/chat_service.dart';

/// Singleton API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// CMS service provider
final cmsServiceProvider = Provider<CmsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CmsService(apiClient);
});

/// Recommendation service provider
final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecommendationService(apiClient);
});

/// Chat service provider
final chatServiceProvider = Provider<ChatService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatService(apiClient);
});
