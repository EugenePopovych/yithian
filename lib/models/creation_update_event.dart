import 'package:coc_sheet/models/creation_rule_set.dart';

/// Payload describing the outcome of a creation-time change (attribute/skill).
/// This wraps the existing [RuleUpdateResult] with the attempted target/value,
/// so the UI can show concise feedback and decide how to react.
class CreationUpdateEvent {
  final ChangeTarget target;      // attribute or skill
  final String name;              // e.g., "Dodge", "Strength"
  final int attemptedValue;       // the value the user tried to set
  final RuleUpdateResult result;  // applied/effective/messages
  final DateTime timestamp;

  CreationUpdateEvent({
    required this.target,
    required this.name,
    required this.attemptedValue,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get applied => result.applied;
  int? get effectiveValue => result.effectiveValue;
  List<String> get codes => result.messages;

  /// Convert known message codes to short, user-friendly texts for the UI.
  /// (Keep this mapping here so the ViewModel/UI stays dumb/simple.)
  List<String> get friendlyMessages => codes.map(_friendlyTextFor).toList();

  static String _friendlyTextFor(String code) {
    switch (code) {
      case 'no_points_remaining':
        return 'Not enough points.';
      case 'partial_due_to_pool':
        return 'Applied partially; pools exhausted.';
      case 'forbidden_cthulhu_mythos':
        return 'Cthulhu Mythos can’t be increased during creation.';
      case 'forbidden_calculated':
        return 'This value is calculated during creation.';
      // future-proof fallback
      default:
        return code.replaceAll('_', ' ');
    }
  }

  @override
  String toString() =>
      'CreationUpdateEvent(target:$target name:$name attempted:$attemptedValue '
      'applied:${result.applied} effective:${result.effectiveValue} codes:$codes)';
}
