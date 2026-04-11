import '../../domain/entities/app_user.dart';

/// Abstract contract for the auth data source.
///
/// Throws [AuthException] on failure — the repository catches these
/// and converts them to domain [Failure]s.
abstract interface class AuthDatasource {
  /// Emits the current user immediately on subscription, then on each change.
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signInWithEmail(String email, String password);

  Future<AppUser> signInWithGoogle();

  Future<AppUser> createUserWithEmail(
    String email,
    String password,
    String displayName,
  );

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);
}
