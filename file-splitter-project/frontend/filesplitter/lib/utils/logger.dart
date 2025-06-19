import 'package:flutter/foundation.dart'; // For kDebugMode

class Logger {
  static void init() {
    // Optionally configure a logging package here if needed,
    // e.g., logger, build_log, etc.
    // For now, a simple print-based logger is sufficient.
    debugPrint("Logger initialized.");
  }

  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
      if (stackTrace != null) {
        debugPrint('[STACK] $stackTrace');
      }
    }
  }

  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    // Can be used for important information even in release mode
    debugPrint('[INFO] $message');
    if (error != null) {
      debugPrint('[ERROR] $error');
    }
    if (stackTrace != null) {
      debugPrint('[STACK] $stackTrace');
    }
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR_DETAIL] $error');
    }
    if (stackTrace != null) {
      debugPrint('[STACK_TRACE] $stackTrace');
    }
  }
}
