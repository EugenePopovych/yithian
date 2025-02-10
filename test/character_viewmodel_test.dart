import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';

void main() {
  group('CharacterViewModel Tests', () {
    test('Initial character data should be correct', () {
      final viewModel = CharacterViewModel();

      expect(viewModel.character.name, equals("Investigator"));
      expect(viewModel.character.attributes.length, greaterThan(0));
      expect(viewModel.character.skills.length, greaterThan(0));
    });

    test('Updating an attribute should notify listeners', () {
      final viewModel = CharacterViewModel();
      bool notified = false;

      viewModel.addListener(() {
        notified = true;
      });

      viewModel.updateAttribute("Strength", 80);

      expect(viewModel.character.attributes.firstWhere((a) => a.name == "Strength").base, equals(80));
      expect(notified, isTrue);
    });

    test('Updating a skill should notify listeners', () {
      final viewModel = CharacterViewModel();
      bool notified = false;

      viewModel.addListener(() {
        notified = true;
      });

      viewModel.updateSkill("Spot Hidden", 90);

      expect(viewModel.character.skills.firstWhere((s) => s.name == "Spot Hidden").base, equals(90));
      expect(notified, isTrue);
    });
  });
}
