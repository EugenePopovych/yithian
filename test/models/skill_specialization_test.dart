import 'package:flutter_test/flutter_test.dart';
import 'package:coc_sheet/models/skill_specialization.dart';

void main() {
  test('families include Fighting', () {
    expect(SkillSpecialization.families,
        contains(SkillSpecialization.familyFighting));
  });

  test('displayName & parse round-trip for Fighting (Brawl)', () {
    final name = SkillSpecialization.displayName(
        SkillSpecialization.familyFighting, 'Brawl');
    final parsed = SkillSpecialization.parse(name);
    expect(parsed.category, SkillSpecialization.familyFighting);
    expect(parsed.specialization, 'Brawl');
  });

  test('displayName & parse round-trip for Firearms (Rifle/Shotgun)', () {
    final name = SkillSpecialization.displayName(
        SkillSpecialization.familyFirearms, 'Rifle/Shotgun');
    final parsed = SkillSpecialization.parse(name);
    expect(parsed.category, SkillSpecialization.familyFirearms);
    expect(parsed.specialization, 'Rifle/Shotgun');
  });
}
