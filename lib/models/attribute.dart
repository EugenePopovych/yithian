class Attribute {
  String name;
  int _base;

  Attribute({required this.name, required int base}) : _base = base >= 0 ? base : 0;

  int get base => _base;
  set base(int value) => _base = value >= 0 ? value : 0;

  int get hard => _base ~/ 2;
  int get extreme => _base ~/ 5;
}
