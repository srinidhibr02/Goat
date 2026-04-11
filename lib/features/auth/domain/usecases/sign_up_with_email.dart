import 'package:goat/core/utils/result.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository _repo;
  const SignUpWithEmail(this._repo);

  Future<Result<AppUser>> call(
    String email,
    String password,
    String displayName,
  ) =>
      _repo.createUserWithEmail(email, password, displayName);
}
