import '../../domain/entities/booking.dart';

/// Abstract datasource contract for booking CRUD.
abstract interface class BookingDatasource {
  /// Returns a stream of all bookings for [uid].
  Stream<List<Booking>> watchBookings(String uid);

  /// Persists a new booking.
  Future<void> createBooking(String uid, Booking booking);

  /// Marks a booking as cancelled.
  Future<void> cancelBooking(String uid, String bookingId);

  /// Generates a new unique booking ID.
  String generateId(String uid);
}
