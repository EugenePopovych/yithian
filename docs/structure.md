# Project Structure

- Generated at: 2025-09-01T00:49:22.471459  
- Generator: gen_structure.dart v0.2
- Root: `.`
- Scanned code: `lib`
- Scanned docs: `docs`
- Scanned tests: `test`

> This document lists **public APIs** found under `lib/`, the **docs** index, and the discovered **tests**.
> Private types are shown by name *(private)*; private members and generated files are skipped.

## Documentation (docs)

- project.md
- roadmap.md
- structure.md
- task_YIT-001-fighting-firearms-as-families.md
- task_YIT-002_refactor-categories-for-skills.md
- workflow.md
- yit-001 fighting-firearms-as-families.md
- yit-002 refactor categories for skills.md

## Index

- [main.dart](#lib-main-dart)
- [models/attribute.dart](#lib-models-attribute-dart)
- [models/character.dart](#lib-models-character-dart)
- [models/classic_creation_rule_set.dart](#lib-models-classic-creation-rule-set-dart)
- [models/classic_rules.dart](#lib-models-classic-rules-dart)
- [models/create_character_spec.dart](#lib-models-create-character-spec-dart)
- [models/creation_rule_set.dart](#lib-models-creation-rule-set-dart)
- [models/creation_update_event.dart](#lib-models-creation-update-event-dart)
- [models/credit_rating_range.dart](#lib-models-credit-rating-range-dart)
- [models/hive_attribute.dart](#lib-models-hive-attribute-dart)
- [models/hive_character.dart](#lib-models-hive-character-dart)
- [models/hive_skill.dart](#lib-models-hive-skill-dart)
- [models/occupation.dart](#lib-models-occupation-dart)
- [models/sheet_status.dart](#lib-models-sheet-status-dart)
- [models/skill.dart](#lib-models-skill-dart)
- [models/skill_bases.dart](#lib-models-skill-bases-dart)
- [models/skill_specialization.dart](#lib-models-skill-specialization-dart)
- [screens/attributes_tab.dart](#lib-screens-attributes-tab-dart)
- [screens/background_tab.dart](#lib-screens-background-tab-dart)
- [screens/character_list_screen.dart](#lib-screens-character-list-screen-dart)
- [screens/character_sheet_screen.dart](#lib-screens-character-sheet-screen-dart)
- [screens/create_character_dialog.dart](#lib-screens-create-character-dialog-dart)
- [screens/create_character_screen.dart](#lib-screens-create-character-screen-dart)
- [screens/dice_roller_screen.dart](#lib-screens-dice-roller-screen-dart)
- [screens/info_tab.dart](#lib-screens-info-tab-dart)
- [screens/main_screen.dart](#lib-screens-main-screen-dart)
- [screens/settings_screen.dart](#lib-screens-settings-screen-dart)
- [screens/skills_tab.dart](#lib-screens-skills-tab-dart)
- [services/character_storage.dart](#lib-services-character-storage-dart)
- [services/hive_character_storage.dart](#lib-services-hive-character-storage-dart)
- [services/hive_init.dart](#lib-services-hive-init-dart)
- [services/occupation_storage.dart](#lib-services-occupation-storage-dart)
- [services/occupation_storage_json.dart](#lib-services-occupation-storage-json-dart)
- [services/sheet_id_generator.dart](#lib-services-sheet-id-generator-dart)
- [theme_dark.dart](#lib-theme-dark-dart)
- [theme_light.dart](#lib-theme-light-dart)
- [viewmodels/character_viewmodel.dart](#lib-viewmodels-character-viewmodel-dart)
- [viewmodels/create_character_view_model.dart](#lib-viewmodels-create-character-view-model-dart)
- [viewmodels/dice_rolling_viewmodel.dart](#lib-viewmodels-dice-rolling-viewmodel-dart)
- [widgets/creation_row.dart](#lib-widgets-creation-row-dart)
- [widgets/inline_creation_feedback.dart](#lib-widgets-inline-creation-feedback-dart)
- [widgets/screen_nav_bar.dart](#lib-widgets-screen-nav-bar-dart)
- [widgets/stat_row.dart](#lib-widgets-stat-row-dart)

---

## main.dart
- **Imports (9):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/services/hive_init.dart`, `package:coc_sheet/services/hive_character_storage.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/screens/main_screen.dart`, `package:coc_sheet/theme_light.dart`, `package:coc_sheet/services/occupation_storage.dart`, `package:coc_sheet/services/occupation_storage_json.dart`

### Classes
- `class CocSheetApp` — ctors: `const CocSheetApp({Key? key})` — methods: `State<CocSheetApp> createState()`
- `class _CocSheetAppState` *(private)*

### Top-level Functions
- `void main()`

---

## models/attribute.dart

### Classes
- `class Attribute` — ctors: `Attribute({required String name, required int base})` — fields: `String name`; `int base`; `int hard`; `int extreme` — accessors: `int get base`; ` set base(int value)`; `int get hard`; `int get extreme`

---

## models/character.dart
- **Imports (3):** `attribute.dart`, `skill.dart`, `sheet_status.dart`

### Classes
- `class Character` — ctors: `Character({required String sheetId, required SheetStatus sheetStatus, required String sheetName, required String name, required int age, required String pronouns, required String birthplace, required String occupation, required String residence, required int currentHP, required int maxHP, required int currentSanity, required int startingSanity, required int currentMP, required int startingMP, required int currentLuck, required List<Attribute> attributes, required List<Skill> skills, String personalDescription = "", String ideologyAndBeliefs = "", String significantPeople = "", String meaningfulLocations = "", String treasuredPossessions = "", String traitsAndMannerisms = "", String injuriesAndScars = "", String phobiasAndManias = "", String arcaneTomesAndSpells = "", String encountersWithEntities = "", String gear = "", String wealth = "", String notes = "", bool hasMajorWound = false, bool isIndefinitelyInsane = false, bool isTemporarilyInsane = false, bool isUnconscious = false, bool isDying = false})` — fields: `final String sheetId`; `SheetStatus sheetStatus`; `String sheetName`; `String name`; `int age`; `String pronouns`; `String birthplace`; `String occupation`; `String residence`; `int currentHP`; `int maxHP`; `int currentSanity`; `int startingSanity`; `int currentMP`; `int startingMP`; `int currentLuck`; `List<Attribute> attributes`; `List<Skill> skills`; `String personalDescription`; `String ideologyAndBeliefs`; `String significantPeople`; `String meaningfulLocations`; `String treasuredPossessions`; `String traitsAndMannerisms`; `String injuriesAndScars`; `String phobiasAndManias`; `String arcaneTomesAndSpells`; `String encountersWithEntities`; `String gear`; `String wealth`; `String notes`; `bool hasMajorWound`; `bool isIndefinitelyInsane`; `bool isTemporarilyInsane`; `bool isUnconscious`; `bool isDying`; `int maxSanity`; `int movementRate` — accessors: `int get maxSanity`; `int get movementRate` — methods: `void updateAttribute(required String attributeName, required int newValue)`; `void updateSkill(required String skillName, required int newValue)`; `void updateLuck(required int luck)`; `Character copyWith({String? sheetId, SheetStatus? sheetStatus, String? sheetName, String? name, int? age, String? pronouns, String? birthplace, String? occupation, String? residence, int? currentHP, int? maxHP, int? currentSanity, int? startingSanity, int? currentMP, int? startingMP, int? currentLuck, List<Attribute>? attributes, List<Skill>? skills, String? personalDescription, String? ideologyAndBeliefs, String? significantPeople, String? meaningfulLocations, String? treasuredPossessions, String? traitsAndMannerisms, String? injuriesAndScars, String? phobiasAndManias, String? arcaneTomesAndSpells, String? encountersWithEntities, String? gear, String? wealth, String? notes, bool? hasMajorWound, bool? isIndefinitelyInsane, bool? isTemporarilyInsane, bool? isUnconscious, bool? isDying})`

---

## models/classic_creation_rule_set.dart
- **Imports (5):** `dart:math`, `package:coc_sheet/models/classic_rules.dart`, `package:coc_sheet/models/creation_rule_set.dart`, `package:coc_sheet/models/credit_rating_range.dart`, `package:coc_sheet/models/skill.dart`

### Classes
- `class ClassicCreationRuleSet` — ctors: `ClassicCreationRuleSet({bool Function(String)? isOccupationSkill})` — fields: `String id`; `String label`; `bool canFinalize` — accessors: `String get id`; `String get label`; `bool get canFinalize` — methods: `void seedOccupationSkills(required Set<String> skills)`; `bool isOccupationSkill(required String name)`; `void initialize({String? sheetName, String? name, String? occupation})`; `void onEnter()`; `RuleUpdateResult update(required CreationChange change)`; `void rollAttributes()`; `void seedCreditRatingRange(required CreditRatingRange range)`

---

## models/classic_rules.dart
- **Imports (1):** `dart:math`

### Classes
- `class AttrKey` — ctors: `AttrKey()` — fields: `static const String str`; `static const String con`; `static const String dex`; `static const String app`; `static const String intg`; `static const String pow`; `static const String siz`; `static const String edu`; `static const List<String> all`
- `class DbBuild` — ctors: `const DbBuild(required String db, required int build)` — fields: `final String db`; `final int build`
- `class ClassicRolls` — ctors: `ClassicRolls([Random? rng])` — methods: `int d6()`; `int d10()`; `int roll3d6x5()`; `int roll2d6p6x5()`; `int rollLuck({required int age})`

### Top-level Functions
- `DbBuild calcDamageBonus(required int str, required int siz)`
- `int calcHP(required int con, required int siz)`
- `int calcMP(required int pow)`
- `int calcSanity(required int pow)`
- `int calcMove({required int str, required int dex, required int siz, required int age})`
- `int eduChecksForAge(required int age)`
- `Map<String, int> applyAgeToAttributes(required Map<String, int> attrs, {required int age, Random? rng})`
- `Map<String, int> buildBaseSkills(required Map<String, int> attrs)`

### Top-level Variables
- `const Map<String, int> kStaticSkillBases`

---

## models/create_character_spec.dart
- **Imports (1):** `package:flutter/foundation.dart`

### Classes
- `class CreateCharacterSpec` — ctors: `const CreateCharacterSpec({required String name, required int age, required Map<String, int> attributes, required int luck, required String occupationId, required List<String> selectedSkills})` — fields: `final String name`; `final int age`; `final Map<String, int> attributes`; `final int luck`; `final String occupationId`; `final List<String> selectedSkills`

---

## models/creation_rule_set.dart
- **Imports (9):** `package:meta/meta.dart`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/attribute.dart`, `package:coc_sheet/models/skill.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/models/credit_rating_range.dart`, `package:coc_sheet/models/classic_creation_rule_set.dart`, `package:coc_sheet/models/skill_specialization.dart`, `package:coc_sheet/models/skill_bases.dart`

### Enums
- `enum ChangeTarget` — values: `attribute`, `skill`

### Mixins
- `mixin SkillPointPools` — fields: `int? occupationPointsRemaining`; `int? personalPointsRemaining`; `bool canFinalizeSkillPools` — methods: `void setSkillPoolTotals({required int edu, required int intel})`; `void seedPools({required int occupation, required int personal})`; `int spendSkill(required bool occupation, required int need)`; `void refundSkill(required int pts, {bool preferOccupation = false})`

### Classes
- `class CreationChange` — ctors: `const CreationChange(required ChangeTarget target, required String name, required int newBase, {bool? isOccupation})`; `const CreationChange.attribute(required String name, required int v)`; `const CreationChange.skill(required String name, required int v, {bool? isOccupation})` — fields: `final ChangeTarget target`; `final String name`; `final int newBase`; `final bool? isOccupation`
- `class RuleUpdateResult` — ctors: `const RuleUpdateResult({required bool applied, int? effectiveValue, List<String> messages = const []})` — fields: `final bool applied`; `final int? effectiveValue`; `final List<String> messages`
- `class PointPool` — ctors: `PointPool({required int total, int spent = 0})` — fields: `int total`; `int spent`; `int remaining` — accessors: `int get remaining` — methods: `int spend(required int want)`; `int refund(required int pts)`
- `class CreationRuleSet` — ctors: `CreationRuleSet()` — fields: `Character character`; `String id`; `String label`; `int? attributePointsRemaining`; `int? occupationPointsRemaining`; `int? personalPointsRemaining`; `bool canFinalize`; `CreditRatingRange? creditRatingRange` — accessors: `String get id`; `String get label`; `int? get attributePointsRemaining`; `int? get occupationPointsRemaining`; `int? get personalPointsRemaining`; `bool get canFinalize`; `CreditRatingRange? get creditRatingRange` — methods: `bool isOccupationSkill(required String name)`; `void seedOccupationSkills(required Set<String> skills)`; `void seedPools({required int occupation, required int personal})`; `void bind(required Character c)`; `void onEnter()`; `void onExit()`; `void initialize({String? sheetName, String? name, String? occupation})`; `RuleUpdateResult update(required CreationChange change)`; `void rollAttributes()`; `void rollSkills()`; `void seedCreditRatingRange(required CreditRatingRange range)`; `void finalizeDraft()`; `void ensureAttr(required String n)`; `void ensureSkill(required String name, required int base)`; `int attr(required String name)`; `int skill(required String name)`; `void seedClassicSkills()`; `bool hasSpecialized(required String family, required String spec)`; `void ensureSpecialized(required String family, required String spec)`; `void ensureGenericAny(required String family, required int base)`; `void ensureLanguageOther()`
- `class CreationRules` — ctors: `CreationRules()` — methods: `static CreationRuleSet forStatus(required SheetStatus status)`

---

## models/creation_update_event.dart
- **Imports (1):** `package:coc_sheet/models/creation_rule_set.dart`

### Classes
- `class CreationUpdateEvent` — ctors: `CreationUpdateEvent({required ChangeTarget target, required String name, required int attemptedValue, required RuleUpdateResult result, DateTime? timestamp})` — fields: `final ChangeTarget target`; `final String name`; `final int attemptedValue`; `final RuleUpdateResult result`; `final DateTime timestamp`; `bool applied`; `int? effectiveValue`; `List<String> codes`; `List<String> friendlyMessages` — accessors: `bool get applied`; `int? get effectiveValue`; `List<String> get codes`; `List<String> get friendlyMessages` — methods: `String toString()`

---

## models/credit_rating_range.dart

### Classes
- `class CreditRatingRange` — ctors: `const CreditRatingRange({required int min, required int max})` — fields: `final int min`; `final int max` — methods: `String toString()`

---

## models/hive_attribute.dart
- **Imports (2):** `package:hive/hive.dart`, `attribute.dart`

### Classes
- `class HiveAttribute` — ctors: `HiveAttribute({required String name, required int base})`; `factory HiveAttribute.fromAttribute(required Attribute a)` — fields: `String name`; `int base` — methods: `Attribute toAttribute()`

---

## models/hive_character.dart
- **Imports (5):** `package:hive/hive.dart`, `package:coc_sheet/models/hive_attribute.dart`, `package:coc_sheet/models/hive_skill.dart`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/sheet_status.dart`

### Classes
- `class HiveCharacter` — ctors: `HiveCharacter({required String sheetName, required String name, required int age, required String pronouns, required String birthplace, required String occupation, required String residence, required int currentHP, required int maxHP, required int currentSanity, required int startingSanity, required int currentMP, required int startingMP, required int currentLuck, required List<HiveAttribute> attributes, required List<HiveSkill> skills, String personalDescription = "", String ideologyAndBeliefs = "", String significantPeople = "", String meaningfulLocations = "", String treasuredPossessions = "", String traitsAndMannerisms = "", String injuriesAndScars = "", String phobiasAndManias = "", String arcaneTomesAndSpells = "", String encountersWithEntities = "", String gear = "", String wealth = "", String notes = "", bool hasMajorWound = false, bool isIndefinitelyInsane = false, bool isTemporarilyInsane = false, bool isUnconscious = false, bool isDying = false, String? sheetStatusCode = "draft_free"})`; `factory HiveCharacter.fromCharacter(required Character c)` — fields: `String sheetName`; `String name`; `int age`; `String pronouns`; `String birthplace`; `String occupation`; `String residence`; `int currentHP`; `int maxHP`; `int currentSanity`; `int startingSanity`; `int currentMP`; `int startingMP`; `int currentLuck`; `List<HiveAttribute> attributes`; `List<HiveSkill> skills`; `String personalDescription`; `String ideologyAndBeliefs`; `String significantPeople`; `String meaningfulLocations`; `String treasuredPossessions`; `String traitsAndMannerisms`; `String injuriesAndScars`; `String phobiasAndManias`; `String arcaneTomesAndSpells`; `String encountersWithEntities`; `String gear`; `String wealth`; `String notes`; `bool hasMajorWound`; `bool isIndefinitelyInsane`; `bool isTemporarilyInsane`; `bool isUnconscious`; `bool isDying`; `String? sheetStatusCode` — methods: `Character toCharacter()`

---

## models/hive_skill.dart
- **Imports (2):** `package:hive/hive.dart`, `skill.dart`

### Classes
- `class HiveSkill` — ctors: `HiveSkill({required String name, required int base, String? category, String? specialization, bool isOccupation = false})`; `factory HiveSkill.fromSkill(required Skill s)` — fields: `String name`; `int base`; `String? category`; `String? specialization`; `bool isOccupation` — methods: `Skill toSkill()`

---

## models/occupation.dart

### Classes
- `class Occupation` — ctors: `const Occupation({required String id, required String name, required int creditMin, required int creditMax, required int selectCount, List<String> mandatorySkills = const [], List<String> skillPool = const []})`; `factory Occupation.fromJson(required Map<String, dynamic> j)` — fields: `final String id`; `final String name`; `final int creditMin`; `final int creditMax`; `final int selectCount`; `final List<String> mandatorySkills`; `final List<String> skillPool` — methods: `Map<String, dynamic> toJson()`; `String toString()`

---

## models/sheet_status.dart

### Enums
- `enum SheetStatus` — values: `active`, `archived`, `draftClassic`, `draftPoints`, `draftFree`

### Extensions
- `extension SheetStatusX on SheetStatus` — accessors: `bool get isDraft`

---

## models/skill.dart

### Classes
- `class Skill` — ctors: `Skill({required String name, required int base, bool canUpgrade = false, String? category, String? specialization})` — fields: `String name`; `bool canUpgrade`; `String? category`; `String? specialization`; `bool isOccupation`; `int base`; `int hard`; `int extreme`; `bool isSpecialized`; `String displayName` — accessors: `int get base`; ` set base(int value)`; `int get hard`; `int get extreme`; `bool get isSpecialized`; `String get displayName`

---

## models/skill_bases.dart
- **Imports (1):** `skill_specialization.dart`

### Classes
- `class SkillBases` — ctors: `SkillBases()` — methods: `static int baseForGeneric(required String family)`; `static int baseForSpecialized(required String family, required String specialization)`

---

## models/skill_specialization.dart

### Classes
- `class SkillSpecialization` — ctors: `SkillSpecialization()` — fields: `static const String familyArtCraft`; `static const String familyScience`; `static const String familyLanguageOther`; `static const String familyPilot`; `static const String familyFirearms`; `static const String familyFighting`; `static const List<String> families` — methods: `static String displayName(required String category, required String specialization)`; `static ({String? category, String? specialization}) parse(required String skillName)`; `static bool isOfFamily(required String skillName, required String family)`; `static bool isGenericFamily(required String skillName)`

---

## screens/attributes_tab.dart
- **Imports (8):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/models/attribute.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/widgets/stat_row.dart`, `package:coc_sheet/screens/dice_roller_screen.dart`, `package:coc_sheet/widgets/creation_row.dart`

### Classes
- `class AttributesTab` — ctors: `const AttributesTab({Key? key})` — methods: `State<AttributesTab> createState()`
- `class _AttributesTabState` *(private)*

---

## screens/background_tab.dart
- **Imports (4):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/widgets/creation_row.dart`

### Classes
- `class BackgroundTab` — ctors: `BackgroundTab({Key? key})` — methods: `Widget build(required BuildContext context)`

---

## screens/character_list_screen.dart
- **Imports (8):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/models/create_character_spec.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/services/occupation_storage.dart`, `package:coc_sheet/screens/create_character_screen.dart`

### Classes
- `class CharacterListScreen` — ctors: `const CharacterListScreen({Key? key, void Function()? onCharacterSelected})` — fields: `final void Function()? onCharacterSelected` — methods: `Widget build(required BuildContext context)`

---

## screens/character_sheet_screen.dart
- **Imports (8):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/screens/info_tab.dart`, `package:coc_sheet/screens/attributes_tab.dart`, `package:coc_sheet/screens/skills_tab.dart`, `package:coc_sheet/screens/background_tab.dart`, `package:coc_sheet/models/sheet_status.dart`

### Classes
- `class CharacterSheetScreen` — ctors: `const CharacterSheetScreen({Key? key})` — methods: `CharacterSheetScreenState createState()`
- `class CharacterSheetScreenState` — ctors: `CharacterSheetScreenState()` — methods: `void didChangeDependencies()`; `void dispose()`; `Widget build(required BuildContext context)`

---

## screens/create_character_dialog.dart
- **Imports (2):** `package:flutter/material.dart`, `package:coc_sheet/models/sheet_status.dart`

### Classes
- `class CreateCharacterRequest` — ctors: `const CreateCharacterRequest({required String name, required String occupation, required SheetStatus status})` — fields: `final String name`; `final String occupation`; `final SheetStatus status`

### Top-level Functions
- `Future<CreateCharacterRequest?> showCreateCharacterDialog(required BuildContext context)`

---

## screens/create_character_screen.dart
- **Imports (7):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/models/create_character_spec.dart`, `package:coc_sheet/models/occupation.dart`, `package:coc_sheet/models/classic_rules.dart`, `package:coc_sheet/services/occupation_storage_json.dart`, `package:coc_sheet/viewmodels/create_character_view_model.dart`

### Classes
- `class CreateCharacterScreen` — ctors: `const CreateCharacterScreen({Key? key, void Function(CreateCharacterSpec)? onCreate})` — fields: `final void Function(CreateCharacterSpec)? onCreate` — methods: `State<CreateCharacterScreen> createState()`
- `class _CreditRatingHint` *(private)*
- `class _CreateCharacterScreenState` *(private)*
- `class _Body` *(private)*
- `class _AttributesGrid` *(private)*
- `class _SquareValue` *(private)*
- `class _OccupationPicker` *(private)*
- `class _OccupationPickerState` *(private)*
- `class _SpecScope` *(private)*
- `class _OccupationSkills` *(private)*

### Top-level Variables
- `const double kOccupationListHeight`

---

## screens/dice_roller_screen.dart
- **Imports (3):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/viewmodels/dice_rolling_viewmodel.dart`

### Classes
- `class DiceRollerScreen` — ctors: `const DiceRollerScreen({Key? key, String? skillName, int? base, int? hard, int? extreme})` — fields: `final String? skillName`; `final int? base`; `final int? hard`; `final int? extreme` — methods: `Widget build(required BuildContext context)`
- `class _DiceRollerBody` *(private)*
- `class _SkillThresholds` *(private)*
- `class _ChipKV` *(private)*
- `class _BonusPenaltyRow` *(private)*
- `class _Stepper` *(private)*
- `class _DicePad` *(private)*
- `class _DieButtonData` *(private)*
- `class _SelectedDiceRow` *(private)*
- `class _MiniIconButton` *(private)*
- `class _RollButton` *(private)*
- `class _ResultArea` *(private)*

---

## screens/info_tab.dart
- **Imports (4):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/widgets/creation_row.dart`

### Classes
- `class InfoTab` — ctors: `const InfoTab({Key? key})` — methods: `State<InfoTab> createState()`
- `class _InfoTabState` *(private)*

---

## screens/main_screen.dart
- **Imports (8):** `package:flutter/material.dart`, `package:provider/provider.dart`, `../screens/character_list_screen.dart`, `../screens/character_sheet_screen.dart`, `../screens/dice_roller_screen.dart`, `../screens/settings_screen.dart`, `../widgets/screen_nav_bar.dart`, `../viewmodels/character_viewmodel.dart`

### Classes
- `class MainScreen` — ctors: `const MainScreen({Key? key})` — methods: `State<MainScreen> createState()`
- `class _MainScreenState` *(private)*

---

## screens/settings_screen.dart
- **Imports (1):** `package:flutter/material.dart`

### Classes
- `class SettingsScreen` — ctors: `const SettingsScreen({Key? key})` — methods: `Widget build(required BuildContext context)`

---

## screens/skills_tab.dart
- **Imports (11):** `dart:async`, `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/skill.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/models/creation_rule_set.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`, `package:coc_sheet/widgets/stat_row.dart`, `package:coc_sheet/widgets/creation_row.dart`, `package:coc_sheet/screens/dice_roller_screen.dart`

### Extensions
- `extension  on Widget`

### Classes
- `class SkillsTab` — ctors: `const SkillsTab({Key? key})` — methods: `State<SkillsTab> createState()`
- `class _Tile` *(private)*
- `class _FamilyBucket` *(private)*
- `class _GroupOrSolo` *(private)*
- `class _SkillsTabState` *(private)*
- `class _AddRow` *(private)*
- `class _Bubble` *(private)*

---

## services/character_storage.dart
- **Imports (3):** `dart:async`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/sheet_status.dart`

### Type Aliases
- `typedef SheetId = String`

### Classes
- `class CharacterStorage` — ctors: `CharacterStorage()` — methods: `Future<void> store(required Character character)`; `Stream<List<Character>> getCharacters({Set<SheetStatus> statuses = const {SheetStatus.active, SheetStatus.archived}})`; `Future<Character?> getRecent()`; `Future<void> delete(required String id)`

---

## services/hive_character_storage.dart
- **Imports (6):** `dart:async`, `package:hive/hive.dart`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/hive_character.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/services/character_storage.dart`

### Classes
- `class HiveCharacterStorage` — ctors: `HiveCharacterStorage()` — methods: `Future<void> store(required Character character)`; `Stream<List<Character>> getCharacters({Set<SheetStatus> statuses = const {SheetStatus.active, SheetStatus.archived}})`; `Future<Character?> getRecent()`; `Future<void> delete(required String id)`

---

## services/hive_init.dart
- **Imports (4):** `package:hive_flutter/hive_flutter.dart`, `package:coc_sheet/models/hive_character.dart`, `package:coc_sheet/models/hive_attribute.dart`, `package:coc_sheet/models/hive_skill.dart`

### Classes
- `class Schema` — ctors: `Schema()` — fields: `static const int current`; `static const String metaBox`; `static const String key`

### Top-level Functions
- `Future<void> initHive()`

---

## services/occupation_storage.dart
- **Imports (1):** `package:coc_sheet/models/occupation.dart`

### Classes
- `class OccupationStorage` — ctors: `OccupationStorage()` — methods: `Future<List<Occupation>> getAll()`; `Future<Occupation?> findById(required String id)`; `Future<Occupation?> findByName(required String name)`; `Future<int> getVersion()`

---

## services/occupation_storage_json.dart
- **Imports (4):** `dart:convert`, `package:flutter/services.dart`, `package:coc_sheet/models/occupation.dart`, `package:coc_sheet/services/occupation_storage.dart`

### Classes
- `class OccupationStorageJson` — ctors: `OccupationStorageJson({required String assetPath, AssetBundle? bundle})` — fields: `final String assetPath`; `static const int kCurrentSchemaVersion`; `static final OccupationStorageJson instance` — methods: `Future<List<Occupation>> getAll()`; `Future<Occupation?> findById(required String id)`; `Future<Occupation?> findByName(required String name)`; `Future<int> getVersion()`

### Top-level Variables
- `const String kDefaultOccupationsAsset`

---

## services/sheet_id_generator.dart
- **Imports (1):** `package:uuid/uuid.dart`

### Type Aliases
- `typedef SheetId = String`

### Classes
- `class SheetIdGenerator` — ctors: `SheetIdGenerator()` — methods: `String newId()`
- `class UuidSheetIdGenerator` — ctors: `UuidSheetIdGenerator()` — methods: `String newId()`

---

## theme_dark.dart
- **Imports (1):** `package:flutter/material.dart`

### Top-level Variables
- `final ThemeData cocThemeDark`

---

## theme_light.dart
- **Imports (1):** `package:flutter/material.dart`

### Top-level Variables
- `const Color selectedNavColor`
- `const Color availableNavColor`
- `final Color disabledNavColor`
- `final ThemeData cocThemeLight`

---

## viewmodels/character_viewmodel.dart
- **Imports (16):** `dart:async`, `package:flutter/foundation.dart`, `package:coc_sheet/models/character.dart`, `package:coc_sheet/models/attribute.dart`, `package:coc_sheet/models/skill.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/models/creation_rule_set.dart`, `package:coc_sheet/models/creation_update_event.dart`, `package:coc_sheet/models/credit_rating_range.dart`, `package:coc_sheet/models/create_character_spec.dart`, `package:coc_sheet/models/classic_rules.dart`, `package:coc_sheet/models/skill_bases.dart`, `package:coc_sheet/models/skill_specialization.dart`, `package:coc_sheet/services/character_storage.dart`, `package:coc_sheet/services/sheet_id_generator.dart`, `package:coc_sheet/services/occupation_storage.dart`

### Classes
- `class CharacterViewModel` — ctors: `CharacterViewModel(required CharacterStorage _storage, {SheetIdGenerator? ids})` — fields: `final ValueNotifier<CreationUpdateEvent?> lastCreationUpdate`; `Character? character`; `bool hasCharacter`; `CreationRuleSet? rules`; `int? occupationPointsRemaining`; `int? personalPointsRemaining`; `bool canFinalizeCreation`; `CreditRatingRange? creditRatingRange`; `int? movementRate`; `String damageBonusText`; `int? buildValue` — accessors: `Character? get character`; `bool get hasCharacter`; `CreationRuleSet? get rules`; `int? get occupationPointsRemaining`; `int? get personalPointsRemaining`; `bool get canFinalizeCreation`; `CreditRatingRange? get creditRatingRange`; `int? get movementRate`; `String get damageBonusText`; `int? get buildValue` — methods: `Future<void> init()`; `Future<void> loadCharacter(required String id)`; `Future<void> createCharacter({String? name, String? occupation, SheetStatus? status})`; `Stream<List<Character>> charactersStream({Set<SheetStatus> statuses = const {SheetStatus.active, SheetStatus.archived}})`; `Future<void> deleteById(required String sheetId)`; `Future<void> addSpecializedSkill({required String category, required String specialization})`; `Future<void> removeSkillByName(required String name)`; `bool isOccupationSkill(required String name)`; `void dispose()`; `Future<void> createFromSpec(required CreateCharacterSpec spec, {required OccupationStorage occupationStorage})`; `Future<void> saveCharacter()`; `void setCharacter(required Character newCharacter)`; `void clearCharacter()`; `void rollAttributes()`; `void rollSkills()`; `Future<void> finalizeCreation()`; `Future<void> discardCurrent()`; `void updateCharacterSheetName(required String newSheetName)`; `void updateCharacterName(required String newName)`; `void updateCharacterInfo({String? pronouns, String? birthplace, String? occupation, String? residence, int? age})`; `void updateAttribute(required String name, required int newValue)`; `void updateSkill({required Skill skill, required int newValue})`; `void updateHealth(required int currentHP, required int maxHP)`; `void updateSanity(required int currentSanity, required int startingSanity)`; `void updateMagicPoints(required int currentMP, required int startingMP)`; `void updateStatus({bool? hasMajorWound, bool? isIndefinitelyInsane, bool? isTemporarilyInsane, bool? isUnconscious, bool? isDying})`; `void updateBackground({String? personalDescription, String? ideologyAndBeliefs, String? significantPeople, String? meaningfulLocations, String? treasuredPossessions, String? traitsAndMannerisms, String? injuriesAndScars, String? phobiasAndManias, String? arcaneTomesAndSpells, String? encountersWithEntities, String? gear, String? wealth, String? notes})`; `void updateLuck(required int luck)`

---

## viewmodels/create_character_view_model.dart
- **Imports (4):** `dart:math`, `package:flutter/foundation.dart`, `package:coc_sheet/models/occupation.dart`, `package:coc_sheet/models/classic_rules.dart`

### Classes
- `class DamageBonus` — ctors: `const DamageBonus(required String db, required int build)` — fields: `final String db`; `final int build`
- `class CreateCharacterViewModel` — ctors: `CreateCharacterViewModel({Random? rng})` — fields: `String name`; `int age`; `Map<String, int> attributes`; `int luck`; `int hp`; `int mp`; `int sanity`; `int move`; `DamageBonus damageBonus`; `int occupationPoints`; `int personalPoints`; `Occupation? occupation`; `Set<String> selectedSkills`; `bool isReadyToCreate` — accessors: `String get name`; `int get age`; `Map<String, int> get attributes`; `int get luck`; `int get hp`; `int get mp`; `int get sanity`; `int get move`; `DamageBonus get damageBonus`; `int get occupationPoints`; `int get personalPoints`; `Occupation? get occupation`; `Set<String> get selectedSkills`; `bool get isReadyToCreate` — methods: `void setName(required String value)`; `void setAge(required int value)`; `void rollAll()`; `void rerollAttributes()`; `void selectOccupation(required Occupation? occ)`; `void setOccupationSkills(required Set<String> fullSelection)`

---

## viewmodels/dice_rolling_viewmodel.dart
- **Imports (2):** `dart:math`, `package:flutter/foundation.dart`

### Enums
- `enum DieType` — values: `d3`, `d4`, `d6`, `d8`, `d10`, `d12`, `d20`, `d100`
- `enum DiceMode` — values: `skillD100`, `plainD100`, `adHoc`

### Classes
- `class SingleDieRoll` — ctors: `SingleDieRoll({required DieType type, required List<int> rolls})` — fields: `final DieType type`; `final List<int> rolls`; `final int subtotal`
- `class DiceRollResult` — ctors: `DiceRollResult({required List<SingleDieRoll> details})` — fields: `final List<SingleDieRoll> details`; `final int total`
- `class D100RollBreakdown` — ctors: `D100RollBreakdown({required int value, required int onesDigit, required List<int> tensCandidates, required int chosenTensDigit, required int netBonusCount, required int netPenaltyCount})` — fields: `final int value`; `final int onesDigit`; `final List<int> tensCandidates`; `final int chosenTensDigit`; `final int netBonusCount`; `final int netPenaltyCount`
- `class D100RollResult` — ctors: `D100RollResult({required D100RollBreakdown breakdown})` — fields: `final D100RollBreakdown breakdown`
- `class SkillContext` — ctors: `const SkillContext({required String skillName, required int target, required int hard, required int extreme})` — fields: `final String skillName`; `final int target`; `final int hard`; `final int extreme`
- `class DiceRollingViewModel` — ctors: `DiceRollingViewModel()` — fields: `DiceMode mode`; `bool hasSkillContext`; `SkillContext? skillContext`; `int bonusDice`; `int penaltyDice`; `Map<DieType, int> dicePool`; `DiceRollResult? lastAdHocResult`; `D100RollResult? lastD100Result` — accessors: `DiceMode get mode`; `bool get hasSkillContext`; `SkillContext? get skillContext`; `int get bonusDice`; `int get penaltyDice`; `Map<DieType, int> get dicePool`; `DiceRollResult? get lastAdHocResult`; `D100RollResult? get lastD100Result` — methods: `void setMode(required DiceMode mode)`; `void setSkillContext(required SkillContext? ctx)`; `void setBonusDice(required int value)`; `void setPenaltyDice(required int value)`; `void addDie(required DieType type, [int count = 1])`; `void removeDie(required DieType type, [int count = 1])`; `void clearDice()`; `void resetResults()`; `D100RollResult rollD100()`; `DiceRollResult rollAdHoc()`

---

## widgets/creation_row.dart
- **Imports (4):** `package:flutter/material.dart`, `package:provider/provider.dart`, `package:coc_sheet/models/sheet_status.dart`, `package:coc_sheet/viewmodels/character_viewmodel.dart`

### Classes
- `class CreationRow` — ctors: `const CreationRow._()` — methods: `static Widget info()`; `static Widget attributes()`; `static Widget skills()`; `static Widget background()`
- `class _Panel` *(private)*
- `class _CreationInfoRow` *(private)*
- `class _CreationAttributesRow` *(private)*
- `class _CreationSkillsRow` *(private)*
- `class _CreationBackgroundRow` *(private)*

---

## widgets/inline_creation_feedback.dart
- **Imports (1):** `package:flutter/material.dart`

### Classes
- `class InlineCreationFeedback` — ctors: `const InlineCreationFeedback({Key? key, required String message, bool isError = false, bool isWarning = false})` — fields: `final String message`; `final bool isError`; `final bool isWarning` — methods: `Widget build(required BuildContext context)`

---

## widgets/screen_nav_bar.dart
- **Imports (2):** `package:flutter/material.dart`, `../theme_light.dart`

### Classes
- `class ScreenNavBar` — ctors: `const ScreenNavBar({Key? key, required int currentIndex, required void Function(int) onTap, required bool hasCharacter})` — fields: `final int currentIndex`; `final void Function(int) onTap`; `final bool hasCharacter` — methods: `Widget build(required BuildContext context)`

---

## widgets/stat_row.dart
- **Imports (1):** `package:flutter/material.dart`

### Classes
- `class StatRow` — ctors: `const StatRow({Key? key, required String name, required int base, required int hard, required int extreme, required void Function() onTap, required TextEditingController controller, required void Function(int) onBaseChanged, required bool enabled, required bool locked, required bool occupation, void Function()? onDelete, bool showBorder = true})` — fields: `final String name`; `final int base`; `final int hard`; `final int extreme`; `final void Function() onTap`; `final TextEditingController controller`; `final void Function(int) onBaseChanged`; `final bool enabled`; `final bool locked`; `final bool occupation`; `final void Function()? onDelete`; `final bool showBorder` — methods: `Widget build(required BuildContext context)`

### Top-level Variables
- `const double kStatRowTileWidth`
- `const double kStatRowLabelWidth`
- `const double kStatRowDeleteWidth`
- `const double kStatRowMetricWidth`
- `const double kStatRowCellGap`
- `const double kStatRowHeight`

---

## Tests

### test/_test_utils/fake_asset_bundle.dart
- **Groups:** 0
- **Tests:** 0

### test/data/occupation_storage_json_test.dart
- **Groups:** 1
- **Tests:** 3

**Group Names**
- OccupationStorageJson

**Test Names**
- OccupationStorageJson > bubbles up malformed occupation error (type issue)
- OccupationStorageJson > loads v1 fixture and returns occupations
- OccupationStorageJson > throws on version mismatch

### test/models/character_model_test.dart
- **Groups:** 1
- **Tests:** 10

**Group Names**
- Character Model Tests

**Test Names**
- Character Model Tests > Background fields should be correctly stored and retrievable
- Character Model Tests > Character should initialize with correct general info
- Character Model Tests > Current HP should not exceed Max HP
- Character Model Tests > Movement Rate should be 7 when both DEX and STR are less than SIZ
- Character Model Tests > Movement Rate should be 8 when either DEX or STR is equal to SIZ
- Character Model Tests > Movement Rate should be 9 when DEX and STR are greater than SIZ
- Character Model Tests > Sanity should not exceed Max Sanity
- Character Model Tests > SheetStatus isDraft helper works
- Character Model Tests > Status flags should toggle correctly
- Character Model Tests > Updating Cthulhu Mythos skill should correctly update maxSanity

### test/models/classic_creation_rule_set_test.dart
- **Groups:** 0
- **Tests:** 6

**Test Names**
- Cthulhu Mythos cannot be increased via update()
- attribute clamping is enforced via update()
- classic skills are seeded with correct base values
- initialize computes derived stats from rolled attributes
- initialize seeds all core attributes in expected ranges
- skill point pools are initialized from EDU and INT

### test/models/classic_rules_test.dart
- **Groups:** 4
- **Tests:** 7

**Group Names**
- Age adjustments
- Derived calculators
- Roll helpers
- Skill bases

**Test Names**
- Age adjustments > EDU checks count
- Age adjustments > Teen rule applies EDU -5 and then checks (none for teens)
- Derived calculators > Damage Bonus / Build bands (raw STR+SIZ)
- Derived calculators > HP/MP/Sanity basic math
- Derived calculators > Move & age modifiers
- Roll helpers > Luck teen advantage takes max of two rolls
- Skill bases > Dodge = DEX/2, Language (Own) = EDU; includes static bases

### test/models/creation_rule_set_generics_test.dart
- **Groups:** 0
- **Tests:** 2

**Test Names**
- Generic rows are idempotent (no duplicates on reseed)
- Seeds structured generic family rows with correct names

### test/models/occupation_model_test.dart
- **Groups:** 1
- **Tests:** 2

**Group Names**
- Occupation.fromJson (shape matches model)

**Test Names**
- Occupation.fromJson (shape matches model) > fails when types do not match (creditMin as string)
- Occupation.fromJson (shape matches model) > parses a valid occupation with your keys

### test/models/skill_bases_test.dart
- **Groups:** 1
- **Tests:** 2

**Group Names**
- SkillBases.baseForSpecialized (positional args)

**Test Names**
- SkillBases.baseForSpecialized (positional args) > Fighting bases
- SkillBases.baseForSpecialized (positional args) > Firearms bases

### test/models/skill_specialization_test.dart
- **Groups:** 0
- **Tests:** 3

**Test Names**
- displayName & parse round-trip for Fighting (Brawl)
- displayName & parse round-trip for Firearms (Rifle/Shotgun)
- families include Fighting

### test/viewmodels/character_viewmodel_create_from_spec_test.dart
- **Groups:** 0
- **Tests:** 1

**Test Names**
- createFromSpec populates Character with classic values and saves it

### test/viewmodels/character_viewmodel_test.dart
- **Groups:** 4
- **Tests:** 18

**Group Names**
- CharacterViewModel (with rules)
- CharacterViewModel specialization helpers
- CharacterViewModel stream + delete
- Specialization skills — classic rules

**Test Names**
- CharacterViewModel (with rules) > Classic: Cthulhu Mythos increase is blocked
- CharacterViewModel (with rules) > Classic: INT drives personal points; spend partially when exceeding pool
- CharacterViewModel (with rules) > Classic: attribute clamp to max 90
- CharacterViewModel (with rules) > Initial character data should be correct (seeded storage)
- CharacterViewModel (with rules) > Updating a skill should notify listeners
- CharacterViewModel (with rules) > Updating an attribute should notify listeners
- CharacterViewModel (with rules) > createCharacter generates id and binds classic rules
- CharacterViewModel (with rules) > finalizeCreation respects rules (not allowed while points remain)
- CharacterViewModel specialization helpers > addSpecializedSkill creates generic family if missing and adds spec with correct base
- CharacterViewModel specialization helpers > addSpecializedSkill is idempotent (no duplicates on same spec)
- CharacterViewModel specialization helpers > removeSkillByName removes only specialization, keeps generic family
- CharacterViewModel stream + delete > charactersStream emits only non-drafts and updates on changes
- CharacterViewModel stream + delete > deleteById removes from storage and clears current if it matches
- Specialization skills — classic rules > editing a generic template is forbidden in creation
- Specialization skills — classic rules > specialization spends from OCCUPATION pool when its category is occupational
- Specialization skills — classic rules > specialization spends from PERSONAL pool when its category is NOT occupational
- Specialization skills — classic rules > specialized OCCUPATION pick spends from OCCUPATION pool
- init loads recent if available (drafts allowed)

### test/viewmodels/create_character_view_model_test.dart
- **Groups:** 2
- **Tests:** 3

**Group Names**
- CreateCharacterViewModel - deterministic rolls & derived
- CreateCharacterViewModel - occupation & skills

**Test Names**
- CreateCharacterViewModel - deterministic rolls & derived > initial roll matches seeded RNG and derived stats are correct
- CreateCharacterViewModel - deterministic rolls & derived > teen age (17): Luck advantage applied and EDU reduced by 5
- CreateCharacterViewModel - occupation & skills > selectOccupation seeds mandatory; setOccupationSkills clamps and validates isReadyToCreate

### test/viewmodels/dice_rolling_viewmodel_test.dart
- **Groups:** 3
- **Tests:** 10

**Group Names**
- Ad-hoc multi-dice rolling — pool and totals
- DiceRollingViewModel — configuration & basics
- d100 rolls — bonus/penalty cancellation & bounds

**Test Names**
- Ad-hoc multi-dice rolling — pool and totals > 2×d6 + 1×d8 produces correct counts and ranges
- Ad-hoc multi-dice rolling — pool and totals > d100 inside ad-hoc uses bonus/penalty cancellation and stays in 1..100
- Ad-hoc multi-dice rolling — pool and totals > resetResults clears cached results but not the pool
- Ad-hoc multi-dice rolling — pool and totals > rolling empty pool returns total 0 and no details
- DiceRollingViewModel — configuration & basics > add/remove/clear dice pool works
- DiceRollingViewModel — configuration & basics > bonus/penalty clamped to [0, 10]
- DiceRollingViewModel — configuration & basics > initial state is adHoc with empty pool, zero bonus/penalty
- d100 rolls — bonus/penalty cancellation & bounds > bonus and penalty cancel each other for d100
- d100 rolls — bonus/penalty cancellation & bounds > plain d100 roll returns 1..100
- d100 rolls — bonus/penalty cancellation & bounds > skill context can be set and used in skillD100 mode

