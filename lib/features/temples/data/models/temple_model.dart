import '../../domain/entities/temple.dart';
import '../../domain/entities/temple_category.dart';

/// Data model extending [Temple] with JSON serialisation.
class TempleModel extends Temple {
  const TempleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.latitude,
    required super.longitude,
    required super.city,
    required super.state,
    required super.category,
    required super.rating,
    required super.reviewCount,
    required super.isVerified,
  });

  factory TempleModel.fromJson(Map<String, dynamic> json) => TempleModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        imageUrl: json['imageUrl'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        city: json['city'] as String,
        state: json['state'] as String,
        category: TempleCategory.fromString(json['category'] as String),
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['reviewCount'] as int,
        isVerified: json['isVerified'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'state': state,
        'category': category.name,
        'rating': rating,
        'reviewCount': reviewCount,
        'isVerified': isVerified,
      };
}
