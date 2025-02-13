import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';
import '../models/attribute.dart';

class AttributesTab extends StatefulWidget {
  const AttributesTab({super.key});

  @override
  State<AttributesTab> createState() => _AttributesTabState();
}

class _AttributesTabState extends State<AttributesTab> {
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
          Text("Attributes", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...character.attributes.map((attribute) => _buildAttributeRow(attribute, viewModel)),

          const SizedBox(height: 16),
          Text("Health & Sanity", style: Theme.of(context).textTheme.titleLarge),
          _buildNumberFields("HP", character.currentHP, character.maxHP, (current, max) => viewModel.updateHealth(current, max)),
          _buildNumberFields("Sanity", character.currentSanity, character.startingSanity, (current, starting) => viewModel.updateSanity(current, starting)),
          _buildNumberFields("Magic Points", character.currentMP, character.startingMP, (current, starting) => viewModel.updateMagicPoints(current, starting)),
          
          const SizedBox(height: 16),
          Text("Status Effects", style: Theme.of(context).textTheme.titleLarge),
          _buildStatusToggle("Major Wound", character.hasMajorWound, (value) => viewModel.updateStatus(hasMajorWound: value)),
          _buildStatusToggle("Indefinite Insanity", character.isIndefinitelyInsane, (value) => viewModel.updateStatus(isIndefinitelyInsane: value)),
          _buildStatusToggle("Temporary Insanity", character.isTemporarilyInsane, (value) => viewModel.updateStatus(isTemporarilyInsane: value)),
          _buildStatusToggle("Unconscious", character.isUnconscious, (value) => viewModel.updateStatus(isUnconscious: value)),
          _buildStatusToggle("Dying", character.isDying, (value) => viewModel.updateStatus(isDying: value)),
        ],
      ),
    );
  }

  Widget _buildAttributeRow(Attribute attribute, CharacterViewModel viewModel) {
    _controllers.putIfAbsent(attribute.name, () => TextEditingController(text: attribute.base.toString()));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(attribute.name)),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(),
              controller: _controllers[attribute.name],
              keyboardType: TextInputType.number,
              onChanged: (val) => viewModel.updateAttribute(attribute.name, int.tryParse(val) ?? attribute.base),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Text(attribute.hard.toString(), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(attribute.extreme.toString(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildNumberFields(String label, int current, int max, Function(int, int) onChanged) {
    return Row(
      children: [
        Expanded(child: _buildTextField("$label (Current)", current.toString(), (value) => onChanged(int.tryParse(value) ?? current, max))),
        const SizedBox(width: 8),
        Expanded(child: _buildTextField("$label (Max)", max.toString(), (value) => onChanged(current, int.tryParse(value) ?? max))),
      ],
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(labelText: label),
        controller: _controllers[label],
        keyboardType: TextInputType.number,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatusToggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}
