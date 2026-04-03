import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Lightweight structured logger for the GOAT app.
///
/// Wraps `dart:developer` log in debug mode. In release builds all
/// logging is silently suppressed to avoid leaking sensitive data.
abstract final class AppLogger {
  /// General informational message.
  static void info(
    String message, {
    String tag = 'GOAT',
  }) {
    _log(message, tag: tag, level: 800);
  }

  /// Warning — something unexpected but non-fatal.
  static void warning(
    String message, {
    String tag = 'GOAT',
  }) {
    _log('⚠️ $message', tag: tag, level: 900);
  }

  /// Error — something went wrong.
  static void error(
    String message, {
    String tag = 'GOAT',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      '❌ $message',
      tag: tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Debug-only trace message — stripped in release.
  static void debug(
    String message, {
    String tag = 'GOAT',
  }) {
    _log('🐛 $message', tag: tag, level: 500);
  }

  // ── Internal ────────────────────────────────────────────────────────

  static void _log(
    String message, {
    required String tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;

    developer.log(
      message,
      name: tag,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
