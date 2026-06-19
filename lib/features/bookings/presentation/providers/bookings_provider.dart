import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/booking_datasource.dart';
import '../../data/datasources/firestore_booking_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

// ── Datasource & Repository ───────────────────────────────────────────────────

final _bookingDatasourceProvider = Provider<BookingDatasource>((ref) {
  try {
    Firebase.app();
    return FirestoreBookingDatasource();
  } catch (_) {
    return _InMemoryBookingDatasource();
  }
});

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepositoryImpl(ref.watch(_bookingDatasourceProvider)),
);

// ── State Notifier ────────────────────────────────────────────────────────────

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>(
  (ref) => BookingsNotifier(ref),
);

class BookingsNotifier extends StateNotifier<List<Booking>> {
  final Ref _ref;
  StreamSubscription<List<Booking>>? _sub;

  BookingsNotifier(this._ref) : super([]) {
    _ref.listen(authStateProvider, (_, next) {
      final uid = next.valueOrNull?.uid;
      _sub?.cancel();
      if (uid == null) {
        state = [];
        return;
      }
      _sub = _ref
          .read(bookingRepositoryProvider)
          .watchBookings(uid)
          .listen((bookings) => state = bookings);
    }, fireImmediately: true);
  }

  void createBooking({
    required String templeId,
    required String templeName,
    required String templeImageUrl,
    required DateTime date,
    required TimeSlot timeSlot,
  }) {
    final uid = _ref.read(authStateProvider).valueOrNull?.uid;
    final repo = _ref.read(bookingRepositoryProvider);
    final id = uid != null
        ? repo.generateId(uid)
        : 'booking-${DateTime.now().microsecondsSinceEpoch}';

    final booking = Booking(
      id: id,
      templeId: templeId,
      templeName: templeName,
      templeImageUrl: templeImageUrl,
      date: date,
      timeSlot: timeSlot,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
    );

    // Optimistic local update
    state = [booking, ...state];

    if (uid != null) repo.createBooking(uid, booking);
  }

  void cancelBooking(String bookingId) {
    state = [
      for (final b in state)
        if (b.id == bookingId) b.copyWith(status: BookingStatus.cancelled) else b,
    ];
    final uid = _ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      _ref.read(bookingRepositoryProvider).cancelBooking(uid, bookingId);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

// ── Derived providers ─────────────────────────────────────────────────────────

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

// ── In-Memory fallback (no Firebase) ─────────────────────────────────────────

class _InMemoryBookingDatasource implements BookingDatasource {
  final _controller =
      StreamController<List<Booking>>.broadcast();
  final List<Booking> _store = [];

  @override
  Stream<List<Booking>> watchBookings(String uid) => _controller.stream;

  @override
  Future<void> createBooking(String uid, Booking booking) async {
    _store.insert(0, booking);
    _controller.add(List.from(_store));
  }

  @override
  Future<void> cancelBooking(String uid, String bookingId) async {
    final idx = _store.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _store[idx] = _store[idx].copyWith(status: BookingStatus.cancelled);
      _controller.add(List.from(_store));
    }
  }

  @override
  String generateId(String uid) =>
      'booking-${DateTime.now().microsecondsSinceEpoch}';
}
