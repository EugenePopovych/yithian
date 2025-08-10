/// Draft mode is encoded in status.
enum SheetStatus {
  active,
  archived,
  draft_classic,
  draft_points,
  draft_free,
}

extension SheetStatusX on SheetStatus {
  bool get isDraft =>
      this == SheetStatus.draft_classic ||
      this == SheetStatus.draft_points ||
      this == SheetStatus.draft_free;
}
