import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/feed_post.dart';
import '../models/feed_post_model.dart';
import 'feed_datasource.dart';

/// Real Firestore implementation of [FeedDatasource].
class FirestoreFeedDatasource implements FeedDatasource {
  final FirebaseFirestore _db;

  FirestoreFeedDatasource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _feed => _db.collection('feed');

  FeedPost _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id;
    return FeedPostModel.fromJson(data);
  }

  // ── Read ─────────────────────────────────────────────────────────────────────

  @override
  Future<List<FeedPost>> getPosts({int limit = 30}) async {
    final snap = await _feed
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<List<FeedPost>> getPostsForTemple(String templeId,
      {int limit = 20}) async {
    final snap = await _feed
        .where('templeId', isEqualTo: templeId)
        .orderBy('publishedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  // ── Likes ────────────────────────────────────────────────────────────────────

  @override
  Future<FeedPost> toggleLike(String postId, String uid) async {
    final ref = _feed.doc(postId);

    return _db.runTransaction<FeedPost>((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final alreadyLiked = likedBy.contains(uid);

      if (alreadyLiked) {
        likedBy.remove(uid);
      } else {
        likedBy.add(uid);
      }

      tx.update(ref, {
        'likedBy': likedBy,
        'likeCount': likedBy.length,
      });

      data['id'] = postId;
      data['likedBy'] = likedBy;
      data['likeCount'] = likedBy.length;
      return FeedPostModel.fromJson(data);
    });
  }

  // ── Comments ─────────────────────────────────────────────────────────────────

  @override
  Future<FeedComment> addComment({
    required String postId,
    required String uid,
    required String displayName,
    String? photoUrl,
    required String text,
  }) async {
    final batch = _db.batch();
    final commentRef = _feed.doc(postId).collection('comments').doc();

    final commentData = {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };

    batch.set(commentRef, commentData);
    batch.update(_feed.doc(postId), {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();

    return FeedCommentModel(
      id: commentRef.id,
      postId: postId,
      uid: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      text: text,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<FeedComment>> getComments(String postId,
      {int limit = 50}) async {
    final snap = await _feed
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .get();

    return snap.docs
        .map((doc) => FeedCommentModel.fromJson(doc.id, postId, doc.data()))
        .toList();
  }
}
