import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/feed_post.dart';
import '../models/feed_post_model.dart';
import 'feed_datasource.dart';
import 'mock_feed_datasource.dart';

/// Real Firestore implementation of [FeedDatasource].
///
/// Falls back to [MockFeedDatasource] data when the Firestore `feed`
/// collection is empty (e.g. on first install before an admin has posted).
class FirestoreFeedDatasource implements FeedDatasource {
  final FirebaseFirestore _db;
  final MockFeedDatasource _mock;

  FirestoreFeedDatasource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance,
        _mock = MockFeedDatasource();

  // ── Helpers ──────────────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _feed => _db.collection('feed');

  FeedPost _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    data['id'] = doc.id;
    return FeedPostModel.fromJson(data);
  }

  // ── Seeder ───────────────────────────────────────────────────────────────────

  /// Seeds the Firestore `feed` collection with mock posts if empty.
  /// Safe to call on every launch — it's a no-op when data exists.
  Future<void> seedIfEmpty() async {
    final snap =
        await _feed.limit(1).get(const GetOptions(source: Source.server));
    if (snap.docs.isNotEmpty) return; // Already has data

    final mockPosts = await _mock.getPosts();
    final batch = _db.batch();
    for (final post in mockPosts) {
      final ref = _feed.doc(post.id);
      batch.set(ref, {
        'templeId': post.templeId,
        'templeName': post.templeName,
        'templeImageUrl': post.templeImageUrl,
        'title': post.title,
        'body': post.body,
        'type': post.type.name,
        'publishedAt': Timestamp.fromDate(post.publishedAt),
        'eventDate': post.eventDate != null
            ? Timestamp.fromDate(post.eventDate!)
            : null,
        'imageUrl': post.imageUrl,
        'likeCount': post.likeCount,
        'likedBy': post.likedBy,
        'commentCount': post.commentCount,
      });
    }
    await batch.commit();
  }

  // ── Read ──────────────────────────────────────────────────────────────────────

  @override
  Future<List<FeedPost>> getPosts({int limit = 30}) async {
    try {
      final snap = await _feed
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();

      // Firestore empty → seed once, then return mock data immediately
      if (snap.docs.isEmpty) {
        seedIfEmpty(); // fire-and-forget
        return _mock.getPosts(limit: limit);
      }

      return snap.docs.map(_fromDoc).toList();
    } catch (_) {
      // Any Firestore error (permissions, network, missing index)
      // → fall back to mock so the feed is never blank.
      return _mock.getPosts(limit: limit);
    }
  }

  @override
  Future<List<FeedPost>> getPostsForTemple(String templeId,
      {int limit = 20}) async {
    try {
      final snap = await _feed
          .where('templeId', isEqualTo: templeId)
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();

      if (snap.docs.isEmpty) {
        return _mock.getPostsForTemple(templeId, limit: limit);
      }

      return snap.docs.map(_fromDoc).toList();
    } catch (_) {
      return _mock.getPostsForTemple(templeId, limit: limit);
    }
  }

  // ── Likes ─────────────────────────────────────────────────────────────────────

  @override
  Future<FeedPost> toggleLike(String postId, String uid) async {
    final ref = _feed.doc(postId);

    return _db.runTransaction<FeedPost>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        // Post may only exist in mock — delegate
        return _mock.toggleLike(postId, uid);
      }

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

  // ── Comments ──────────────────────────────────────────────────────────────────

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

    batch.set(commentRef, {
      'uid': uid,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
