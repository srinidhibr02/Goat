import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDatasource _datasource;
  const ProfileRepositoryImpl(this._datasource);

  @override
  Future<void> updateDisplayName(String uid, String displayName) =>
      _datasource.updateDisplayName(uid, displayName);

  @override
  Future<void> updatePhotoUrl(String uid, String photoUrl) =>
      _datasource.updatePhotoUrl(uid, photoUrl);
}
