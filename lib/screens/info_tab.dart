import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/widgets/creation_row.dart';


class InfoTab extends StatefulWidget {
  const InfoTab({super.key});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
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
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    if (character == null) {
      return const Center(
        child: Text(
            'No character loaded.\nPlease create or select a character first.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Draft-only creation row; becomes a no-op on active sheets
          CreationRow.info(),
          const SizedBox(height: 8),

          // Existing layout
          isWideScreen
              ? _buildWideLayout(viewModel)
              : _buildNarrowLayout(viewModel),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(CharacterViewModel viewModel) {
    final character = viewModel.character!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField("Name", character.name, (value) => viewModel.updateCharacterName(value)),
        _buildTextField("Age", character.age.toString(), (value) => viewModel.updateCharacterInfo(age: int.tryParse(value) ?? character.age)),
        _buildTextField("Pronouns", character.pronouns, (value) => viewModel.updateCharacterInfo(pronouns: value)),
        _buildTextField("Occupation", character.occupation, (value) => viewModel.updateCharacterInfo(occupation: value)),
        _buildTextField("Residence", character.residence, (value) => viewModel.updateCharacterInfo(residence: value)),
        _buildTextField("Birthplace", character.birthplace, (value) => viewModel.updateCharacterInfo(birthplace: value)),
      ],
    );
  }

  Widget _buildWideLayout(CharacterViewModel viewModel) {
    final character = viewModel.character!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Name", character.name, (value) => viewModel.updateCharacterName(value)),
              _buildTextField("Age", character.age.toString(), (value) => viewModel.updateCharacterInfo(age: int.tryParse(value) ?? character.age)),
              _buildTextField("Pronouns", character.pronouns, (value) => viewModel.updateCharacterInfo(pronouns: value)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Occupation", character.occupation, (value) => viewModel.updateCharacterInfo(occupation: value)),
              _buildTextField("Residence", character.residence, (value) => viewModel.updateCharacterInfo(residence: value)),
              _buildTextField("Birthplace", character.birthplace, (value) => viewModel.updateCharacterInfo(birthplace: value)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    _controllers.putIfAbsent(label, () => TextEditingController(text: value));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        controller: _controllers[label],
        onChanged: onChanged,
      ),
    );
  }
}
