import 'package:flutter/foundation.dart';

/// Centralized logging utility to replace print statements
/// Only logs in debug mode to improve production performance
class AppLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('$prefix $message');
    }
  }

  static void error(String message, {String? tag, Object? error}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('$prefix ❌ $message${error != null ? ': $error' : ''}');
    }
  }

  static void success(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('$prefix ✅ $message');
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('$prefix ⚠️ $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag]' : '';
      print('$prefix ℹ️ $message');
    }
  }
}

