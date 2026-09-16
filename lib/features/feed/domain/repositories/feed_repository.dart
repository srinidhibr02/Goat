import '../entities/feed_post.dart';

/// Abstract contract for the feed data layer.
abstract interface class FeedRepository {
  Future<List<FeedPost>> getPosts({int limit = 30});
  Future<List<FeedPost>> getPostsForTemple(String templeId, {int limit = 20});
  Future<FeedPost> toggleLike(String postId, String uid);
  Future<FeedComment> addComment({
    required String postId,
    required String uid,
    required String displayName,
    String? photoUrl,
    required String text,
  });
  Future<List<FeedComment>> getComments(String postId, {int limit = 50});
}
