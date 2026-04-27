import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_user.dart';
import 'auth_datasource.dart';

/// Real implementation of [AuthDatasource] using Firebase Auth.
class FirebaseAuthDatasource implements AuthDatasource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDatasource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Web client ID for Firebase Auth (client_type 3)
              serverClientId:
                  '377087662789-qn2l5v5o45hjveo9uae65lg2cc55j21t.apps.googleusercontent.com',
            );

  // ── AuthDatasource ───────────────────────────────────────────────────────

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user == null) throw AuthException.unknown;
      return _mapFirebaseUser(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw AuthException.unknown;
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        throw const AuthException('Google Sign-In cancelled.');
      }

      // 2. Obtain auth details
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Sign in to Firebase
      final cred = await _firebaseAuth.signInWithCredential(credential);
      if (cred.user == null) throw AuthException.unknown;
      
      return _mapFirebaseUser(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw AuthException.unknown;
    }
  }

  @override
  Future<AppUser> createUserWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user == null) throw AuthException.unknown;

      // Update display name
      if (displayName.trim().isNotEmpty) {
        await cred.user!.updateDisplayName(displayName.trim());
        await cred.user!.reload(); // Ensure user data is fresh
      }

      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) throw AuthException.unknown;

      return _mapFirebaseUser(updatedUser)!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw AuthException.unknown;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        // Also sign out from Google so next time they can choose an account
        if (await _googleSignIn.isSignedIn()) _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw const AuthException('Failed to sign out.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (_) {
      throw AuthException.unknown;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' => AuthException.userNotFound,
      'wrong-password' => AuthException.invalidCredentials,
      'invalid-credential' => AuthException.invalidCredentials,
      'email-already-in-use' => AuthException.emailAlreadyInUse,
      'weak-password' => AuthException.weakPassword,
      'operation-not-allowed' => AuthException.operationNotAllowed,
      'invalid-email' => const AuthException('The email address is invalid.'),
      _ => AuthException(e.message ?? 'Authentication failed.'),
    };
  }
}
