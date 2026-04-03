/// Application-wide constants.
///
/// Centralizes magic strings and configuration values so they can be
/// changed in one place without hunting through the codebase.
abstract final class AppConstants {
  // ── App Identity ──────────────────────────────────────────────────────
  static const String appName = 'GOAT';
  static const String appFullName = 'Guide Of All Temples';
  static const String appVersion = '1.0.0';

  // ── API ───────────────────────────────────────────────────────────────
  /// Base URL for the REST API. Replace with the real endpoint when ready.
  static const String apiBaseUrl = 'https://api.example.com/v1';

  // ── Timeouts (in seconds) ─────────────────────────────────────────────
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // ── Pagination ────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;

  // ── Animation Durations (in milliseconds) ─────────────────────────────
  static const int splashDuration = 2500;
  static const int defaultAnimationDuration = 300;
}
