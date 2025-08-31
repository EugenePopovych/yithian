# Title: Fighting & Firearms as Specialized Families

## Linked Design Document
- `docs/design/YET-001 fighting-firearms-as-families.md`

## Context
- **Files:**  
  - `lib/models/skill_specialization.dart`  
  - `lib/models/skill_bases.dart`  
  - `lib/models/creation_rule_set.dart`  
  - `lib/viewmodels/character_viewmodel.dart`  
  - `lib/screens/skills_tab.dart`
- **Current state:**  
  - Families supported: Art/Craft, Science, Language (Other), Pilot, Firearms.  
  - Fighting is only represented as “Fighting (Brawl)” hardcoded.  
  - Firearms has Handguns and Rifle/Shotgun as standalone skills, but Firearms is already a family constant.  
  - SkillsTab adds specializations via a **simple dialog**, not a dropdown.  
- **Problem/Goal:**  
  - Align with CoC 7e: Fighting and Firearms must be proper *families* of specialized skills.  
  - Seed defaults: Fighting (Brawl), Firearms (Handguns), Firearms (Rifle/Shotgun).  
  - Ensure UI allows adding custom specializations under both families via the dialog.

## Change request
1. **Model (`skill_specialization.dart`)**  
   - Add `familyFighting = 'Fighting'`.  
   - Add to static `families` list.  

2. **Model (`skill_bases.dart`)**  
   - Update `baseForSpecialized(family, specialization)` to return:  
     - Fighting (Brawl) → 25  
     - Fighting (any other) → 20  
     - Firearms (Handguns) → 20  
     - Firearms (Rifle/Shotgun) → 25  

3. **Creation (`creation_rule_set.dart`)**  
   - In `seedClassicSkills()`, ensure exactly once per character:  
     - Fighting (Brawl), Firearms (Handguns), Firearms (Rifle/Shotgun).  
   - Use `SkillBases.baseForSpecialized()` for base assignment.  

4. **ViewModel (`character_viewmodel.dart`)**  
   - Confirm `addSpecializedSkill({required category, required specialization})` already works with Fighting; no change expected.  
   - Optionally expose `specializationFamilies` = `SkillSpecialization.families` for UI to list families.  

5. **UI (`skills_tab.dart`)**  
   - In `_AddRow` (the specialization dialog), include **Fighting** and **Firearms** as selectable families.  
   - Keep current dialog flow: user picks family (from `SkillSpecialization.families`) and enters specialization text.  
   - On confirm: call `viewModel.addSpecializedSkill(category: chosenFamily, specialization: userText)`.  

## Acceptance tests
1. **Seeding:**  
   - New Classic character has exactly these three: Fighting (Brawl 25), Firearms (Handguns 20), Firearms (Rifle/Shotgun 25).  
   - No duplication on reseed.  
2. **UI:**  
   - Add Specialization dialog lists “Fighting” and “Firearms”.  
   - User can add e.g. Fighting (Sword) → base 20.  
   - User can add Firearms (SMG) → base 20.  
3. **Persistence:**  
   - Save/reload preserves specialized skills correctly.  
4. **No regressions:**  
   - Other families (Art/Craft, Science, Language, Pilot) unaffected.  
   - Tapping skill still opens Dice Roller with correct thresholds.  

## Constraints
- Imports must be `package:coc_sheet/...`.  
- Respect existing dark Call of Cthulhu UI.  
- No snackbar/Toast usage (inline feedback only if needed).  
- No schema migration needed; Hive already supports category/specialization.  

## Tests
- **Unit:**  
  - `skill_specialization_test.dart`: Fighting in `families`; `parse`/`displayName` round-trip.  
  - `skill_bases_test.dart`: base values for Fighting/Firearms specializations.  
  - `creation_rule_set_test.dart`: seeding includes exactly the three defaults, idempotent.  
- **ViewModel:**  
  - `character_viewmodel_test.dart`: `addSpecializedSkill('Fighting','Sword')` adds skill with base 20.  
- **Widget:**  
  - `skills_tab_test.dart`: dialog shows Fighting + Firearms families; adding new specialization works and displays correctly.

## Risk / Rollback
- Low risk: change isolated to specialization handling.  
- Rollback: remove `familyFighting` and revert seeding + bases logic; default skills remain as standalone.  
