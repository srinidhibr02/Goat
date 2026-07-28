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

  /// Number of likes on this post.
  final int likeCount;

  /// UIDs of users who liked this post (used to check if current user liked).
  final List<String> likedBy;

  /// Number of comments on this post.
  final int commentCount;

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
    this.likeCount = 0,
    this.likedBy = const [],
    this.commentCount = 0,
  });

  bool isLikedBy(String uid) => likedBy.contains(uid);

  FeedPost copyWith({
    int? likeCount,
    List<String>? likedBy,
    int? commentCount,
  }) {
    return FeedPost(
      id: id,
      templeId: templeId,
      templeName: templeName,
      templeImageUrl: templeImageUrl,
      title: title,
      body: body,
      type: type,
      publishedAt: publishedAt,
      eventDate: eventDate,
      imageUrl: imageUrl,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FeedPost && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A single comment on a feed post.
@immutable
class FeedComment {
  final String id;
  final String postId;
  final String uid;
  final String displayName;
  final String? photoUrl;
  final String text;
  final DateTime createdAt;

  const FeedComment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.displayName,
    this.photoUrl,
    required this.text,
    required this.createdAt,
  });
}
