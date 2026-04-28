import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat/core/utils/result.dart';

import 'package:firebase_core/firebase_core.dart';

import '../../data/datasources/firestore_temple_datasource.dart';
import '../../data/datasources/temples_datasource.dart';
import '../../data/datasources/temples_local_datasource.dart';
import '../../data/repositories/temple_repository_impl.dart';
import '../../domain/entities/temple.dart';
import '../../domain/entities/temple_category.dart';
import '../../domain/repositories/temple_repository.dart';

// ── Datasource ───────────────────────────────────────────────────────────────

final templeDatasourceProvider = Provider<TemplesDatasource>((ref) {
  try {
    Firebase.app();
    return FirestoreTempleDatasource();
  } catch (_) {
    return TemplesLocalDatasource();
  }
});

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

// ── Single Temple ────────────────────────────────────────────────────────────

/// Fetches a specific temple by ID (used for deep linking).
final templeByIdProvider = FutureProvider.family<Temple, String>((ref, id) async {
  final repo = ref.watch(templeRepositoryProvider);
  final result = await repo.getTempleById(id);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw Exception(failure.message),
  };
});
