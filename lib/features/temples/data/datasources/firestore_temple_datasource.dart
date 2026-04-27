import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/firestore_paths.dart';
import '../models/temple_model.dart';
import 'temples_datasource.dart';

/// Real implementation of [TemplesDatasource] using Cloud Firestore.
class FirestoreTempleDatasource implements TemplesDatasource {
  final FirebaseFirestore _firestore;

  FirestoreTempleDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<TempleModel>> getTemples() async {
    final snapshot = await _firestore.collection(FirestorePaths.temples).get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Ensure ID matches document ID
      return TempleModel.fromJson(data);
    }).toList();
  }

  @override
  Future<TempleModel> getTempleById(String id) async {
    final doc = await _firestore.collection(FirestorePaths.temples).doc(id).get();
    
    if (!doc.exists) throw StateError('Temple not found: $id');
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return TempleModel.fromJson(data);
  }
}
