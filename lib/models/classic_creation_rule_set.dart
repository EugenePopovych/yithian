import 'dart:math';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/models/credit_rating_range.dart';

class ClassicCreationRuleSet extends CreationRuleSet with SkillPointPools {
  ClassicCreationRuleSet({bool Function(String skillName)? isOccupationSkill})
      : _isOcc = isOccupationSkill;

  @override String get id => 'classic';
  @override String get label => 'Classic (Rolled)';

  Set<String>? _chosenOcc;
  CreditRatingRange? _crRange;

  @override
  void seedOccupationSkills(Set<String> skills) {
    _chosenOcc = skills.map((s) => s.toLowerCase()).toSet();
  }

  @override
  bool isOccupationSkill(String name) => _isOccupation(name);

  @override
  CreditRatingRange? get creditRatingRange => _crRange;

  // Attribute families
  static const _threeD6 = <String>{'Strength','Constitution','Dexterity','Appearance','Power'};
  static const _twoD6p6 = <String>{'Size','Intelligence','Education'};
  static const _min3d6x5 = 15, _max3d6x5 = 90;
  static const _min2d6p6x5 = 40, _max2d6p6x5 = 90;

  final bool Function(String skillName)? _isOcc;

  bool _isOccupation(String skill) {
    final l = skill.toLowerCase();
    if (l == 'credit rating') return true; 
    if (_chosenOcc != null && _chosenOcc!.contains(l)) return true;
    return _isOcc?.call(skill) ?? false;
  }

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

    int baseFor(String name) {
      if (name == 'Dodge') return (dex / 2).floor();
      if (name == 'Language (Own)') return edu;
      return fixed[name] ?? 0; // unknown/custom → assume 0
    }

    for (final s in character.skills) {
      final delta = s.base - baseFor(s.name);
      if (delta > 0) {
        final isOcc = _isOccupation(s.name);
        // Spend against the appropriate pool to rebuild remaining values.
        spendSkill(isOcc, delta);
      }
    }
  }

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

    if (lname == 'cthulhu mythos') {
      final cur = skill(change.name);
      if (change.newBase <= cur) {
        refundSkill(cur - change.newBase, preferOccupation: false);
        return RuleUpdateResult(applied: true, effectiveValue: change.newBase);
      }
      return const RuleUpdateResult(applied: false, messages: ['forbidden_cthulhu_mythos']);
    }

    final cur = skill(change.name);
    var target = change.newBase;

    if (target == cur) {
      return RuleUpdateResult(applied: true, effectiveValue: target);
    }

    if (target < cur) {
      refundSkill(cur - target, preferOccupation: _isOccupation(change.name));
      return RuleUpdateResult(applied: true, effectiveValue: target);
    }

    // Increase: spend from the appropriate pool.
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
    _crRange = range;
  }

  @override
  bool get canFinalize => canFinalizeSkillPools;
}
