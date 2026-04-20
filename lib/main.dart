import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/logger.dart';
import 'features/profile/presentation/providers/profile_providers.dart';

/// Entry point for GOAT — Guide Of All Temples.
///
/// 1. Sets up global error handlers.
/// 2. Initialises Flutter bindings.
/// 3. Initialises SharedPreferences.
/// 4. Attempts Firebase initialization (guarded).
/// 5. Wraps the app in [ProviderScope] for Riverpod.
void main() {
  ErrorHandler.run(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // ── SharedPreferences ─────────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();

    // ── Firebase (guarded) ──────────────────────────────────────────
    // Firebase.initializeApp() requires platform config files
    // (google-services.json / GoogleService-Info.plist).
    // Until those are added, initialization is skipped gracefully.
    try {
      // Uncomment the following lines once Firebase is configured:
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      AppLogger.info('Firebase initialization skipped (not yet configured)');
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
