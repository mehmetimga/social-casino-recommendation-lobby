class ApiConfig {
  static const String cmsBaseUrl = 'http://localhost:3001';
  static const String recommendationBaseUrl = 'http://localhost:8081';
  static const String chatBaseUrl = 'http://localhost:8082';

  static String getMediaUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return '$cmsBaseUrl$path';
  }
}
