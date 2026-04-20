import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── SharedPreferences provider ───────────────────────────────────────────────

/// Must be overridden in the ProviderScope at app startup.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  ),
);

// ── Theme Mode ───────────────────────────────────────────────────────────────

const _themeKey = 'theme_mode';

/// Holds the user's preferred [ThemeMode].
///
/// Persists to SharedPreferences so the choice survives app restarts.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ThemeNotifier(prefs);
  },
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final value = prefs.getString(_themeKey);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _prefs.setString(_themeKey, mode.name);
  }

  void toggle(bool isDark) {
    setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
