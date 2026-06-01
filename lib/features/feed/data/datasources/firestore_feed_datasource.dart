import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/feed_post.dart';
import '../models/feed_post_model.dart';
import 'feed_datasource.dart';

/// Real Firestore implementation of [FeedDatasource].
class FirestoreFeedDatasource implements FeedDatasource {
  final FirebaseFirestore _firestore;

  FirestoreFeedDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<FeedPost>> getPosts({int limit = 30}) async {
    final snapshot = await _firestore
        .collection('feed')
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return FeedPostModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<FeedPost>> getPostsForTemple(String templeId,
      {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('feed')
        .where('templeId', isEqualTo: templeId)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return FeedPostModel.fromJson(data);
    }).toList();
  }
}
