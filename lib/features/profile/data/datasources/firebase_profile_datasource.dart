import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/firestore_paths.dart';
import 'profile_datasource.dart';

/// Updates profile in both Firebase Auth and Firestore.
class FirebaseProfileDatasource implements ProfileDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  FirebaseProfileDatasource({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

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
}
