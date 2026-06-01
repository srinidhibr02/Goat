/// Centralized Firestore collection and document paths.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String temples = 'temples';
  static const String feed = 'feed';

  static String userFavorites(String uid) => '$users/$uid/favorites';
  static String userBookings(String uid) => '$users/$uid/bookings';
}
