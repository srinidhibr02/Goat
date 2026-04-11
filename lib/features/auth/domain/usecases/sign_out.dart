import 'package:goat/core/utils/result.dart';

import '../repositories/auth_repository.dart';

class SignOut {
  final AuthRepository _repo;
  const SignOut(this._repo);

  Future<Result<Unit>> call() => _repo.signOut();
}
