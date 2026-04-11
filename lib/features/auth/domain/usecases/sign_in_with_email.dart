import 'package:goat/core/utils/result.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail {
  final AuthRepository _repo;
  const SignInWithEmail(this._repo);

  Future<Result<AppUser>> call(String email, String password) =>
      _repo.signInWithEmail(email, password);
}
