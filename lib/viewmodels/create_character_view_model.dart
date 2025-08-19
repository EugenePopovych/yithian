import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:coc_sheet/models/occupation.dart';

// Use the shared, single-source-of-truth classic helpers.
import 'package:coc_sheet/models/classic_rules.dart'
    show
        ClassicRolls,
        AttrKey,
        calcHP,
        calcMP,
        calcSanity,
        calcMove,
        calcDamageBonus;

/// Damage Bonus representation for simple UI display.
class DamageBonus {
  final String db;   // e.g., "-2", "-1", "0", "+1D4", "+1D6", "+2D6"
  final int build;   // numeric build (-2..+?)
  const DamageBonus(this.db, this.build);
}

class CreateCharacterViewModel extends ChangeNotifier {
  CreateCharacterViewModel({Random? rng})
      : _rng = rng ?? Random.secure(),
        _rolls = ClassicRolls(rng ?? Random.secure()) {
    _resetState();
  }

  // ---------- Core transient state ----------
  final Random _rng;
  final ClassicRolls _rolls;

  String _name = '';
  int _age = 20;

  /// Primary attributes as %-scaled values (5× roll).
  final Map<String, int> _attrs = {
    for (final k in AttrKey.all) k: 0,
  };

  /// Luck as a %-scaled value.
  int _luck = 0;

  /// Derived stats
  int _hp = 0;
  int _mp = 0;
  int _sanity = 0;
  int _move = 0;
  DamageBonus _db = const DamageBonus('0', 0);

  /// Classic skill point pools (common baseline):
  /// - Occupation: EDU * 4
  /// - Personal: INT * 2
  int _occPoints = 0;
  int _personalPoints = 0;

  /// Occupation selection & skills
  Occupation? _occupation;
  final Set<String> _selectedSkills = <String>{}; // includes mandatory

  // ---------- Public getters ----------
  String get name => _name;
  int get age => _age;

  Map<String, int> get attributes => Map.unmodifiable(_attrs);
  int get luck => _luck;

  int get hp => _hp;
  int get mp => _mp;
  int get sanity => _sanity;
  int get move => _move;
  DamageBonus get damageBonus => _db;

  int get occupationPoints => _occPoints;
  int get personalPoints => _personalPoints;

  Occupation? get occupation => _occupation;
  Set<String> get selectedSkills => Set.unmodifiable(_selectedSkills);

  /// Validation gate for enabling "Create" button on the screen.
  bool get isReadyToCreate {
    if (_name.trim().isEmpty) return false;
    if (_occupation == null) return false;

    final occ = _occupation!;
    // Must include all mandatory skills:
    for (final m in occ.mandatorySkills) {
      if (!_selectedSkills.contains(m)) return false;
    }
    // Must have exactly selectCount in total:
    if (_selectedSkills.length != occ.selectCount) return false;

    // Optional: ensure all selected are from mandatory+pool
    final legal = {...occ.mandatorySkills, ...occ.skillPool};
    if (!_selectedSkills.every(legal.contains)) return false;

    return true;
  }

  // ---------- Commands (called by UI) ----------

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setAge(int value) {
    _age = value.clamp(15, 99);
    _applyAgeAdjustments(); // EDU improvements + teen Luck rule
    _recompute();
    notifyListeners();
  }

  /// Full initial roll (classic):
  /// STR/CON/DEX/APP/POW = 3d6×5; SIZ/INT/EDU = (2d6+6)×5; Luck = 3d6×5 (teen rule handled in _applyAgeAdjustments)
  void rollAll() {
    _attrs[AttrKey.str] = _rolls.roll3d6x5();
    _attrs[AttrKey.con] = _rolls.roll3d6x5();
    _attrs[AttrKey.dex] = _rolls.roll3d6x5();
    _attrs[AttrKey.app] = _rolls.roll3d6x5();
    _attrs[AttrKey.pow] = _rolls.roll3d6x5();
    _attrs[AttrKey.siz] = _rolls.roll2d6p6x5();
    _attrs[AttrKey.intg] = _rolls.roll2d6p6x5();
    _attrs[AttrKey.edu] = _rolls.roll2d6p6x5();

    // Luck base roll (teen rule applied in _applyAgeAdjustments)
    _luck = _rolls.roll3d6x5();

    // Re-apply current age effects (e.g., EDU improvements, teen luck)
    _applyAgeAdjustments();
    _recompute();
    notifyListeners();
  }

  /// Shallow reroll of primary attributes (keeps name/age/occupation choices)
  void rerollAttributes() => rollAll();

  /// Select or change occupation. Resets skill picks to mandatory.
  void selectOccupation(Occupation? occ) {
    _occupation = occ;
    _selectedSkills
      ..clear()
      ..addAll(occ?.mandatorySkills ?? const <String>[]);
    notifyListeners();
  }

  /// Set additional occupation skills (UI supplies the *full* set).
  /// Mandatory skills are enforced (kept) and final count is clamped to selectCount.
  void setOccupationSkills(Set<String> fullSelection) {
    if (_occupation == null) {
      return;
    }
    final occ = _occupation!;

    final legal = {...occ.mandatorySkills, ...occ.skillPool};
    final sanitized = fullSelection.where(legal.contains).toSet();

    // Ensure mandatory are present
    sanitized.addAll(occ.mandatorySkills);

    // Clamp to selectCount by removing overflow from non-mandatory
    if (sanitized.length > occ.selectCount) {
      final overflow = sanitized.length - occ.selectCount;
      // Remove arbitrary (but stable) extra skills from non-mandatory pool
      final extras = sanitized
          .where((s) => !occ.mandatorySkills.contains(s))
          .toList()
        ..sort(); // stable order for predictability
      for (var i = 0; i < overflow && i < extras.length; i++) {
        sanitized.remove(extras[i]);
      }
    }

    _selectedSkills
      ..clear()
      ..addAll(sanitized);
    notifyListeners();
  }

  // ---------- Internals ----------

  void _resetState() {
    _name = '';
    _age = 20;

    for (final k in AttrKey.all) {
      _attrs[k] = 0;
    }

    _luck = 0;

    _hp = 0;
    _mp = 0;
    _sanity = 0;
    _move = 0;
    _db = const DamageBonus('0', 0);

    _occPoints = 0;
    _personalPoints = 0;

    _occupation = null;
    _selectedSkills.clear();

    // Roll once so UI shows values immediately
    rollAll();
  }

  void _recompute() {
    // Derived (use shared helpers)
    _hp = calcHP(_attrs[AttrKey.con]!, _attrs[AttrKey.siz]!);
    _mp = calcMP(_attrs[AttrKey.pow]!);
    _sanity = calcSanity(_attrs[AttrKey.pow]!);

    _move = calcMove(
      str: _attrs[AttrKey.str]!,
      dex: _attrs[AttrKey.dex]!,
      siz: _attrs[AttrKey.siz]!,
      age: _age,
    );

    final dbb = calcDamageBonus(_attrs[AttrKey.str]!, _attrs[AttrKey.siz]!);
    _db = DamageBonus(dbb.db, dbb.build);

    // Pools
    _occPoints = _attrs[AttrKey.edu]! * 4;
    _personalPoints = _attrs[AttrKey.intg]! * 2;
  }

  // ----- Age adjustments (scoped) -----
  void _applyAgeAdjustments() {
    // Teen rule (15–19): Luck advantage + EDU −5
    if (_age >= 15 && _age <= 19) {
      final a = _rolls.roll3d6x5();
      final b = _rolls.roll3d6x5();
      _luck = max(a, b);
      _attrs[AttrKey.edu] = max(5, _attrs[AttrKey.edu]! - 5);
    }

    // EDU improvement checks per bracket (basic scope, no penalties):
    final eduChecks = _eduChecksForAge(_age);
    for (var i = 0; i < eduChecks; i++) {
      // 1d10 via _rng (we don't need full ClassicRolls for a flat d10)
      _attrs[AttrKey.edu] = min(99, _attrs[AttrKey.edu]! + (_rng.nextInt(10) + 1));
    }

    // NOTE: STR/CON/DEX penalties at higher ages are omitted in this scoped pass.
  }

  int _eduChecksForAge(int age) {
    if (age <= 19) return 0;
    if (age <= 39) return 0;
    if (age <= 49) return 1;
    if (age <= 59) return 2;
    if (age <= 69) return 3;
    if (age <= 79) return 4;
    return 4;
  }
}
