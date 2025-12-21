import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiClient {
  late final Dio cmsDio;
  late final Dio recommendationDio;
  late final Dio chatDio;

  ApiClient() {
    cmsDio = _createDio(ApiConfig.cmsBaseUrl);
    recommendationDio = _createDio(ApiConfig.recommendationBaseUrl);
    chatDio = _createDio(ApiConfig.chatBaseUrl);
  }

  Dio _createDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
