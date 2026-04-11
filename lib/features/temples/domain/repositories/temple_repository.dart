import 'package:goat/core/utils/result.dart';

import '../entities/temple.dart';
import '../entities/temple_category.dart';

abstract interface class TempleRepository {
  /// Returns all temples, optionally filtered by [category].
  Future<Result<List<Temple>>> getTemples({TempleCategory? category});

  /// Returns a single temple by [id].
  Future<Result<Temple>> getTempleById(String id);
}
