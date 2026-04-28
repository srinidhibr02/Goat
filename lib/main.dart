import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'core/services/push_notifications_service.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';
import 'features/profile/presentation/providers/profile_providers.dart';
import 'firebase_options.dart';

/// Entry point for GOAT — Guide Of All Temples.
///
/// 1. Sets up global error handlers.
/// 2. Initialises Flutter bindings.
/// 3. Initialises SharedPreferences.
/// 4. Initialises Firebase.
/// 5. Wraps the app in [ProviderScope] for Riverpod.
void main() {
  ErrorHandler.run(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ── SharedPreferences ─────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();

    // ── Firebase ────────────────────────────────────────────────────
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized successfully (goat-d3152)');

      // ── Crashlytics ────────────────────────────────────────────────
      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // ── Firestore Offline Cache ────────────────────────────────────
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // ── Push Notifications ─────────────────────────────────────────
      final pushService = PushNotificationsService();
      await pushService.init();
      AppLogger.info('Push notifications initialized');
    } catch (e, st) {
      AppLogger.error(
        'Firebase initialization failed',
        error: e,
        stackTrace: st,
      );
    }

    // ── Launch ──────────────────────────────────────────────────────
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const GoatApp(),
      ),
    );
  });
}

