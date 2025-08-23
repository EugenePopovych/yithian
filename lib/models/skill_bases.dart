import 'skill_specialization.dart';

/// Centralized base values for generic families and specializations.
/// Adjust these according to your rule references.

class SkillBases {
  /// Generic (family-level) base values.
  /// These represent checks when the investigator has no specialization.
  static int baseForGeneric(String family) {
    switch (family) {
      case SkillSpecialization.familyArtCraft:
        return 5;  // Art/Craft (X) default in 7e
      case SkillSpecialization.familyScience:
        return 1;  // Science (X)
      case SkillSpecialization.familyLanguageOther:
        return 1;  // Language (Other: X)
      case SkillSpecialization.familyPilot:
        return 1;  // Pilot (X)
      case SkillSpecialization.familyFirearms:
        // For a generic Firearms check (rare), keep conservative default.
        // Specific weapons below override via specialization.
        return 15;
      default:
        // For unknown families, be conservative.
        return 1;
    }
  }

  /// Specialized base values.
  /// Most families use a uniform default; Firearms differs by weapon type.
  static int baseForSpecialized(String family, String specialization) {
    switch (family) {
      case SkillSpecialization.familyArtCraft:
        return 5; // Art/Craft (Painting), (Sculpture)...
      case SkillSpecialization.familyScience:
        return 1; // Science (Biology), (Chemistry)...
      case SkillSpecialization.familyLanguageOther:
        return 1; // Language (Other: Latin), (Greek)...
      case SkillSpecialization.familyPilot:
        return 1; // Pilot (Airplane), (Boat)...
      case SkillSpecialization.familyFirearms:
        return _firearmsBase(specialization);
      default:
        return 1;
    }
  }

  /// Common Firearms bases (CoC 7e typical defaults).
  /// Tune as needed for your setting/edition.
  static int _firearmsBase(String spec) {
    final s = spec.toLowerCase().trim();
    if (s.contains('rifle') || s.contains('shotgun')) return 25;
    if (s.contains('handgun') || s.contains('pistol') || s.contains('revolver')) return 20;
    if (s.contains('smg') || s.contains('submachine')) return 15;
    if (s.contains('bow') || s.contains('crossbow')) return 15;
    // Fallback
    return 15;
  }
}
