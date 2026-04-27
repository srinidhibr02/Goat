import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/firestore_paths.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/booking.dart';

// ── Bookings State ───────────────────────────────────────────────────────────

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (ref) => BookingsNotifier(ref),
);

class BookingsNotifier extends StateNotifier<List<Booking>> {
  final Ref _ref;
  StreamSubscription? _sub;
  String? _uid;
  bool _isFirebaseConfigured = false;

  BookingsNotifier(this._ref) : super([]) {
    try {
      Firebase.app();
      _isFirebaseConfigured = true;
    } catch (_) {}

    _ref.listen(authStateProvider, (prev, next) {
      final user = next.valueOrNull;
      if (user?.uid != _uid) {
        _uid = user?.uid;
        _initFirestoreSync();
      }
    });
  }

  void _initFirestoreSync() {
    _sub?.cancel();
    _sub = null;

    if (_uid == null) {
      state = [];
      return;
    }

    if (!_isFirebaseConfigured) return;

    final query = FirebaseFirestore.instance
        .collection(FirestorePaths.userBookings(_uid!))
        .orderBy('createdAt', descending: true);

    _sub = query.snapshots().listen((snapshot) {
      state = snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList();
    });
  }

  void createBooking({
    required String templeId,
    required String templeName,
    required String templeImageUrl,
    required DateTime date,
    required TimeSlot timeSlot,
  }) {
    final bookingId = _isFirebaseConfigured
        ? FirebaseFirestore.instance.collection(FirestorePaths.userBookings(_uid ?? '0')).doc().id
        : 'booking-${DateTime.now().microsecondsSinceEpoch}';

    final booking = Booking(
      id: bookingId,
      templeId: templeId,
      templeName: templeName,
      templeImageUrl: templeImageUrl,
      date: date,
      timeSlot: timeSlot,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
    );

    // Update locally instantly for optimistic UI
    state = [booking, ...state];

    // Sync to Firestore
    if (_isFirebaseConfigured && _uid != null) {
      FirebaseFirestore.instance
          .collection(FirestorePaths.userBookings(_uid!))
          .doc(booking.id)
          .set(booking.toJson());
    }
  }

  void cancelBooking(String bookingId) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(status: BookingStatus.cancelled)
        else
          b,
    ];

    if (_isFirebaseConfigured && _uid != null) {
      FirebaseFirestore.instance
          .collection(FirestorePaths.userBookings(_uid!))
          .doc(bookingId)
          .update({'status': BookingStatus.cancelled.name});
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
