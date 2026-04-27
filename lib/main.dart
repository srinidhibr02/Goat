import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
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

