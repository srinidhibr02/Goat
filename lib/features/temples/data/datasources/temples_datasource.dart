import '../models/temple_model.dart';

/// Interface for temple data operations.
abstract interface class TemplesDatasource {
  /// Fetches a list of temples.
  Future<List<TempleModel>> getTemples();

  /// Fetches a specific temple by ID.
  Future<TempleModel> getTempleById(String id);
}
