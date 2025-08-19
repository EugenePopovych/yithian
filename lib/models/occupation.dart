class Occupation {
  final String id;
  final String name;

  /// Credit Rating range
  final int creditMin;
  final int creditMax;

  /// How many skills in total must be chosen (including mandatory).
  final int selectCount;

  /// Must be part of the occupation set (preselected & non-removable in UI).
  final List<String> mandatorySkills;

  /// Pool to choose additional occupation skills from.
  final List<String> skillPool;

  const Occupation({
    required this.id,
    required this.name,
    required this.creditMin,
    required this.creditMax,
    required this.selectCount,
    this.mandatorySkills = const [],
    this.skillPool = const [],
  });

  factory Occupation.fromJson(Map<String, dynamic> j) {
    return Occupation(
      id: j['id'] as String,
      name: j['name'] as String,
      creditMin: j['creditMin'] as int,
      creditMax: j['creditMax'] as int,
      selectCount: j['selectCount'] as int,
      mandatorySkills: (j['mandatorySkills'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      skillPool: (j['skillPool'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'creditMin': creditMin,
        'creditMax': creditMax,
        'selectCount': selectCount,
        'mandatorySkills': mandatorySkills,
        'skillPool': skillPool,
      };

  @override
  String toString() =>
      'Occupation($name, CR:$creditMin–$creditMax, select:$selectCount, mandatory:${mandatorySkills.length}, pool:${skillPool.length})';
}
