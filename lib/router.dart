import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/domain/entities/app_user.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/sign_up_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/bookings/presentation/pages/booking_flow_page.dart';
import 'features/bookings/presentation/pages/bookings_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/temples/domain/entities/temple.dart';
import 'features/temples/presentation/pages/explore_page.dart';
import 'features/temples/presentation/pages/home_page.dart';
import 'features/temples/presentation/pages/temple_detail_page.dart';
import 'shared/widgets/app_shell.dart';

// ── Route names / paths ───────────────────────────────────────────────────────

const _publicPaths = {'/login', '/sign-up', '/forgot-password'};

// ── Router notifier ───────────────────────────────────────────────────────────

/// Bridges Riverpod's [authStateProvider] with GoRouter's refresh system.
///
/// Implements [Listenable] so GoRouter re-evaluates redirects whenever
/// the auth state changes.
class RouterNotifier extends AsyncNotifier<void> implements Listenable {
  VoidCallback? _routerListener;

  @override
  FutureOr<void> build() {
    // Notify GoRouter whenever auth state changes.
    ref.listen<AsyncValue<AppUser?>>(
      authStateProvider,
      (_, __) => _routerListener?.call(),
    );
  }

  /// GoRouter redirect logic — called on every navigation event.
  String? redirect(BuildContext context, GoRouterState state) {
    final auth = ref.read(authStateProvider);
    final location = state.matchedLocation;

    // While auth is initialising, keep showing splash.
    if (auth.isLoading || auth.hasError) return null;

    final isLoggedIn = auth.valueOrNull != null;
    final isSplash = location == '/';
    final isPublic = _publicPaths.contains(location);

    // Splash is transient — always redirect once auth resolves.
    if (isSplash) return isLoggedIn ? '/home' : '/login';

    // Protect private routes.
    if (!isLoggedIn && !isPublic) return '/login';

    // Redirect authenticated users away from auth screens.
    if (isLoggedIn && isPublic) return '/home';

    return null;
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;
}

final routerNotifierProvider =
    AsyncNotifierProvider<RouterNotifier, void>(RouterNotifier.new);

// ── Router provider ───────────────────────────────────────────────────────────

/// Provides the app's [GoRouter] instance, wired to auth-aware redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider.notifier);

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // ── Public routes (no bottom nav) ────────────────────────────────
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign-up',
        builder: (_, __) => const SignUpPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // ── Detail page (no bottom nav) ──────────────────────────────────
      GoRoute(
        path: '/temple/:id',
        name: 'temple-detail',
        builder: (_, state) {
          final temple = state.extra as Temple;
          return TempleDetailPage(temple: temple);
        },
      ),

      // ── Booking flow (no bottom nav) ─────────────────────────────────
      GoRoute(
        path: '/book/:templeId',
        name: 'booking-flow',
        builder: (_, state) {
          final temple = state.extra as Temple;
          return BookingFlowPage(temple: temple);
        },
      ),

      // ── Tabbed shell (bottom nav) ────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (_, __) => const HomePage(),
              ),
            ],
          ),
          // Tab 1: Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                name: 'explore',
                builder: (_, __) => const ExplorePage(),
              ),
            ],
          ),
          // Tab 2: Bookings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                name: 'bookings',
                builder: (_, __) => const BookingsPage(),
              ),
            ],
          ),
          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (_, __) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
