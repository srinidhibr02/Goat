import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/firestore_paths.dart';
import '../../domain/entities/booking.dart';
import 'booking_datasource.dart';

/// Firestore implementation of [BookingDatasource].
class FirestoreBookingDatasource implements BookingDatasource {
  final FirebaseFirestore _db;

  FirestoreBookingDatasource({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Booking>> watchBookings(String uid) {
    return _db
        .collection(FirestorePaths.userBookings(uid))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromJson(d.data())).toList());
  }

  @override
  Future<void> createBooking(String uid, Booking booking) =>
      _db
          .collection(FirestorePaths.userBookings(uid))
          .doc(booking.id)
          .set(booking.toJson());

  @override
  Future<void> cancelBooking(String uid, String bookingId) =>
      _db
          .collection(FirestorePaths.userBookings(uid))
          .doc(bookingId)
          .update({'status': BookingStatus.cancelled.name});

  @override
  String generateId(String uid) =>
      _db.collection(FirestorePaths.userBookings(uid)).doc().id;
}
