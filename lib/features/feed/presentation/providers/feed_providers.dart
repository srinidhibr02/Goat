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

/// All posts from ALL temples, newest first.
/// Kept as a [StateNotifierProvider] so toggling likes updates in-place.
final feedPostsProvider =
    StateNotifierProvider<FeedPostsNotifier, AsyncValue<List<FeedPost>>>(
  (ref) => FeedPostsNotifier(ref.watch(feedRepositoryProvider)),
);

class FeedPostsNotifier
    extends StateNotifier<AsyncValue<List<FeedPost>>> {
  final FeedRepository _repo;
  FeedPostsNotifier(this._repo) : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final posts = await _repo.getPosts();
      if (mounted) state = AsyncData(posts);
    } catch (e, st) {
      if (mounted) state = AsyncError(e, st);
    }
  }

  Future<void> refresh() => _load();

  /// Toggles like for [uid] on [postId] and patches the list in-place.
  Future<void> toggleLike(String postId, String uid) async {
    final current = state.valueOrNull;
    if (current == null) return;

    // Optimistic update
    final optimistic = current.map((p) {
      if (p.id != postId) return p;
      final alreadyLiked = p.isLikedBy(uid);
      final newLikedBy = List<String>.from(p.likedBy);
      if (alreadyLiked) {
        newLikedBy.remove(uid);
      } else {
        newLikedBy.add(uid);
      }
      return p.copyWith(likedBy: newLikedBy, likeCount: newLikedBy.length);
    }).toList();
    state = AsyncData(optimistic);

    // Persist to backend
    try {
      final updated = await _repo.toggleLike(postId, uid);
      final confirmed = (state.valueOrNull ?? []).map((p) {
        return p.id == postId ? updated : p;
      }).toList();
      if (mounted) state = AsyncData(confirmed);
    } catch (_) {
      // Roll back on error
      if (mounted) state = AsyncData(current);
    }
  }

  /// Increments commentCount locally after a comment is added.
  void onCommentAdded(String postId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(commentCount: p.commentCount + 1);
    }).toList());
  }
}

// ── Post-type filter chip ─────────────────────────────────────────────────────

/// Currently selected filter chip type (null = All).
final selectedFeedTypeProvider = StateProvider<FeedPostType?>((ref) => null);

// ── Derived: favourites-filtered feed ────────────────────────────────────────

/// `true` when the user has at least one favourited temple.
final hasFavouritesProvider = Provider<bool>(
  (ref) => ref.watch(favoritesProvider).isNotEmpty,
);

/// Posts from the user's **favourited temples only**, filtered by
/// [selectedFeedTypeProvider].
/// Falls back to all posts when the user has no favourites yet.
final filteredFeedProvider = Provider<AsyncValue<List<FeedPost>>>((ref) {
  final allAsync = ref.watch(feedPostsProvider);
  final favIds = ref.watch(favoritesProvider);
  final selected = ref.watch(selectedFeedTypeProvider);

  return allAsync.whenData((all) {
    final byFav = favIds.isEmpty
        ? all
        : all.where((p) => favIds.contains(p.templeId)).toList();
    return selected == null
        ? byFav
        : byFav.where((p) => p.type == selected).toList();
  });
});

// ── Comments ─────────────────────────────────────────────────────────────────

final commentsProvider = FutureProvider.family<List<FeedComment>, String>(
  (ref, postId) => ref.watch(feedRepositoryProvider).getComments(postId),
);
