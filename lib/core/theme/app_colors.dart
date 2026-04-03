import 'package:flutter/material.dart';

/// Central color system for GOAT.
///
/// Built around a saffron / orange / yellow palette that reflects
/// the spiritual and temple-centric nature of the app.
abstract final class AppColors {
  // ── Brand Palette ─────────────────────────────────────────────────────
  static const Color saffron = Color(0xFFFF9933);
  static const Color deepSaffron = Color(0xFFFF7722);
  static const Color turmeric = Color(0xFFFFC107);
  static const Color marigold = Color(0xFFFFAB40);
  static const Color templeGold = Color(0xFFD4A017);
  static const Color vermillion = Color(0xFFE23727);

  // ── Light Theme Tokens ────────────────────────────────────────────────
  static const Color lightPrimary = saffron;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightPrimaryContainer = Color(0xFFFFE0B2);
  static const Color lightOnPrimaryContainer = Color(0xFF5D2E00);

  static const Color lightSecondary = Color(0xFF8B5E3C);
  static const Color lightOnSecondary = Colors.white;
  static const Color lightSecondaryContainer = Color(0xFFFFDCC2);
  static const Color lightOnSecondaryContainer = Color(0xFF3B1E00);

  static const Color lightTertiary = templeGold;
  static const Color lightOnTertiary = Colors.white;

  static const Color lightSurface = Color(0xFFFFFBF7);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightSurfaceVariant = Color(0xFFF5EDE4);
  static const Color lightOnSurfaceVariant = Color(0xFF4E4540);

  static const Color lightBackground = Color(0xFFFFFBF7);
  static const Color lightOnBackground = Color(0xFF1C1B1F);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Colors.white;

  static const Color lightOutline = Color(0xFF857568);

  // ── Dark Theme Tokens ─────────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFFFFB74D);
  static const Color darkOnPrimary = Color(0xFF4A2800);
  static const Color darkPrimaryContainer = Color(0xFF6B3A00);
  static const Color darkOnPrimaryContainer = Color(0xFFFFDDB3);

  static const Color darkSecondary = Color(0xFFE6BE9C);
  static const Color darkOnSecondary = Color(0xFF3B1E00);
  static const Color darkSecondaryContainer = Color(0xFF5A3D22);
  static const Color darkOnSecondaryContainer = Color(0xFFFFDCC2);

  static const Color darkTertiary = Color(0xFFFFD54F);
  static const Color darkOnTertiary = Color(0xFF3F2E00);

  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkSurfaceVariant = Color(0xFF4E4540);
  static const Color darkOnSurfaceVariant = Color(0xFFD2C4B9);

  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkOnBackground = Color(0xFFE6E1E5);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);

  static const Color darkOutline = Color(0xFF9C8E84);
}
