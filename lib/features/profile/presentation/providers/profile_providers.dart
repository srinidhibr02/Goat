import 'dart:async';
import 'dart:io';

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

// ── Notification Preferences ──────────────────────────────────────────────────

const _notifGeneralKey = 'notif_general';
const _notifEventsKey = 'notif_events';
const _notifBookingsKey = 'notif_bookings';

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, Map<String, bool>>(
  (ref) => NotificationPrefsNotifier(ref.watch(sharedPreferencesProvider)),
);

class NotificationPrefsNotifier extends StateNotifier<Map<String, bool>> {
  final SharedPreferences _prefs;

  NotificationPrefsNotifier(this._prefs)
      : super({
          _notifGeneralKey: _prefs.getBool(_notifGeneralKey) ?? true,
          _notifEventsKey: _prefs.getBool(_notifEventsKey) ?? true,
          _notifBookingsKey: _prefs.getBool(_notifBookingsKey) ?? true,
        });

  void toggle(String key) {
    final newVal = !(state[key] ?? true);
    state = {...state, key: newVal};
    _prefs.setBool(key, newVal);
  }

  bool get generalEnabled => state[_notifGeneralKey] ?? true;
  bool get eventsEnabled => state[_notifEventsKey] ?? true;
  bool get bookingsEnabled => state[_notifBookingsKey] ?? true;
}

// Expose keys for use in the UI
const notifGeneralKey = _notifGeneralKey;
const notifEventsKey = _notifEventsKey;
const notifBookingsKey = _notifBookingsKey;

// ── Profile Repository ────────────────────────────────────────────────────────

/// Exposes the Firebase datasource directly so controllers can call
/// Firebase-specific methods like [FirebaseProfileDatasource.uploadAndSetAvatar].
final firebaseProfileDatasourceProvider =
    Provider<FirebaseProfileDatasource?>((ref) {
  try {
    Firebase.app();
    return FirebaseProfileDatasource();
  } catch (_) {
    return null;
  }
});

final _profileDatasourceProvider = Provider<ProfileDatasource>((ref) {
  return ref.watch(firebaseProfileDatasourceProvider) ??
      _NoOpProfileDatasource();
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

  /// Picks and uploads an avatar image. Returns the download URL on success,
  /// or `null` if Firebase Storage is unavailable.
  Future<String?> uploadAvatar(String uid, File imageFile) async {
    state = const AsyncLoading();
    try {
      final ds = ref.read(firebaseProfileDatasourceProvider);
      if (ds == null) {
        state = const AsyncData(null);
        return null;
      }
      final url = await ds.uploadAndSetAvatar(uid, imageFile);
      state = const AsyncData(null);
      return url;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
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

