import 'package:flutter/foundation.dart';

/// The type/category of a feed post.
enum FeedPostType {
  news('News', '📰'),
  event('Event', '🎉'),
  announcement('Announcement', '📢'),
  festival('Festival', '🪔');

  const FeedPostType(this.displayName, this.emoji);

  final String displayName;
  final String emoji;
}

/// A single post in the devotee feed.
@immutable
class FeedPost {
  final String id;
  final String templeId;
  final String templeName;
  final String? templeImageUrl;
  final String title;
  final String body;
  final FeedPostType type;
  final DateTime publishedAt;

  /// Only set when [type] is [FeedPostType.event] or [FeedPostType.festival].
  final DateTime? eventDate;

  /// Optional hero image for the post.
  final String? imageUrl;

  const FeedPost({
    required this.id,
    required this.templeId,
    required this.templeName,
    this.templeImageUrl,
    required this.title,
    required this.body,
    required this.type,
    required this.publishedAt,
    this.eventDate,
    this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FeedPost && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
