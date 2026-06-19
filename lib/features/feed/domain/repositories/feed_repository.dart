import '../entities/feed_post.dart';

/// Abstract contract for the feed data layer.
abstract interface class FeedRepository {
  /// Returns a list of posts, newest first.
  ///
  /// [limit] caps the number of results (default 30).
  Future<List<FeedPost>> getPosts({int limit = 30});

  /// Returns only posts for a specific temple.
  Future<List<FeedPost>> getPostsForTemple(String templeId, {int limit = 20});
}
