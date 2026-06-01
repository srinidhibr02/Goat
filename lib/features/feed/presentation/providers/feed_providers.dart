import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// All posts, newest first.
final feedPostsProvider = FutureProvider<List<FeedPost>>((ref) {
  return ref.watch(feedRepositoryProvider).getPosts();
});

/// Posts filtered by [selectedFeedTypeProvider].
final filteredFeedProvider = FutureProvider<List<FeedPost>>((ref) async {
  final all = await ref.watch(feedPostsProvider.future);
  final selected = ref.watch(selectedFeedTypeProvider);
  if (selected == null) return all;
  return all.where((p) => p.type == selected).toList();
});

/// Currently selected filter chip type (null = All).
final selectedFeedTypeProvider = StateProvider<FeedPostType?>((ref) => null);
