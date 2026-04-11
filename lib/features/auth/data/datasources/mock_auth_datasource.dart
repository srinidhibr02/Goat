import 'dart:async';

import 'package:goat/core/errors/exceptions.dart';

import '../../domain/entities/app_user.dart';
import 'auth_datasource.dart';

/// In-memory mock implementation of [AuthDatasource].
///
/// Accepts any valid email/password combination (email must contain '@',
/// password must be ≥ 6 characters). No network calls are made.
///
/// To swap in real Firebase Auth, implement [AuthDatasource] using
/// `firebase_auth` and replace this in the provider.
class MockAuthDatasource implements AuthDatasource {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  // ── AuthDatasource ───────────────────────────────────────────────────────

  @override
  Stream<AppUser?> get authStateChanges async* {
    // Immediately emit the current auth state (null = signed out),
    // then forward every future event from the broadcast controller.
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _validateEmail(email);
    _validatePassword(password);
    return _setUser(AppUser(
      uid: 'mock-${email.hashCode.abs()}',
      email: email,
      displayName: email.split('@').first,
    ));
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    return _setUser(const AppUser(
      uid: 'google-mock-001',
      email: 'user@gmail.com',
      displayName: 'Google User',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
    ));
  }

  @override
  Future<AppUser> createUserWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    _validateEmail(email);
    _validatePassword(password);
    final name = displayName.trim().isEmpty
        ? email.split('@').first
        : displayName.trim();
    return _setUser(AppUser(
      uid: 'mock-${email.hashCode.abs()}',
      email: email,
      displayName: name,
    ));
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _validateEmail(email);
    // In mock mode this is a no-op — just validates the email format.
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  AppUser _setUser(AppUser user) {
    _currentUser = user;
    _controller.add(_currentUser);
    return user;
  }

  void _validateEmail(String email) {
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
      throw AuthException.invalidCredentials;
    }
  }

  void _validatePassword(String password) {
    if (password.length < 6) throw AuthException.weakPassword;
  }

  void dispose() => _controller.close();
}
