import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat/core/utils/result.dart';

import 'package:firebase_core/firebase_core.dart';

import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/mock_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Datasource ───────────────────────────────────────────────────────────────

final _authDatasourceProvider = Provider<AuthDatasource>((ref) {
  try {
    // If Firebase is configured, use real backend
    Firebase.app();
    return FirebaseAuthDatasource();
  } catch (_) {
    // Fallback to mock data
    final ds = MockAuthDatasource();
    ref.onDispose(ds.dispose);
    return ds;
  }
});

// ── Repository ───────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authDatasourceProvider)) as AuthRepository,
);

// ── Auth State Stream ────────────────────────────────────────────────────────

/// Streams the currently signed-in [AppUser], or `null` when signed out.
///
/// Starts with `AsyncLoading` until the first value arrives from the datasource.
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

// ── Auth Controller ──────────────────────────────────────────────────────────

/// Manages auth operations.  Listen to this provider for loading / error states.
///
/// ```dart
/// ref.listen<AsyncValue<void>>(authControllerProvider, (_, state) {
///   if (state case AsyncError(:final error)) { /* show snackbar */ }
/// });
/// ```
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  FutureOr<void> build() {
    // No initial async work needed.
  }

  Future<bool> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    final result = await _repo.signInWithEmail(email, password);
    return _handleResult(result);
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await _repo.signInWithGoogle();
    return _handleResult(result);
  }

  Future<bool> signUp(
      String email, String password, String displayName) async {
    state = const AsyncLoading();
    final result =
        await _repo.createUserWithEmail(email, password, displayName);
    return _handleResult(result);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _repo.signOut();
    state = const AsyncData(null);
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    final result = await _repo.sendPasswordResetEmail(email);
    return _handleResult(result);
  }

  // ── Private ────────────────────────────────────────────────────────────────

  bool _handleResult(Result<Object?> result) {
    switch (result) {
      case Ok():
        state = const AsyncData(null);
        return true;
      case Err(:final failure):
        state = AsyncError(failure.message, StackTrace.current);
        return false;
    }
  }
}
