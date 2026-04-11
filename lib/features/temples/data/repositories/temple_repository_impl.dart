import 'package:goat/core/errors/failures.dart';
import 'package:goat/core/utils/result.dart';

import '../../domain/entities/temple.dart';
import '../../domain/entities/temple_category.dart';
import '../../domain/repositories/temple_repository.dart';
import '../datasources/temples_local_datasource.dart';

class TempleRepositoryImpl implements TempleRepository {
  final TemplesLocalDatasource _datasource;

  const TempleRepositoryImpl(this._datasource);

  @override
  Future<Result<List<Temple>>> getTemples({TempleCategory? category}) async {
    try {
      final temples = await _datasource.getTemples();
      if (category == null || category == TempleCategory.all) {
        return Ok(temples);
      }
      return Ok(temples.where((t) => t.category == category).toList());
    } catch (e) {
      return Err(CacheFailure(message: 'Failed to load temples: $e'));
    }
  }

  @override
  Future<Result<Temple>> getTempleById(String id) async {
    try {
      final temple = await _datasource.getTempleById(id);
      return Ok(temple);
    } catch (e) {
      return Err(CacheFailure(message: 'Temple not found: $id'));
    }
  }
}
