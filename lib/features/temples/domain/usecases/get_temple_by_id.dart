import 'package:goat/core/utils/result.dart';

import '../entities/temple.dart';
import '../repositories/temple_repository.dart';

class GetTempleById {
  final TempleRepository _repo;
  const GetTempleById(this._repo);

  Future<Result<Temple>> call(String id) => _repo.getTempleById(id);
}
