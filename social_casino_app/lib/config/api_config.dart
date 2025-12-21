import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Get the host address for localhost based on platform
  /// - iOS Simulator: localhost works
  /// - Android Emulator: 10.0.2.2 is the alias for host machine's localhost
  /// - Web: localhost works
  /// - Physical devices: Use your machine's actual IP address
  static String get _host {
    if (kIsWeb) {
      return 'localhost';
    }
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    // iOS, macOS, Windows, Linux
    return 'localhost';
  }

  static String get cmsBaseUrl => 'http://$_host:3001';
  static String get recommendationBaseUrl => 'http://$_host:8081';
  static String get chatBaseUrl => 'http://$_host:8082';

  static String getMediaUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return '$cmsBaseUrl$path';
  }
}
