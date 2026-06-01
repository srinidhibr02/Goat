import '../../domain/entities/feed_post.dart';

/// Abstract datasource contract for feed posts.
abstract interface class FeedDatasource {
  Future<List<FeedPost>> getPosts({int limit = 30});
  Future<List<FeedPost>> getPostsForTemple(String templeId, {int limit = 20});
}
