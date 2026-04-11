import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat/core/utils/result.dart';

import '../../data/datasources/temples_local_datasource.dart';
import '../../data/repositories/temple_repository_impl.dart';
import '../../domain/entities/temple.dart';
import '../../domain/entities/temple_category.dart';
import '../../domain/repositories/temple_repository.dart';

// ── Datasource ───────────────────────────────────────────────────────────────

final templeDatasourceProvider = Provider<TemplesLocalDatasource>(
  (_) => TemplesLocalDatasource(),
);

// ── Repository ───────────────────────────────────────────────────────────────

final templeRepositoryProvider = Provider<TempleRepository>(
  (ref) => TempleRepositoryImpl(ref.watch(templeDatasourceProvider)) as TempleRepository,
);

// ── Category Filter ──────────────────────────────────────────────────────────

/// The currently selected category in the home screen filter.
final selectedCategoryProvider =
    StateProvider<TempleCategory>((_) => TempleCategory.all);

// ── Temple List ──────────────────────────────────────────────────────────────

/// Async list of temples filtered by [selectedCategoryProvider].
///
/// Automatically re-fetches when the selected category changes.
final templesProvider = FutureProvider<List<Temple>>((ref) async {
  final repo = ref.watch(templeRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final result = await repo.getTemples(category: category);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw Exception(failure.message),
  };
});
