import '../../domain/repositories/booking_repository.dart';
import '../../domain/entities/booking.dart';
import '../datasources/booking_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingDatasource _datasource;
  const BookingRepositoryImpl(this._datasource);

  @override
  Stream<List<Booking>> watchBookings(String uid) =>
      _datasource.watchBookings(uid);

  @override
  Future<void> createBooking(String uid, Booking booking) =>
      _datasource.createBooking(uid, booking);

  @override
  Future<void> cancelBooking(String uid, String bookingId) =>
      _datasource.cancelBooking(uid, bookingId);

  @override
  String generateId(String uid) => _datasource.generateId(uid);
}
