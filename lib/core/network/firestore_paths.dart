/// Centralized Firestore collection and document paths.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String temples = 'temples';

  static String userFavorites(String uid) => '$users/$uid/favorites';
  static String userBookings(String uid) => '$users/$uid/bookings';
}
