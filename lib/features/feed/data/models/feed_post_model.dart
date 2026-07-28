import '../../domain/entities/feed_post.dart';

/// Data model for a [FeedPost] with JSON serialization.
class FeedPostModel extends FeedPost {
  const FeedPostModel({
    required super.id,
    required super.templeId,
    required super.templeName,
    super.templeImageUrl,
    required super.title,
    required super.body,
    required super.type,
    required super.publishedAt,
    super.eventDate,
    super.imageUrl,
    super.likeCount,
    super.likedBy,
    super.commentCount,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) => FeedPostModel(
        id: json['id'] as String,
        templeId: json['templeId'] as String,
        templeName: json['templeName'] as String,
        templeImageUrl: json['templeImageUrl'] as String?,
        title: json['title'] as String,
        body: json['body'] as String,
        type: FeedPostType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => FeedPostType.news,
        ),
        publishedAt: _parseDate(json['publishedAt']),
        eventDate: json['eventDate'] != null
            ? _parseDate(json['eventDate'])
            : null,
        imageUrl: json['imageUrl'] as String?,
        likeCount: (json['likeCount'] as int?) ?? 0,
        likedBy: (json['likedBy'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        commentCount: (json['commentCount'] as int?) ?? 0,
      );

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    // Firestore Timestamp
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'templeId': templeId,
        'templeName': templeName,
        'templeImageUrl': templeImageUrl,
        'title': title,
        'body': body,
        'type': type.name,
        'publishedAt': publishedAt.toIso8601String(),
        'eventDate': eventDate?.toIso8601String(),
        'imageUrl': imageUrl,
        'likeCount': likeCount,
        'likedBy': likedBy,
        'commentCount': commentCount,
      };
}

/// Data model for a [FeedComment].
class FeedCommentModel extends FeedComment {
  const FeedCommentModel({
    required super.id,
    required super.postId,
    required super.uid,
    required super.displayName,
    super.photoUrl,
    required super.text,
    required super.createdAt,
  });

  factory FeedCommentModel.fromJson(String id, String postId,
      Map<String, dynamic> json) =>
      FeedCommentModel(
        id: id,
        postId: postId,
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        photoUrl: json['photoUrl'] as String?,
        text: json['text'] as String,
        createdAt: FeedPostModel._parseDate(json['createdAt']),
      );
}
