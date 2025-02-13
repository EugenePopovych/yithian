import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';

class BackgroundTab extends StatelessWidget {
  BackgroundTab({super.key});

  @override
  Widget build(BuildContext context) {
    final character = Provider.of<CharacterViewModel>(context).character;
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Background Information", style: Theme.of(context).textTheme.titleLarge),
          _buildTextField("Personal Description", character.personalDescription, (value) => viewModel.updateBackground(personalDescription: value)),
          _buildTextField("Ideology & Beliefs", character.ideologyAndBeliefs, (value) => viewModel.updateBackground(ideologyAndBeliefs: value)),
          _buildTextField("Significant People", character.significantPeople, (value) => viewModel.updateBackground(significantPeople: value)),
          _buildTextField("Meaningful Locations", character.meaningfulLocations, (value) => viewModel.updateBackground(meaningfulLocations: value)),
          _buildTextField("Treasured Possessions", character.treasuredPossessions, (value) => viewModel.updateBackground(treasuredPossessions: value)),
          _buildTextField("Traits & Mannerisms", character.traitsAndMannerisms, (value) => viewModel.updateBackground(traitsAndMannerisms: value)),
          _buildTextField("Injuries & Scars", character.injuriesAndScars, (value) => viewModel.updateBackground(injuriesAndScars: value)),
          _buildTextField("Phobias & Manias", character.phobiasAndManias, (value) => viewModel.updateBackground(phobiasAndManias: value)),
          _buildTextField("Arcane Tomes & Spells", character.arcaneTomesAndSpells, (value) => viewModel.updateBackground(arcaneTomesAndSpells: value)),
          _buildTextField("Encounters with Strange Entities", character.encountersWithEntities, (value) => viewModel.updateBackground(encountersWithEntities: value)),
          _buildTextField("Gear", character.gear, (value) => viewModel.updateBackground(gear: value)),
          _buildTextField("Wealth", character.wealth, (value) => viewModel.updateBackground(wealth: value)),
          _buildTextField("Notes", character.notes, (value) => viewModel.updateBackground(notes: value)),
        ],
      ),
    );
  }

  final _controllers = <String, TextEditingController>{};

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    _controllers.putIfAbsent(label, () => TextEditingController(text: value));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        controller: _controllers[label],
        onChanged: (val) {
          onChanged(val);
        },
        maxLines: null,
        keyboardType: TextInputType.multiline,
      ),
    );
  }

}
