import 'package:flutter/services.dart';

/// Minimal in-memory AssetBundle for unit tests.
class FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> _strings;
  FakeAssetBundle(this._strings);

  @override
  Future<ByteData> load(String key) async {
    final s = _strings[key];
    if (s == null) {
      throw Exception('Asset not found: $key');
    }
    final bytes = Uint8List.fromList(s.codeUnits);
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final s = _strings[key];
    if (s == null) {
      throw Exception('Asset not found: $key');
    }
    return s;
  }
}
