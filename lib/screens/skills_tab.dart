import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';
import '../models/skill.dart';

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
    final character = Provider.of<CharacterViewModel>(context).character;
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Skills", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...character.skills.map((skill) => _buildSkillRow(skill, viewModel)),
        ],
      ),
    );
  }

  Widget _buildSkillRow(Skill skill, CharacterViewModel viewModel) {
    _controllers.putIfAbsent(skill.name, () => TextEditingController(text: skill.base.toString()));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                // Future: Open dice roller screen
              },
              child: Row(
                children: [
                  const Icon(Icons.casino, size: 16),
                  const SizedBox(width: 8),
                  Text(skill.name),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(),
              controller: _controllers[skill.name],
              keyboardType: TextInputType.number,
              onChanged: (val) => viewModel.updateSkill(skill.name, int.tryParse(val) ?? skill.base),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Text((skill.base ~/ 2).toString(), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text((skill.base ~/ 5).toString(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
