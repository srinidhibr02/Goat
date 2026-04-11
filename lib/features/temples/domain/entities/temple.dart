import 'package:flutter/foundation.dart';

import 'temple_category.dart';

/// Represents a temple in the domain layer.
@immutable
class Temple {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final TempleCategory category;
  final double rating;
  final int reviewCount;
  final bool isVerified;

  const Temple({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Temple && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
