import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/network/firestore_paths.dart';
import 'profile_datasource.dart';

/// Updates profile in Firebase Auth, Firestore, and Storage.
class FirebaseProfileDatasource implements ProfileDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  FirebaseProfileDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> updateDisplayName(String uid, String displayName) async {
    await Future.wait([
      _auth.currentUser!.updateDisplayName(displayName),
      _db
          .collection(FirestorePaths.users)
          .doc(uid)
          .set({'displayName': displayName}, SetOptions(merge: true)),
    ]);
  }

  @override
  Future<void> updatePhotoUrl(String uid, String photoUrl) async {
    await Future.wait([
      _auth.currentUser!.updatePhotoURL(photoUrl),
      _db
          .collection(FirestorePaths.users)
          .doc(uid)
          .set({'photoUrl': photoUrl}, SetOptions(merge: true)),
    ]);
  }

  /// Uploads [imageFile] to Firebase Storage under `avatars/{uid}.jpg`,
  /// then persists the download URL via [updatePhotoUrl].
  ///
  /// Returns the public download URL on success.
  Future<String> uploadAndSetAvatar(String uid, File imageFile) async {
    final ref = _storage.ref('avatars/$uid.jpg');

    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();
    await updatePhotoUrl(uid, url);
    return url;
  }
}
