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
        publishedAt: DateTime.parse(json['publishedAt'] as String),
        eventDate: json['eventDate'] != null
            ? DateTime.parse(json['eventDate'] as String)
            : null,
        imageUrl: json['imageUrl'] as String?,
      );

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
      };
}
