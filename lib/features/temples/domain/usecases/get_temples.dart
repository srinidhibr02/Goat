import 'package:goat/core/utils/result.dart';

import '../entities/temple.dart';
import '../entities/temple_category.dart';
import '../repositories/temple_repository.dart';

class GetTemples {
  final TempleRepository _repo;
  const GetTemples(this._repo);

  Future<Result<List<Temple>>> call({TempleCategory? category}) =>
      _repo.getTemples(category: category);
}
