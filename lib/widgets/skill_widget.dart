import 'package:flutter/material.dart';
import '../models/skill.dart';

class SkillWidget extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;

  const SkillWidget({super.key, required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("🎲 ${skill.name}:"),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: skill.base.toString()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int? newValue = int.tryParse(value);
                if (newValue != null && newValue >= 0) {
                  skill.base = newValue;
                }
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: skill.hard.toString()),
              readOnly: true,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: skill.extreme.toString()),
              readOnly: true,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
