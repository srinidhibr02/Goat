import '../../domain/entities/booking.dart';

/// Abstract domain contract for booking operations.
abstract interface class BookingRepository {
  Stream<List<Booking>> watchBookings(String uid);
  Future<void> createBooking(String uid, Booking booking);
  Future<void> cancelBooking(String uid, String bookingId);
  String generateId(String uid);
}
