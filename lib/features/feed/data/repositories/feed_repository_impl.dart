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
  Future<List<FeedPost>> getPostsForTemple(String templeId,
          {int limit = 20}) =>
      _datasource.getPostsForTemple(templeId, limit: limit);

  @override
  Future<FeedPost> toggleLike(String postId, String uid) =>
      _datasource.toggleLike(postId, uid);

  @override
  Future<FeedComment> addComment({
    required String postId,
    required String uid,
    required String displayName,
    String? photoUrl,
    required String text,
  }) =>
      _datasource.addComment(
        postId: postId,
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
        text: text,
      );

  @override
  Future<List<FeedComment>> getComments(String postId, {int limit = 50}) =>
      _datasource.getComments(postId, limit: limit);
}
