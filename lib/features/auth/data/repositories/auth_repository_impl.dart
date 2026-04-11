import 'package:goat/core/errors/exceptions.dart';
import 'package:goat/core/errors/failures.dart';
import 'package:goat/core/utils/result.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Concrete implementation of [AuthRepository].
///
/// Catches [AuthException]s from the datasource and converts them to
/// domain [AuthFailure]s.  All other exceptions fall back to [AuthFailure.unknown].
class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  Stream<AppUser?> get authStateChanges => _datasource.authStateChanges;

  @override
  Future<Result<AppUser>> signInWithEmail(
      String email, String password) async {
    try {
      final user = await _datasource.signInWithEmail(email, password);
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(message: e.message));
    } catch (_) {
      return Err(AuthFailure.unknown);
    }
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    try {
      final user = await _datasource.signInWithGoogle();
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(message: e.message));
    } catch (_) {
      return Err(AuthFailure.unknown);
    }
  }

  @override
  Future<Result<AppUser>> createUserWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final user =
          await _datasource.createUserWithEmail(email, password, displayName);
      return Ok(user);
    } on AuthException catch (e) {
      return Err(AuthFailure(message: e.message));
    } catch (_) {
      return Err(AuthFailure.unknown);
    }
  }

  @override
  Future<Result<Unit>> signOut() async {
    try {
      await _datasource.signOut();
      return Ok(Unit.instance);
    } catch (_) {
      return Err(AuthFailure.unknown);
    }
  }

  @override
  Future<Result<Unit>> sendPasswordResetEmail(String email) async {
    try {
      await _datasource.sendPasswordResetEmail(email);
      return Ok(Unit.instance);
    } on AuthException catch (e) {
      return Err(AuthFailure(message: e.message));
    } catch (_) {
      return Err(AuthFailure.unknown);
    }
  }
}
