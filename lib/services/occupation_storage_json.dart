import 'dart:convert';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:coc_sheet/models/occupation.dart';
import 'package:coc_sheet/services/occupation_storage.dart';

/// Default asset path for occupations.
const String kDefaultOccupationsAsset = 'lib/data/occupations.json';

/// JSON-backed occupation storage.
/// Expects a top-level map: { "version": int, "occupations": [ ... ] }
class OccupationStorageJson implements OccupationStorage {
  OccupationStorageJson({
    required this.assetPath,
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final String assetPath;
  final AssetBundle _bundle;

  static const int kCurrentSchemaVersion = 1;

  List<Occupation>? _cache;
  int? _version;

  static final OccupationStorageJson instance = OccupationStorageJson(
    assetPath: kDefaultOccupationsAsset,
  );

  Future<void> _ensureLoaded() async {
    if (_cache != null && _version != null) return;

    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('occupations.json: top-level must be object');
    }

    final ver = decoded['version'];
    if (ver is! int || ver != kCurrentSchemaVersion) {
      throw StateError(
        'Unsupported occupations schema version: $ver; expected $kCurrentSchemaVersion',
      );
    }
    _version = ver;

    final list = decoded['occupations'];
    if (list is! List) {
      throw const FormatException('occupations.json: "occupations" must be a list');
    }

    final parsed = list
        .map((e) => Occupation.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    parsed.sort((a, b) => a.name.compareTo(b.name));
    _cache = parsed;
  }

  @override
  Future<List<Occupation>> getAll() async {
    await _ensureLoaded();
    return _cache!;
  }

  @override
  Future<Occupation?> findById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Occupation?> findByName(String name) async {
    final all = await getAll();
    final q = name.trim().toLowerCase();
    try {
      return all.firstWhere((o) => o.name.toLowerCase() == q);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> getVersion() async {
    await _ensureLoaded();
    return _version!;
  }
}
