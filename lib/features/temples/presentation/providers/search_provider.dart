import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat/core/utils/result.dart';

import '../../domain/entities/temple.dart';
import 'temples_providers.dart';

// ── Search Query ─────────────────────────────────────────────────────────────

/// The current search query entered by the user.
final searchQueryProvider = StateProvider<String>((_) => '');

// ── Filtered Temples ─────────────────────────────────────────────────────────

/// Temples filtered by both the selected category AND the search query.
///
/// Matches case-insensitively against temple name, city, and state.
/// Returns the full list when the query is empty.
final filteredTemplesProvider = FutureProvider<List<Temple>>((ref) async {
  final repo = ref.watch(templeRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  final result = await repo.getTemples(category: category);
  final temples = switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw Exception(failure.message),
  };

  if (query.isEmpty) return temples;

  return temples.where((t) {
    return t.name.toLowerCase().contains(query) ||
        t.city.toLowerCase().contains(query) ||
        t.state.toLowerCase().contains(query);
  }).toList();
});
