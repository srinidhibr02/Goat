
/// Abstract contract for profile data operations.
abstract interface class ProfileRepository {
  /// Updates the display name in Firebase Auth and Firestore.
  Future<void> updateDisplayName(String uid, String displayName);

  /// Updates the photo URL in Firebase Auth and Firestore.
  Future<void> updatePhotoUrl(String uid, String photoUrl);
}
