import 'package:uuid/uuid.dart';

typedef SheetId = String;

abstract class SheetIdGenerator {
  SheetId newId();
}

class UuidSheetIdGenerator implements SheetIdGenerator {
  static const _uuid = Uuid();
  @override
  SheetId newId() => _uuid.v4();
}
