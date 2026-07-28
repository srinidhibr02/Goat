import '../../domain/entities/feed_post.dart';
import 'feed_datasource.dart';

/// In-memory mock feed for use when Firebase is not configured.
class MockFeedDatasource implements FeedDatasource {
  // Mutable list so toggleLike / addComment can mutate state in-place.
  late final List<FeedPost> _posts = _buildPosts();

  static List<FeedPost> _buildPosts() {
    final now = DateTime.now();
    return [
      FeedPost(
        id: 'f1',
        templeId: 't1',
        templeName: 'Tirumala Venkateswara Temple',
        templeImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Tirumala_temple_view.jpg/640px-Tirumala_temple_view.jpg',
        title: 'Brahmotsavam 2025 — Schedule Released',
        body:
            'The annual Brahmotsavam festival will be held from September 28 to October 6. '
            'Devotees are requested to book their accommodation in advance via the TTD portal.',
        type: FeedPostType.festival,
        publishedAt: now.subtract(const Duration(hours: 2)),
        eventDate: now.add(const Duration(days: 90)),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Tirumala_temple_view.jpg/640px-Tirumala_temple_view.jpg',
        likeCount: 42,
        commentCount: 7,
      ),
      FeedPost(
        id: 'f2',
        templeId: 't2',
        templeName: 'Meenakshi Amman Temple',
        templeImageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/Madurai_Meenakshi_Amman_Temple_%28edit2%29.jpg/640px-Madurai_Meenakshi_Amman_Temple_%28edit2%29.jpg',
        title: 'Special Abishekam on Aadi Pooram',
        body:
            'A grand Abishekam ceremony will be conducted for Goddess Meenakshi on Aadi Pooram. '
            'The event starts at 5:00 AM. Prasad distribution will be open to all devotees.',
        type: FeedPostType.event,
        publishedAt: now.subtract(const Duration(hours: 8)),
        eventDate: now.add(const Duration(days: 7)),
        likeCount: 19,
        commentCount: 3,
      ),
      FeedPost(
        id: 'f3',
        templeId: 't3',
        templeName: 'Siddhivinayak Temple',
        title: 'Online Darshan Booking Now Available',
        body:
            'Siddhivinayak Temple Trust is pleased to announce that devotees can now book '
            'darshan slots online. Walk-in queues will continue to be available on Tuesdays.',
        type: FeedPostType.announcement,
        publishedAt: now.subtract(const Duration(days: 1)),
        likeCount: 88,
        commentCount: 12,
      ),
      FeedPost(
        id: 'f4',
        templeId: 't4',
        templeName: 'Somnath Temple',
        title: 'Restoration of the Western Gopuram Complete',
        body:
            'After two years of careful restoration work, the western Gopuram of the temple '
            'has been fully renovated. The temple management thanks all devotees.',
        type: FeedPostType.news,
        publishedAt: now.subtract(const Duration(days: 2)),
        likeCount: 34,
        commentCount: 5,
      ),
      FeedPost(
        id: 'f5',
        templeId: 't1',
        templeName: 'Tirumala Venkateswara Temple',
        title: 'Dress Code Reminder for All Devotees',
        body:
            'The temple management reminds all devotees to adhere to the prescribed dress code. '
            'Men must wear dhoti or pyjama-kurta; women must wear saree or salwar-kameez.',
        type: FeedPostType.announcement,
        publishedAt: now.subtract(const Duration(days: 3)),
        likeCount: 55,
        commentCount: 9,
      ),
      FeedPost(
        id: 'f6',
        templeId: 't5',
        templeName: 'Golden Temple',
        title: 'Guru Nanak Jayanti — Community Langar',
        body:
            'A grand community Langar will be organised on Guru Nanak Jayanti. '
            'Over 1 lakh devotees are expected to participate. Volunteers are welcome.',
        type: FeedPostType.festival,
        publishedAt: now.subtract(const Duration(days: 4)),
        eventDate: now.add(const Duration(days: 21)),
        likeCount: 201,
        commentCount: 31,
      ),
      FeedPost(
        id: 'f7',
        templeId: 't6',
        templeName: 'Kashi Vishwanath Temple',
        title: 'New Corridor Expansion Opens to Devotees',
        body:
            'The newly built Kashi Vishwanath Corridor has been opened to the public, '
            'offering a seamless pathway from the ghats to the sanctum.',
        type: FeedPostType.news,
        publishedAt: now.subtract(const Duration(days: 5)),
        likeCount: 76,
        commentCount: 14,
      ),
    ];
  }

  // Store mock comments per post
  final Map<String, List<FeedComment>> _comments = {};

  @override
  Future<List<FeedPost>> getPosts({int limit = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _posts.take(limit).map((p) {
      // Reflect any comment additions
      final count = _comments[p.id]?.length ?? p.commentCount;
      return count == p.commentCount
          ? p
          : p.copyWith(commentCount: count);
    }).toList();
  }

  @override
  Future<List<FeedPost>> getPostsForTemple(String templeId,
      {int limit = 20}) async {
    final all = await getPosts();
    return all.where((p) => p.templeId == templeId).take(limit).toList();
  }

  @override
  Future<FeedPost> toggleLike(String postId, String uid) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) throw Exception('Post not found: $postId');

    final post = _posts[idx];
    final likedBy = List<String>.from(post.likedBy);
    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }
    final updated = post.copyWith(
      likedBy: likedBy,
      likeCount: likedBy.length,
    );
    _posts[idx] = updated;
    return updated;
  }

  @override
  Future<FeedComment> addComment({
    required String postId,
    required String uid,
    required String displayName,
    String? photoUrl,
    required String text,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final comment = FeedComment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      uid: uid,
      displayName: displayName,
      photoUrl: photoUrl,
      text: text,
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(postId, () => []).add(comment);
    return comment;
  }

  @override
  Future<List<FeedComment>> getComments(String postId,
      {int limit = 50}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return (_comments[postId] ?? []).take(limit).toList();
  }
}
