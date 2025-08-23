/// Draft mode is encoded in status.
enum SheetStatus {
  active,
  archived,
  draftClassic,
  draftPoints,
  draftFree,
}

extension SheetStatusX on SheetStatus {
  bool get isDraft =>
      this == SheetStatus.draftClassic ||
      this == SheetStatus.draftPoints ||
      this == SheetStatus.draftFree;
}
