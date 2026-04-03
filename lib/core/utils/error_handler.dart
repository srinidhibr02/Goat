import 'dart:async';

import 'package:flutter/foundation.dart';

import 'logger.dart';

/// Global error handling setup for the GOAT app.
///
/// Captures:
/// - Flutter framework errors (`FlutterError.onError`)
/// - Uncaught platform / async errors (`PlatformDispatcher.instance.onError`)
/// - Errors inside a guarded zone (`runZonedGuarded`)
///
/// Usage: wrap your `runApp()` call with [ErrorHandler.run].
abstract final class ErrorHandler {
  /// Runs [appRunner] inside a guarded zone with global error handlers
  /// installed.
  ///
  /// ```dart
  /// void main() {
  ///   ErrorHandler.run(() => runApp(const GoatApp()));
  /// }
  /// ```
  static void run(VoidCallback appRunner) {
    // ── Flutter framework errors ──────────────────────────────────────
    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.error(
        'Flutter framework error',
        tag: 'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );

      // In debug mode, also print the default Flutter rendering.
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // ── Platform / async errors ───────────────────────────────────────
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      AppLogger.error(
        'Uncaught platform error',
        tag: 'PlatformError',
        error: error,
        stackTrace: stack,
      );
      // Return true to prevent the error from propagating further.
      return true;
    };

    // ── Zone-guarded execution ────────────────────────────────────────
    runZonedGuarded(
      appRunner,
      (Object error, StackTrace stack) {
        AppLogger.error(
          'Uncaught zone error',
          tag: 'ZoneError',
          error: error,
          stackTrace: stack,
        );
      },
    );
  }
}
