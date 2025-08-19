import 'package:coc_sheet/models/occupation.dart';

/// Abstraction for loading occupations from any backend/source.
abstract class OccupationStorage {
  /// Returns all occupations, sorted by name (recommended for UX).
  Future<List<Occupation>> getAll();

  /// Find by canonical id.
  Future<Occupation?> findById(String id);

  /// Find by exact name (case-insensitive).
  Future<Occupation?> findByName(String name);

  /// Version of the loaded dataset (from the JSON, DB, etc.).
  Future<int> getVersion();
}
