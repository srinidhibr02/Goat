import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/booking.dart';

// ── Bookings State ───────────────────────────────────────────────────────────

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (_) => BookingsNotifier(),
);

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]);

  int _nextId = 1;

  /// Creates a new confirmed booking and adds it to the list.
  void createBooking({
    required String templeId,
    required String templeName,
    required String templeImageUrl,
    required DateTime date,
    required TimeSlot timeSlot,
  }) {
    final booking = Booking(
      id: 'booking-${_nextId++}',
      templeId: templeId,
      templeName: templeName,
      templeImageUrl: templeImageUrl,
      date: date,
      timeSlot: timeSlot,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
    );
    state = [booking, ...state];
  }

  /// Cancels a booking by ID (keeps it in list with cancelled status).
  void cancelBooking(String bookingId) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(status: BookingStatus.cancelled)
        else
          b,
    ];
  }
}

// ── Derived providers ────────────────────────────────────────────────────────

/// Upcoming confirmed bookings sorted by date.
final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final all = ref.watch(bookingsProvider);
  final now = DateTime.now();
  return all
      .where((b) =>
          b.status == BookingStatus.confirmed &&
          b.date.isAfter(now.subtract(const Duration(days: 1))))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
});

/// Past or cancelled bookings.
final pastBookingsProvider = Provider<List<Booking>>((ref) {
  final all = ref.watch(bookingsProvider);
  final now = DateTime.now();
  return all
      .where((b) =>
          b.status == BookingStatus.cancelled ||
          b.date.isBefore(now.subtract(const Duration(days: 1))))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});
