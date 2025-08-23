// lib/rules/classic_rules.dart
import 'dart:math';

/// Attribute keys (match your VM / sheet keys).
class AttrKey {
  static const str = 'STR';
  static const con = 'CON';
  static const dex = 'DEX';
  static const app = 'APP';
  static const intg = 'INT';
  static const pow = 'POW';
  static const siz = 'SIZ';
  static const edu = 'EDU';

  static const all = <String>[str, con, dex, app, intg, pow, siz, edu];
}

/// Damage Bonus / Build pair.
class DbBuild {
  final String db;   // "-2", "-1", "0", "+1D4", "+1D6", "+2D6", ...
  final int build;   // -2..+?
  const DbBuild(this.db, this.build);
}

/// ===== Rolls (3d6×5, (2d6+6)×5, teen Luck advantage) =====
class ClassicRolls {
  ClassicRolls([Random? rng]) : _rng = rng ?? Random.secure();
  final Random _rng;

  int d6() => _rng.nextInt(6) + 1;
  int d10() => _rng.nextInt(10) + 1;
  // ignore: non_constant_identifier_names
  int _3d6() => d6() + d6() + d6();
  // ignore: non_constant_identifier_names
  int _2d6() => d6() + d6();

  int roll3d6x5() => _3d6() * 5;
  int roll2d6p6x5() => ((_2d6() + 6) * 5);

  /// Luck: for ages 15–19 take the better of two 3d6×5 rolls.
  int rollLuck({required int age}) {
    final a = roll3d6x5();
    if (age >= 15 && age <= 19) {
      final b = roll3d6x5();
      return max(a, b);
    }
    return a;
  }
}

DbBuild calcDamageBonus(int str, int siz) {
  final totalBase = str + siz;
  if (totalBase <= 64) return const DbBuild('-2', -2);
  if (totalBase <= 84) return const DbBuild('-1', -1);
  if (totalBase <= 124) return const DbBuild('0', 0);
  if (totalBase <= 164) return const DbBuild('+1D4', 1);
  if (totalBase <= 204) return const DbBuild('+1D6', 2);
  return const DbBuild('+2D6', 3);
}

/// ===== Derived stats =====
int calcHP(int con, int siz) => ((con + siz) / 10).floor();
int calcMP(int pow) => (pow / 5).floor();
int calcSanity(int pow) => pow.clamp(0, 99);

int calcMove({
  required int str,
  required int dex,
  required int siz,
  required int age,
}) {
  final strBase = (str / 5).floor();
  final dexBase = (dex / 5).floor();
  final sizBase = (siz / 5).floor();

  int move;
  if (dexBase < sizBase && strBase < sizBase) {
    move = 7;
  } else if (dexBase > sizBase && strBase > sizBase) {
    move = 9;
  } else {
    move = 8;
  }

  if (age >= 40 && age <= 49) {
    move -= 1;
  } else if (age >= 50 && age <= 59) {
    move -= 2;
  } else if (age >= 60) {
    move -= 3;
  }

  return max(1, min(12, move));
}

/// ===== Age adjustments (basic scope per your plan) =====

/// How many EDU improvement checks by age bracket (basic).
int eduChecksForAge(int age) {
  if (age <= 19) return 0;
  if (age <= 39) return 0;
  if (age <= 49) return 1;
  if (age <= 59) return 2;
  if (age <= 69) return 3;
  if (age <= 79) return 4;
  return 4;
}

/// Apply minimal age rules to attributes map:
/// - If teen (15–19): reduce EDU by 5 (floor to 5).
/// - Apply EDU improvement checks: +1d10 per check.
/// Returns a new map (does not mutate [attrs]).
Map<String, int> applyAgeToAttributes(
  Map<String, int> attrs, {
  required int age,
  Random? rng,
}) {
  final r = rng ?? Random.secure();
  final next = Map<String, int>.from(attrs);

  if (age >= 15 && age <= 19) {
    next[AttrKey.edu] = max(5, (next[AttrKey.edu] ?? 0) - 5);
  }
  final checks = eduChecksForAge(age);
  for (var i = 0; i < checks; i++) {
    next[AttrKey.edu] = min(99, (next[AttrKey.edu] ?? 0) + (r.nextInt(10) + 1));
  }
  return next;
}

/// ===== Skill bases (CoC 7e core) =====
/// These are *base* values before training/occupation.
/// Dynamic bases: Dodge = DEX/2, Language (Own) = EDU, Credit Rating = 0 (set by occupation later).
const Map<String, int> kStaticSkillBases = {
  'Accounting': 5,
  'Anthropology': 1,
  'Appraise': 5,
  'Archaeology': 1,
  'Art/Craft': 5,
  'Charm': 15,
  'Climb': 20,
  'Credit Rating': 0,
  'Cthulhu Mythos': 0,
  'Disguise': 5,
  'Drive Auto': 20,
  'Electrical Repair': 10,
  'Fast Talk': 5,
  'Fighting (Brawl)': 25,
  'First Aid': 30,
  'History': 5,
  'Intimidate': 15,
  'Jump': 20,
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
  'Pilot': 1, // generic; specializations are (X)
  'Psychology': 10,
  'Ride': 5,
  'Science': 1, // generic; specializations are (X)
  'Sleight of Hand': 10,
  'Spot Hidden': 25,
  'Stealth': 20,
  'Survival': 10,
  'Swim': 20,
  'Throw': 20,
  'Track': 10,
  'Firearms (Handgun)': 20,
  'Firearms (Rifle/Shotgun)': 25,
  'Artillery': 1,
};

/// Build full base skills including dynamic ones.
/// Returns a new map of skill -> base%.
Map<String, int> buildBaseSkills(Map<String, int> attrs) {
  final dex = attrs[AttrKey.dex] ?? 0;
  final edu = attrs[AttrKey.edu] ?? 0;

  final map = <String, int>{};
  map.addAll(kStaticSkillBases);
  map['Dodge'] = (dex / 2).floor();
  map['Language (Own)'] = edu;
  return map;
}
