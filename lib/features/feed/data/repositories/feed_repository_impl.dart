import '../../domain/entities/feed_post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedDatasource _datasource;
  const FeedRepositoryImpl(this._datasource);

  @override
  Future<List<FeedPost>> getPosts({int limit = 30}) =>
      _datasource.getPosts(limit: limit);

  @override
  Future<List<FeedPost>> getPostsForTemple(String templeId, {int limit = 20}) =>
      _datasource.getPostsForTemple(templeId, limit: limit);
}
