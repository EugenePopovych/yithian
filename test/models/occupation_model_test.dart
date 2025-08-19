import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/occupation.dart';

void main() {
  group('Occupation.fromJson (shape matches model)', () {
    test('parses a valid occupation with your keys', () {
      final j = jsonDecode(r'''
        {
          "id": "antiquarian",
          "name": "Antiquarian",
          "creditMin": 30,
          "creditMax": 70,
          "selectCount": 4,
          "mandatorySkills": ["Appraise", "History"],
          "skillPool": ["Accounting", "Library Use"]
        }
      ''') as Map<String, dynamic>;

      final o = Occupation.fromJson(j);
      expect(o.id, 'antiquarian');
      expect(o.name, 'Antiquarian');
      expect(o.creditMin, 30);
      expect(o.creditMax, 70);
      expect(o.selectCount, 4);
      expect(o.mandatorySkills, containsAll(['Appraise', 'History']));
      expect(o.skillPool, containsAll(['Accounting', 'Library Use']));
    });

    test('fails when types do not match (creditMin as string)', () {
      final j = jsonDecode(r'''
        {
          "id": "bad",
          "name": "Bad",
          "creditMin": "10",
          "creditMax": 20,
          "selectCount": 0,
          "mandatorySkills": [],
          "skillPool": []
        }
      ''') as Map<String, dynamic>;

      expect(() => Occupation.fromJson(j), throwsA(isA<TypeError>()));
    });
  });
}
