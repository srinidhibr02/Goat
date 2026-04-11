import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/temple_model.dart';

/// Loads temple data from the bundled JSON asset.
///
/// To switch to Firestore, implement the same interface using
/// `cloud_firestore` and swap the provider.
class TemplesLocalDatasource {
  Future<List<TempleModel>> getTemples() async {
    final jsonString =
        await rootBundle.loadString('assets/data/temples_seed.json');
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((e) => TempleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TempleModel> getTempleById(String id) async {
    final temples = await getTemples();
    return temples.firstWhere(
      (t) => t.id == id,
      orElse: () => throw StateError('Temple not found: $id'),
    );
  }
}
