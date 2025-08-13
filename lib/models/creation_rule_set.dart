import 'package:meta/meta.dart' show protected;
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/classic_creation_rule_set.dart';

enum ChangeTarget { attribute, skill }

class CreationChange {
  final ChangeTarget target;
  final String name;
  final int newBase; // absolute target value
  const CreationChange(this.target, this.name, this.newBase);
  const CreationChange.attribute(String name, int v) : this(ChangeTarget.attribute, name, v);
  const CreationChange.skill(String name, int v) : this(ChangeTarget.skill, name, v);
}

class RuleUpdateResult {
  final bool applied;
  final int? effectiveValue;      // value the VM should write if applied
  final List<String> messages;    // message keys
  const RuleUpdateResult({required this.applied, this.effectiveValue, this.messages = const []});
}

/// Generic point pool (total/spent/remaining).
class PointPool {
  int total;
  int spent;
  PointPool({required this.total, this.spent = 0});
  int get remaining => total - spent;

  /// Try to spend [want]. Returns granted amount (0..want).
  int spend(int want) {
    if (want <= 0) return 0;
    final grant = want <= remaining ? want : remaining;
    spent += grant;
    return grant;
  }

  /// Refund up to [pts]. Returns actually refunded.
  int refund(int pts) {
    if (pts <= 0) return 0;
    final r = pts <= spent ? pts : spent;
    spent -= r;
    return r;
  }
}

/// Mixin for skill pools (classic and point-buy share this).
mixin SkillPointPools on CreationRuleSet {
  final PointPool _occ = PointPool(total: 0);
  final PointPool _pers = PointPool(total: 0);

  void setSkillPoolTotals({required int edu, required int intel}) {
    _occ.total = edu * 4;
    _pers.total = intel * 2;
    // do not auto-trim spent; negative remaining blocks finalize until refunded
  }

  @override
  int? get occupationPointsRemaining => _occ.remaining;
  @override
  int? get personalPointsRemaining => _pers.remaining;

  /// Spend from chosen pool. Returns granted amount 0..need.
  int spendSkill(bool occupation, int need) =>
      occupation ? _occ.spend(need) : _pers.spend(need);

  /// Refund to pools. If [preferOccupation] true, refund occ first.
  void refundSkill(int pts, {bool preferOccupation = false}) {
    if (preferOccupation) {
      final r = _occ.refund(pts);
      _pers.refund(pts - r);
    } else {
      final r = _pers.refund(pts);
      _occ.refund(pts - r);
    }
  }

  bool get canFinalizeSkillPools =>
      _occ.remaining == 0 && _pers.remaining == 0;
}

/// One rules instance per draft. `update` is pure (no Character mutation).
abstract class CreationRuleSet {
  late Character character;

  String get id;
  String get label;

  // Optional UI properties (null => N/A). Mixins may override.
  int? get attributePointsRemaining => null;
  int? get occupationPointsRemaining => null;
  int? get personalPointsRemaining => null;
  bool get canFinalize => true;

  void bind(Character c) => character = c;
  void onEnter() {}
  void onExit() {}

  /// Initialize the already-created [character] with rule defaults.
  /// Default only sets provided fields; concrete rules may roll, seed pools, etc.
  void initialize({String? sheetName, String? name, String? occupation}) {
    if (sheetName != null) character.sheetName = sheetName;
    if (name != null) character.name = name;
    if (occupation != null) character.occupation = occupation;
  }

  /// Decide an edit. Must NOT mutate [character].
  RuleUpdateResult update(CreationChange change) =>
      RuleUpdateResult(applied: true, effectiveValue: change.newBase);

  void rollAttributes() {}
  void rollSkills() {}

  void finalizeDraft() {
    character.sheetStatus = SheetStatus.active;
  }

  @protected
  void ensureAttr(String n) {
    if (!character.attributes.any((a) => a.name == n)) {
      character.attributes.add(Attribute(name: n, base: 0));
    }
  }

  @protected
  void ensureSkill(String name, int base) {
    if (!character.skills.any((s) => s.name == name)) {
      character.skills.add(Skill(name: name, base: base));
    }
  }

  @protected
  int attr(String name) =>
      character.attributes.firstWhere((a) => a.name == name, orElse: () => Attribute(name: name, base: 0)).base;

  @protected
  int skill(String name) =>
      character.skills.firstWhere((s) => s.name == name, orElse: () => Skill(name: name, base: 0)).base;

  @protected
  void seedClassicSkills() {
    final dex = attr('Dexterity');
    final edu = attr('Education');

    // Fixed-base skills (classic 7e, 1920s-friendly)
    const fixed = <String, int>{
      'Accounting': 5,
      'Anthropology': 1,
      'Appraise': 5,
      'Archaeology': 1,
      'Art/Craft (Any)': 5,
      'Charm': 15,
      'Climb': 20,
      'Credit Rating': 0,
      'Cthulhu Mythos': 0, // special: cannot be increased with normal points
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

    for (final e in fixed.entries) {
      ensureSkill(e.key, e.value);
    }

    // Dynamic-base skills
    ensureSkill('Dodge', (dex / 2).floor()); // base = DEX/2 (x5 scale)
    ensureSkill('Language (Own)', edu); // base = EDU (x5 scale)
  }
}

abstract class CreationRules {
  static CreationRuleSet forStatus(SheetStatus status) {
    switch (status) {
      case SheetStatus.draft_classic:
        return ClassicCreationRuleSet();
      case SheetStatus.draft_points:
      case SheetStatus.draft_free:
        throw UnimplementedError('Rule set for $status not implemented yet.');
      default:
        throw StateError('forStatus called for non-draft status: $status');
    }
  }
}
