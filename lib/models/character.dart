import 'attribute.dart';
import 'skill.dart';

class Character {
  String name;
  List<Attribute> attributes;
  List<Skill> skills;

  Character({
    required this.name,
    required this.attributes,
    required this.skills,
  });

  void updateAttribute(String attributeName, int newValue) {
    for (var attribute in attributes) {
      if (attribute.name == attributeName) {
        attribute.base = newValue >= 0 ? newValue : 0;
        break;
      }
    }
  }

  void updateSkill(String skillName, int newValue) {
    for (var skill in skills) {
      if (skill.name == skillName) {
        skill.base = newValue >= 0 ? newValue : 0;
        break;
      }
    }
  }
}
