import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/presentation/providers/profile_providers.dart';
import 'router.dart';

/// Root application widget.
///
/// Consumes [routerProvider] and [themeProvider] so the auth-aware
/// [GoRouter] and user's theme preference are wired in.
class GoatApp extends ConsumerWidget {
  const GoatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      // ── Identity ────────────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ── Routing ──────────────────────────────────────────────────────
      routerConfig: router,
    );
  }
}
