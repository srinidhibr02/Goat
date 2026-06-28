import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../temples/presentation/providers/favorites_provider.dart';
import '../../data/datasources/feed_datasource.dart';
import '../../data/datasources/firestore_feed_datasource.dart';
import '../../data/datasources/mock_feed_datasource.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/feed_post.dart';
import '../../domain/repositories/feed_repository.dart';

// ── Datasource ────────────────────────────────────────────────────────────────

final feedDatasourceProvider = Provider<FeedDatasource>((ref) {
  try {
    Firebase.app();
    return FirestoreFeedDatasource();
  } catch (_) {
    return MockFeedDatasource();
  }
});

// ── Repository ────────────────────────────────────────────────────────────────

final feedRepositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepositoryImpl(ref.watch(feedDatasourceProvider)),
);

// ── Feed posts ────────────────────────────────────────────────────────────────

/// All posts from ALL temples, newest first (used internally).
final feedPostsProvider = FutureProvider<List<FeedPost>>((ref) {
  return ref.watch(feedRepositoryProvider).getPosts();
});

/// Currently selected filter chip type (null = All).
final selectedFeedTypeProvider = StateProvider<FeedPostType?>((ref) => null);

/// `true` when the user has at least one favourited temple.
final hasFavouritesProvider = Provider<bool>(
  (ref) => ref.watch(favoritesProvider).isNotEmpty,
);

/// Posts from the user's **favourited temples only**, filtered by
/// [selectedFeedTypeProvider].
///
/// Falls back to showing all posts when the user has no favourites yet
/// (so new users don't see a blank feed on first launch).
final filteredFeedProvider = FutureProvider<List<FeedPost>>((ref) async {
  final all = await ref.watch(feedPostsProvider.future);
  final favIds = ref.watch(favoritesProvider);
  final selected = ref.watch(selectedFeedTypeProvider);

  // Filter to favourite temples (fallback to all if no favourites yet)
  final byFav = favIds.isEmpty
      ? all
      : all.where((p) => favIds.contains(p.templeId)).toList();

  // Apply post-type filter chip
  final filtered =
      selected == null ? byFav : byFav.where((p) => p.type == selected).toList();

  return filtered;
});

