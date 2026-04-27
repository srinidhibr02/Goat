

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:goat/core/constants/app_constants.dart';

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

// ── Splash Timer logic ────────────────────────────────────────────────────────

/// Enforces a minimum splash duration so the animation finishes playing.
final splashStateProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: AppConstants.splashDuration));
});

// ── Router notifier ───────────────────────────────────────────────────────────

/// Bridges Riverpod's [authStateProvider] with GoRouter's refresh system.
class RouterNotifier extends ChangeNotifier {
  final Ref ref;

  RouterNotifier(this.ref) {
    // Notify GoRouter when auth state changes
    ref.listen<AsyncValue<AppUser?>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    // Notify GoRouter when the initial splash timer is done
    ref.listen<AsyncValue<void>>(
      splashStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  /// GoRouter redirect logic — called on every navigation event.
  String? redirect(BuildContext context, GoRouterState state) {
    final auth = ref.read(authStateProvider);
    final splash = ref.read(splashStateProvider);
    final location = state.matchedLocation;

    debugPrint('RouterNotifier.redirect: location=$location, authLoading=${auth.isLoading}, splashLoading=${splash.isLoading}');

    // While auth is initialising or splash timer is ticking, keep showing splash.
    if (auth.isLoading || auth.hasError || splash.isLoading) return null;

    final isLoggedIn = auth.valueOrNull != null;
    final isSplash = location == '/';
    final isPublic = _publicPaths.contains(location);

    // Splash is transient — always redirect once auth resolves.
    if (isSplash) {
      debugPrint('RouterNotifier.redirect: Redirecting from Splash -> ${isLoggedIn ? '/home' : '/login'}');
      return isLoggedIn ? '/home' : '/login';
    }

    // Protect private routes.
    if (!isLoggedIn && !isPublic) {
      debugPrint('RouterNotifier.redirect: Redirecting to /login (protected)');
      return '/login';
    }

    // Redirect authenticated users away from auth screens.
    if (isLoggedIn && isPublic) {
      debugPrint('RouterNotifier.redirect: Redirecting to /home (already logged in)');
      return '/home';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// ── Router provider ───────────────────────────────────────────────────────────

/// Provides the app's [GoRouter] instance, wired to auth-aware redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);


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
        pageBuilder: (context, state) {
          final temple = state.extra as Temple;
          return CustomTransitionPage(
            key: state.pageKey,
            child: TempleDetailPage(temple: temple),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
          );
        },
      ),

      // ── Booking flow (no bottom nav) ─────────────────────────────────
      GoRoute(
        path: '/book/:templeId',
        name: 'booking-flow',
        pageBuilder: (context, state) {
          final temple = state.extra as Temple;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BookingFlowPage(temple: temple),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
          );
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
