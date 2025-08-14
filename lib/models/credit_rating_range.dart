class CreditRatingRange {
  final int min;
  final int max;

  const CreditRatingRange({required this.min, required this.max});

  @override
  String toString() => '$min–$max';
}
