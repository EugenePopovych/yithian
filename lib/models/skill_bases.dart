import 'skill_specialization.dart';

/// Centralized base values for generic families and specializations.
/// Adjust these according to your rule references.

class SkillBases {
  /// Generic (family-level) base values.
  /// These represent checks when the investigator has no specialization.
  static int baseForGeneric(String family) {
    switch (family) {
      case SkillSpecialization.familyArtCraft:
        return 5; // Art/Craft (X) default in 7e
      case SkillSpecialization.familyScience:
        return 1; // Science (X)
      case SkillSpecialization.familyLanguageOther:
        return 1; // Language (Other: X)
      case SkillSpecialization.familyPilot:
        return 1; // Pilot (X)
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
      case SkillSpecialization.familyFighting:
        // RAW: Fighting (Brawl) = 25, other Fighting weapons = 20
        final s = specialization.trim().toLowerCase();
        return (s == 'brawl') ? 25 : 20;
      default:
        return 1;
    }
  }

  /// Firearms base helper (already existed)
  static int _firearmsBase(String specialization) {
    final s = specialization.trim().toLowerCase();
    if (s == 'handguns') return 20;
    if (s == 'rifle/shotgun') return 25;
    // Default for other firearm types (SMG, etc.)
    return 20;
  }
}
