import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/skill_bases.dart';
import 'package:coc_sheet/models/skill_specialization.dart';

void main() {
  group('SkillBases.baseForSpecialized (positional args)', () {
    test('Fighting bases', () {
      expect(
        SkillBases.baseForSpecialized(
          SkillSpecialization.familyFighting,
          'Brawl',
        ),
        25,
      );

      expect(
        SkillBases.baseForSpecialized(
          SkillSpecialization.familyFighting,
          'Sword',
        ),
        20,
      );
    });

    test('Firearms bases', () {
      expect(
        SkillBases.baseForSpecialized(
          SkillSpecialization.familyFirearms,
          'Handguns',
        ),
        20,
      );

      expect(
        SkillBases.baseForSpecialized(
          SkillSpecialization.familyFirearms,
          'Rifle/Shotgun',
        ),
        25,
      );

      // Default for other firearm types
      expect(
        SkillBases.baseForSpecialized(
          SkillSpecialization.familyFirearms,
          'SMG',
        ),
        20,
      );
    });
  });
}
