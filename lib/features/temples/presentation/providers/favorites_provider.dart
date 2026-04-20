import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Favorites State ──────────────────────────────────────────────────────────

/// Holds the set of favorited temple IDs (in-memory).
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (_) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  void toggle(String templeId) {
    if (state.contains(templeId)) {
      state = {...state}..remove(templeId);
    } else {
      state = {...state, templeId};
    }
  }

  bool isFavorite(String templeId) => state.contains(templeId);
}

// ── Derived provider ─────────────────────────────────────────────────────────

/// Returns `true` if the given temple is in the user's favorites.
final isFavoriteProvider = Provider.family<bool, String>(
  (ref, templeId) => ref.watch(favoritesProvider).contains(templeId),
);
