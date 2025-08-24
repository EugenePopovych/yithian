import 'dart:math';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/models/credit_rating_range.dart';
import 'package:coc_sheet/models/skill.dart';

class ClassicCreationRuleSet extends CreationRuleSet with SkillPointPools {
  ClassicCreationRuleSet({bool Function(String skillName)? isOccupationSkill})
      : _isOcc = isOccupationSkill;

  @override String get id => 'classic';
  @override String get label => 'Classic (Rolled)';

  Set<String>? _chosenOcc; // lowercased strings of occupation skills as seeded

  // Attribute families
  static const _threeD6 = <String>{'Strength','Constitution','Dexterity','Appearance','Power'};
  static const _twoD6p6 = <String>{'Size','Intelligence','Education'};
  static const _min3d6x5 = 15, _max3d6x5 = 90;
  static const _min2d6p6x5 = 40, _max2d6p6x5 = 90;

  // Generic template skills that are LOCKED during creation
  static const _genericTemplates = <String>{
    'art/craft (any)',
    'science (any)',
    'survival (any)',
    'pilot (any)',
    'language (other)',
  };

  final bool Function(String skillName)? _isOcc;

  // ---------- Occupation handling (by category/template) ----------

  @override
  void seedOccupationSkills(Set<String> skills) {
    // Store lowercased to compare quickly and stably
    _chosenOcc = skills.map((s) => s.toLowerCase()).toSet();
  }

  @override
  bool isOccupationSkill(String name) => _isOccupation(name);

  /// Determine if a skill name (legacy or display) should use the occupation pool.
  /// Resolves specializations by their category → template.
  bool _isOccupation(String name) {
    if (name.toLowerCase() == 'credit rating') return true;

    final s = _findSkillByAnyName(name);
    if (s != null && s.isSpecialized) {
      final tmpl = _templateNameForCategory(s.category!);
      final ltmpl = tmpl.toLowerCase();
      if (_chosenOcc != null && _chosenOcc!.contains(ltmpl)) return true;
      return _isOcc?.call(tmpl) ?? false;
    }

    final key = name.toLowerCase(); // assume this is already the template or plain skill
    if (_chosenOcc != null && _chosenOcc!.contains(key)) return true;
    return _isOcc?.call(name) ?? false;
  }

  /// Map a category to its generic template name.
  /// Language -> "Language (Other)", others -> "<Cat> (Any)".
  String _templateNameForCategory(String category) {
    return category.toLowerCase() == 'language'
        ? 'Language (Other)'
        : '$category (Any)';
  }

  /// For a concrete [Skill], return the template name used to look up its base.
  String _templateForSkill(Skill s) {
    if (s.isSpecialized) {
      return _templateNameForCategory(s.category!);
    }
    return s.name;
  }

  Skill? _findSkillByAnyName(String q) {
    for (final s in character.skills) {
      if (s.name == q) return s;                 // legacy/internal name
      if (s.displayName == q) return s;          // UI display name
    }
    return null;
  }

  // ---------- Attribute helpers ----------

  int _clampAttr(String name, int v) {
    if (_threeD6.contains(name)) return v.clamp(_min3d6x5, _max3d6x5);
    if (_twoD6p6.contains(name)) return v.clamp(_min2d6p6x5, _max2d6p6x5);
    return v.clamp(0, 99);
  }

  @override
  void initialize({String? sheetName, String? name, String? occupation}) {
    super.initialize(sheetName: sheetName, name: name, occupation: occupation);

    for (final n in _threeD6) {
      ensureAttr(n);
    }
    for (final n in _twoD6p6) {
      ensureAttr(n);
    }
    rollAttributes();

    seedClassicSkills();
    setSkillPoolTotals(edu: attr('Education'), intel: attr('Intelligence'));
  }

  void _recalcDerivedFromAttributes() {
    final con = attr('Constitution');
    final siz = attr('Size');
    final pow = attr('Power');

    final hp = ((con + siz) / 10).floor();
    character.maxHP = hp;
    character.currentHP = hp;

    final mp = (pow / 5).floor();
    character.startingMP = mp;
    character.currentMP = mp;

    final san = pow.clamp(0, character.maxSanity);
    character.startingSanity = san;
    character.currentSanity = san;
  }

  @override
  void onEnter() {
    super.onEnter();

    setSkillPoolTotals(
      edu: attr('Education'),
      intel: attr('Intelligence'),
    );

    _replaySpentFromCharacter();
  }

  // ---------- Rebuild pools by diffing current skills vs bases ----------

  void _replaySpentFromCharacter() {
    final dex = attr('Dexterity');
    final edu = attr('Education');

    // Classic 7e fixed bases
    final fixed = <String, int>{
      'Accounting': 5,
      'Anthropology': 1,
      'Appraise': 5,
      'Archaeology': 1,
      'Art/Craft (Any)': 5,
      'Charm': 15,
      'Climb': 20,
      'Credit Rating': 0,
      'Cthulhu Mythos': 0,
      'Disguise': 5,
      'Drive Auto': 20,
      'Electrical Repair': 10,
      'Fast Talk': 5,
      'Fighting (Brawl)': 25,
      'Firearms (Handgun)': 20,
      'Firearms (Rifle/Shotgun)': 25,
      'First Aid': 30,
      'History': 5,
      'Intimidate': 15,
      'Jump': 20,
      'Language (Other)': 1,
      'Law': 5,
      'Library Use': 20,
      'Listen': 20,
      'Locksmith': 1,
      'Mechanical Repair': 10,
      'Medicine': 1,
      'Natural World': 10,
      'Navigate': 10,
      'Occult': 5,
      'Operate Heavy Machinery': 1,
      'Persuade': 10,
      'Pilot (Any)': 1,
      'Psychoanalysis': 1,
      'Psychology': 10,
      'Ride': 5,
      'Science (Any)': 1,
      'Sleight of Hand': 10,
      'Spot Hidden': 25,
      'Stealth': 20,
      'Survival (Any)': 10,
      'Swim': 20,
      'Throw': 20,
      'Track': 10,
    };

    int baseFor(Skill s) {
      final n = s.name;
      if (n == 'Dodge') return (dex / 2).floor();
      if (n == 'Language (Own)') return edu;
      final key = _templateForSkill(s);
      return fixed[key] ?? 0; // unknown/custom → assume 0
    }

    for (final s in character.skills) {
      final delta = s.base - baseFor(s);
      if (delta > 0) {
        // Spend against the appropriate pool to rebuild remaining values.
        spendSkill(s.isOccupation, delta);
      }
    }
  }

  // ---------- Edits during creation ----------

  @override
  RuleUpdateResult update(CreationChange change) {
    if (change.target == ChangeTarget.attribute) {
      final clamped = _clampAttr(change.name, change.newBase);
      // If EDU/INT changed, recompute pool totals against *effective* value.
      if (change.name == 'Education' || change.name == 'Intelligence') {
        final edu = change.name == 'Education' ? clamped : attr('Education');
        final intel = change.name == 'Intelligence' ? clamped : attr('Intelligence');
        setSkillPoolTotals(edu: edu, intel: intel);
      }
      return RuleUpdateResult(applied: true, effectiveValue: clamped);
    }

    // Skills: classic always uses pools.
    final lname = change.name.toLowerCase();

    // Calculated during creation: block edits
    if (lname == 'dodge' || lname == 'language (own)') {
      return const RuleUpdateResult(applied: false, messages: ['forbidden_calculated']);
    }

    // Lock generic template rows (categories)
    if (_genericTemplates.contains(lname)) {
      return const RuleUpdateResult(applied: false, messages: ['forbidden_generic_template']);
    }

    // Cthulhu Mythos special rule
    if (lname == 'cthulhu mythos') {
      final cur = _skillValueForEditName(change.name);
      if (change.newBase <= cur) {
        refundSkill(cur - change.newBase, preferOccupation: false);
        return RuleUpdateResult(applied: true, effectiveValue: change.newBase);
      }
      return const RuleUpdateResult(applied: false, messages: ['forbidden_cthulhu_mythos']);
    }

    final cur = _skillValueForEditName(change.name);
    var target = change.newBase;

    if (target == cur) {
      return RuleUpdateResult(applied: true, effectiveValue: target);
    }

    if (target < cur) {
      // Refund to pools; prefer the pool that was likely used (occupation vs personal)
      refundSkill(cur - target, preferOccupation: _isOccupation(change.name));
      return RuleUpdateResult(applied: true, effectiveValue: target);
    }

    // Increase: spend from the appropriate pool (resolve by category/template).
    final need = target - cur;
    final occ = _isOccupation(change.name);
    final grant = spendSkill(occ, need);
    if (grant <= 0) {
      return const RuleUpdateResult(applied: false, messages: ['no_points_remaining']);
    }

    final eff = cur + grant;
    return RuleUpdateResult(
      applied: true,
      effectiveValue: eff,
      messages: grant == need ? const [] : const ['partial_due_to_pool'],
    );
  }

  int _skillValueForEditName(String name) {
    final s = _findSkillByAnyName(name);
    if (s != null) return s.base;
    // Fallback to legacy lookup by exact name
    return skill(name);
  }

  // ---------- Attribute rolling ----------

  @override
  void rollAttributes() {
    final r = Random();
    int d6() => r.nextInt(6) + 1;
    int r3d6x5() => (d6() + d6() + d6()) * 5;
    int r2d6p6x5() => ((d6() + d6()) + 6) * 5;

    for (final n in _threeD6) {
      character.updateAttribute(n, r3d6x5());
    }
    for (final n in _twoD6p6) {
      character.updateAttribute(n, r2d6p6x5());
    }

    // Luck (CoC 7e): 3d6×5
    character.updateLuck(r3d6x5());

    // Derived stats depend on attributes
    _recalcDerivedFromAttributes();

    // Recompute skill point pools from EDU/INT
    setSkillPoolTotals(edu: attr('Education'), intel: attr('Intelligence'));
  }

  @override
  void seedCreditRatingRange(CreditRatingRange range) {
  }

  @override
  bool get canFinalize => canFinalizeSkillPools;
}
