class Skill {
  /// Legacy display name. For specialized skills prefer [displayName].
  String name;

  int _base;

  /// Whether this skill can be upgraded by the user (creation or free mode).
  /// (Kept as in your current model; not persisted yet.)
  bool canUpgrade;

  /// Optional specialization support
  /// - For generic skills (e.g., "Spot Hidden"): both are null.
  /// - For specialized skills (e.g., Science (Biology)):
  ///     category = "Science", specialization = "Biology".
  String? category;
  String? specialization;

  bool isOccupation = false;

  Skill({
    required this.name,
    required int base,
    this.canUpgrade = false,
    this.category,
    this.specialization,
  }) : _base = base >= 0 ? base : 0;

  /// Base value (always clamped to >= 0).
  int get base => _base;
  set base(int value) => _base = value >= 0 ? value : 0;

  /// Derived thresholds
  int get hard => _base ~/ 2;
  int get extreme => _base ~/ 5;

  /// Convenience: true when both category and specialization are present.
  bool get isSpecialized => category != null && specialization != null;

  /// Canonical display: "Category (Specialization)" for specialized, otherwise [name].
  String get displayName =>
      isSpecialized ? '${category!} (${specialization!})' : name;
}
