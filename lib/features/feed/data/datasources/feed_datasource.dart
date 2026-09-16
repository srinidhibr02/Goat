import '../../domain/entities/feed_post.dart';

/// Abstract datasource contract for feed posts.
abstract interface class FeedDatasource {
  Future<List<FeedPost>> getPosts({int limit = 30});
  Future<List<FeedPost>> getPostsForTemple(String templeId, {int limit = 20});

  /// Toggles like for [uid] on [postId].
  /// Returns the new [FeedPost] with updated likeCount / likedBy.
  Future<FeedPost> toggleLike(String postId, String uid);

  /// Adds a comment to [postId]. Returns the created [FeedComment].
  Future<FeedComment> addComment({
    required String postId,
    required String uid,
    required String displayName,
    String? photoUrl,
    required String text,
  });

  /// Returns the comments for [postId], newest first.
  Future<List<FeedComment>> getComments(String postId, {int limit = 50});
}
