import 'package:goat/core/utils/result.dart';

import '../entities/app_user.dart';

/// Contract between domain and data layers for authentication.
///
/// Repositories catch raw exceptions from the data source and
/// return typed [Result] values so the presentation layer never
/// handles exceptions directly.
abstract interface class AuthRepository {
  /// Emits the current user on subscription, then updates on sign-in/out.
  Stream<AppUser?> get authStateChanges;

  Future<Result<AppUser>> signInWithEmail(String email, String password);

  Future<Result<AppUser>> signInWithGoogle();

  Future<Result<AppUser>> createUserWithEmail(
    String email,
    String password,
    String displayName,
  );

  Future<Result<Unit>> signOut();

  Future<Result<Unit>> sendPasswordResetEmail(String email);
}
