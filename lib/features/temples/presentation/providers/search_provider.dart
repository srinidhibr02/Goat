import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat/core/utils/result.dart';

import '../../domain/entities/temple.dart';
import 'temples_providers.dart';

// ── Search Query ─────────────────────────────────────────────────────────────

/// Holds the raw (instant) search query — updated on every keystroke for
/// responsive UI (clear button, hint text, etc.).
final searchQueryProvider = StateProvider<String>((_) => '');

/// Debounced search query notifier — emits a new value 300 ms after the user
/// stops typing so [filteredTemplesProvider] doesn't hit Firestore / local JSON
/// on every single character.
class _SearchDebounceNotifier extends StateNotifier<String> {
  Timer? _timer;

  _SearchDebounceNotifier() : super('');

  void update(String value) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) state = value;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final searchDebounceProvider =
    StateNotifierProvider<_SearchDebounceNotifier, String>(
  (_) => _SearchDebounceNotifier(),
);

/// Call this whenever the search text field changes.
/// Updates [searchQueryProvider] immediately (for UI) and schedules a
/// debounced update to [searchDebounceProvider] (for data fetching).
void updateSearchQuery(WidgetRef ref, String value) {
  ref.read(searchQueryProvider.notifier).state = value;
  ref.read(searchDebounceProvider.notifier).update(value);
}

// ── Filtered Temples ─────────────────────────────────────────────────────────

/// Temples filtered by both the selected category AND the debounced search query.
///
/// Category changes re-fetch immediately; search only re-fetches after the user
/// pauses typing for 300 ms.
final filteredTemplesProvider = FutureProvider<List<Temple>>((ref) async {
  final repo = ref.watch(templeRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchDebounceProvider).trim().toLowerCase();

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

