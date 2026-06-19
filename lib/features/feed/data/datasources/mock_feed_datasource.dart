import '../../domain/entities/feed_post.dart';
import 'feed_datasource.dart';

/// In-memory mock feed for use when Firebase is not configured.
class MockFeedDatasource implements FeedDatasource {
  static final List<FeedPost> _posts = [
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
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      eventDate: DateTime(2025, 9, 28),
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Tirumala_temple_view.jpg/640px-Tirumala_temple_view.jpg',
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
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      eventDate: DateTime.now().add(const Duration(days: 7)),
    ),
    FeedPost(
      id: 'f3',
      templeId: 't3',
      templeName: 'Siddhivinayak Temple',
      templeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Siddhivinayak_Temple%2C_Mumbai.jpg/640px-Siddhivinayak_Temple%2C_Mumbai.jpg',
      title: 'Online Darshan Booking Now Available',
      body:
          'Siddhivinayak Temple Trust is pleased to announce that devotees can now book '
          'darshan slots online. Walk-in queues will continue to be available on Tuesdays.',
      type: FeedPostType.announcement,
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FeedPost(
      id: 'f4',
      templeId: 't4',
      templeName: 'Somnath Temple',
      templeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Somnath_temple_1869.jpg/640px-Somnath_temple_1869.jpg',
      title: 'Restoration of the Western Gopuram Complete',
      body:
          'After two years of careful restoration work, the western Gopuram of the temple '
          'has been fully renovated. The temple management thanks all devotees for their generous donations.',
      type: FeedPostType.news,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
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
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FeedPost(
      id: 'f6',
      templeId: 't5',
      templeName: 'Golden Temple',
      templeImageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Golden_Temple%2C_Amritsar.jpg/640px-Golden_Temple%2C_Amritsar.jpg',
      title: 'Guru Nanak Jayanti — Community Langar',
      body:
          'A grand community Langar will be organised on Guru Nanak Jayanti. '
          'Over 1 lakh devotees are expected to participate. Volunteers are welcome to join the seva.',
      type: FeedPostType.festival,
      publishedAt: DateTime.now().subtract(const Duration(days: 4)),
      eventDate: DateTime.now().add(const Duration(days: 21)),
    ),
    FeedPost(
      id: 'f7',
      templeId: 't6',
      templeName: 'Kashi Vishwanath Temple',
      title: 'New Corridor Expansion Opens to Devotees',
      body:
          'The newly built Kashi Vishwanath Corridor has been opened to the public, '
          'offering a seamless pathway from the ghats to the sanctum. Capacity has tripled.',
      type: FeedPostType.news,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<FeedPost>> getPosts({int limit = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _posts.take(limit).toList();
  }

  @override
  Future<List<FeedPost>> getPostsForTemple(String templeId,
      {int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _posts.where((p) => p.templeId == templeId).take(limit).toList();
  }
}
