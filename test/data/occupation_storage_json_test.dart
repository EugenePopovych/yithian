import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/services/occupation_storage_json.dart';
import '../_test_utils/fake_asset_bundle.dart';

String _fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OccupationStorageJson', () {
    test('loads v1 fixture and returns occupations', () async {
      final bundle = FakeAssetBundle({
        kDefaultOccupationsAsset: _fixture('occupations_v1.json'),
      });

      final storage = OccupationStorageJson(
        assetPath: kDefaultOccupationsAsset,
        bundle: bundle,
      );

      final list = await storage.getAll();
      expect(list, isNotEmpty);
      expect(list.length, 2);

      final antiq = list.firstWhere((o) => o.id == 'antiquarian');
      expect(antiq.name, 'Antiquarian');
      expect(antiq.creditMin, 30);
      expect(antiq.creditMax, 70);
      expect(antiq.mandatorySkills, contains('Appraise'));
      expect(antiq.selectCount, 4);
      expect(antiq.skillPool, containsAll(['Accounting', 'Library Use', 'Spot Hidden']));
    });

    test('throws on version mismatch', () async {
      final bundle = FakeAssetBundle({
        kDefaultOccupationsAsset: _fixture('occupations_v2.json'),
      });

      final storage = OccupationStorageJson(
        assetPath: kDefaultOccupationsAsset,
        bundle: bundle,
      );

      expect(() => storage.getAll(), throwsA(isA<StateError>()));
    });

    test('bubbles up malformed occupation error (type issue)', () async {
      final bundle = FakeAssetBundle({
        kDefaultOccupationsAsset: _fixture('occupations_malformed.json'),
      });

      final storage = OccupationStorageJson(
        assetPath: kDefaultOccupationsAsset,
        bundle: bundle,
      );

      // creditMin is a string in fixture -> Occupation.fromJson cast fails
      expect(() => storage.getAll(), throwsA(isA<TypeError>()));
    });
  });
}
