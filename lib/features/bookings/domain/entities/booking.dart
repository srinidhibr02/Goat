import 'package:flutter/foundation.dart';

/// Pre-defined darshan time slots.
enum TimeSlot {
  earlyMorning('Early Morning', '6:00 AM'),
  morning('Morning', '9:00 AM'),
  afternoon('Afternoon', '12:00 PM'),
  evening('Evening', '3:00 PM'),
  night('Night', '6:00 PM');

  const TimeSlot(this.displayName, this.timeLabel);

  final String displayName;
  final String timeLabel;
}

/// Represents the status of a booking.
enum BookingStatus {
  confirmed('Confirmed'),
  cancelled('Cancelled');

  const BookingStatus(this.displayName);
  final String displayName;
}

/// A darshan booking for a temple.
@immutable
class Booking {
  final String id;
  final String templeId;
  final String templeName;
  final String templeImageUrl;
  final DateTime date;
  final TimeSlot timeSlot;
  final BookingStatus status;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.templeId,
    required this.templeName,
    required this.templeImageUrl,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
  });

  Booking copyWith({BookingStatus? status}) => Booking(
        id: id,
        templeId: templeId,
        templeName: templeName,
        templeImageUrl: templeImageUrl,
        date: date,
        timeSlot: timeSlot,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Booking && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'templeId': templeId,
        'templeName': templeName,
        'templeImageUrl': templeImageUrl,
        'date': date.toIso8601String(),
        'timeSlot': timeSlot.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        templeId: json['templeId'] as String,
        templeName: json['templeName'] as String,
        templeImageUrl: json['templeImageUrl'] as String,
        date: DateTime.parse(json['date'] as String),
        timeSlot: TimeSlot.values.firstWhere((e) => e.name == json['timeSlot']),
        status: BookingStatus.values.firstWhere((e) => e.name == json['status']),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
