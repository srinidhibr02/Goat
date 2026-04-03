import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';

/// Root application widget.
///
/// Uses [MaterialApp.router] with GoRouter and the GOAT theme system.
/// Wrapped in a [ConsumerWidget] so any Riverpod provider can be
/// consumed at the app level if needed in the future.
class GoatApp extends ConsumerWidget {
  const GoatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // ── Identity ──────────────────────────────────────────────────
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // ── Theme ─────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ── Routing ───────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}
