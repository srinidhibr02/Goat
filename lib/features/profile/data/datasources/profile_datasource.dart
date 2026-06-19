/// Abstract datasource contract for profile mutations.
abstract interface class ProfileDatasource {
  Future<void> updateDisplayName(String uid, String displayName);
  Future<void> updatePhotoUrl(String uid, String photoUrl);
}
