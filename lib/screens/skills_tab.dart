import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';
import '../models/skill.dart';
import '../widgets/stat_row.dart';
import 'dice_roller_screen.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    final character = viewModel.character;
    final screenWidth = MediaQuery.of(context).size.width;

    if (character == null) {
      return const Center(
        child: Text('No character loaded.\nPlease create or select a character first.'),
      );
    }

    const double rowWidth = 346.0;
    final columnsCount = (screenWidth / (rowWidth + 16)).floor().clamp(2, 4);
    final sortedSkills = [...character.skills]..sort((a, b) => a.name.compareTo(b.name));

    // Split the sorted list into columns
    final rowsPerColumn = (sortedSkills.length / columnsCount).ceil();
    final columns = List.generate(columnsCount, (col) {
      final start = col * rowsPerColumn;
      final end = (start + rowsPerColumn).clamp(0, sortedSkills.length);
      final slice = sortedSkills.sublist(start, end);
      return slice;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Skills", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((columnSkills) {
              return Container(
                width: rowWidth,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: columnSkills
                      .map((skill) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: _buildSkillRow(skill, viewModel),
                          ))
                      .toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRow(Skill skill, CharacterViewModel viewModel) {
    _controllers.putIfAbsent(skill.name, () => TextEditingController(text: skill.base.toString()));

    return StatRow(
      name: skill.name,
      base: skill.base,
      hard: skill.hard,
      extreme: skill.extreme,
      controller: _controllers[skill.name]!,
      onBaseChanged: (value) => viewModel.updateSkill(skill.name, value),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiceRollerScreen(
              skillName: skill.name,
              base: skill.base,
              hard: skill.base ~/ 2,
              extreme: skill.base ~/ 5,
            ),
          ),
        );
      },
    );
  }
}
