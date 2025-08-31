class SkillSpecialization {
  /// Canonical specialization families supported in Classic CoC 7e.
  /// Add more as needed and keep in sync with [base] functions.
  static const familyArtCraft = 'Art/Craft';
  static const familyScience = 'Science';
  static const familyLanguageOther = 'Language (Other)';
  static const familyPilot = 'Pilot';
  static const familyFirearms = 'Firearms';
  static const String familyFighting = 'Fighting';

  static const List<String> families = [
    familyArtCraft,
    familyScience,
    familyLanguageOther,
    familyPilot,
    familyFirearms,
    familyFighting,
  ];

  /// Build canonical display name, e.g. "Science (Biology)".
  static String displayName(String category, String specialization) =>
      '$category ($specialization)';

  /// Returns (category, specialization) for specialized names.
  /// If [skillName] isn't in canonical "Category (Spec)" format, returns (null, null).
  static ({String? category, String? specialization}) parse(String skillName) {
    final open = skillName.indexOf('(');
    final close = skillName.endsWith(')') ? skillName.length - 1 : -1;
    if (open <= 0 || close <= open + 1) {
      return (category: null, specialization: null);
    }
    final cat = skillName.substring(0, open).trim();
    final spec = skillName.substring(open + 1, close).trim();
    if (cat.isEmpty || spec.isEmpty) {
      return (category: null, specialization: null);
    }
    return (category: cat, specialization: spec);
  }

  /// Returns true if [skillName] is a specialization under the given [family].
  /// e.g. isOfFamily("Science (Biology)", "Science") == true
  static bool isOfFamily(String skillName, String family) {
    final parsed = parse(skillName);
    return parsed.category == family && parsed.specialization != null;
  }

  /// Returns true if [skillName] is a generic family skill without specialization.
  /// e.g. isGenericFamily("Science") == true; isGenericFamily("Science (Biology)") == false
  static bool isGenericFamily(String skillName) {
    // Generic families are the raw family names
    return families.contains(skillName);
  }
}
