import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/firebase_profile_datasource.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

// ── SharedPreferences ─────────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  ),
);

// ── Theme ─────────────────────────────────────────────────────────────────────

const _themeKey = 'theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(ref.watch(sharedPreferencesProvider)),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  ThemeNotifier(this._prefs) : super(_loadTheme(_prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    return switch (prefs.getString(_themeKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    _prefs.setString(_themeKey, mode.name);
  }

  void toggle(bool isDark) => setTheme(isDark ? ThemeMode.dark : ThemeMode.light);
}

// ── Profile Repository ────────────────────────────────────────────────────────

final _profileDatasourceProvider = Provider<ProfileDatasource>((ref) {
  try {
    Firebase.app();
    return FirebaseProfileDatasource();
  } catch (_) {
    return _NoOpProfileDatasource();
  }
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(_profileDatasourceProvider)),
);

// ── Profile Controller ────────────────────────────────────────────────────────

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(ProfileController.new);

class ProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> updateDisplayName(String uid, String displayName) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateDisplayName(uid, displayName);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// ── No-op fallback (no Firebase) ──────────────────────────────────────────────

class _NoOpProfileDatasource implements ProfileDatasource {
  @override
  Future<void> updateDisplayName(String uid, String displayName) async {}
  @override
  Future<void> updatePhotoUrl(String uid, String photoUrl) async {}
}
