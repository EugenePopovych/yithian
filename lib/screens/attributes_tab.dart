import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';
import '../models/attribute.dart';
import '../models/character.dart';
import '../widgets/stat_row.dart';
import 'dice_roller_screen.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final columns =
        (screenWidth / 300).floor().clamp(2, 4); // Adaptive column count

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection("Health, Sanity, Magic Points",
              _buildHealthSanityLuck(character, viewModel)),
          const SizedBox(height: 16),
          _buildSection("Attributes",
              _buildAttributesGrid(character, viewModel, columns)),
          const SizedBox(height: 16),
          _buildSection("Status Effects",
              _buildStatusEffects(character, viewModel, columns)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildHealthSanityLuck(
      Character character, CharacterViewModel viewModel) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        _buildStatBox(
            "Health",
            character.currentHP,
            character.maxHP,
            (val) => viewModel.updateHealth(
                int.tryParse(val) ?? character.currentHP, character.maxHP)),
        _buildStatBox(
            "Sanity",
            character.currentSanity,
            character.startingSanity,
            (val) => viewModel.updateSanity(
                int.tryParse(val) ?? character.currentSanity,
                character.startingSanity)),
        _buildStatBox(
            "Magic",
            character.currentMP,
            character.startingMP,
            (val) => viewModel.updateMagicPoints(
                int.tryParse(val) ?? character.currentMP,
                character.startingMP)),
        _buildStatBox(
            "Luck",
            character.currentLuck,
            99,
            (val) => viewModel
                .updateLuck(int.tryParse(val) ?? character.currentLuck)),
      ],
    );
  }

  Widget _buildStatBox(
      String label, int current, int max, Function(String) onChanged) {
    final controller = TextEditingController(text: current.toString());

    return SizedBox(
      width: 180, // Fixed width for each stat box
      child: Row(
        children: [
          SizedBox(
              width: 70,
              child:
                  Text(label, textAlign: TextAlign.right)), // Label on the left
          const SizedBox(width: 8), // Fixed spacing between label and field
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (val) => onChanged(val),
              onTap: () => controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length), // Keeps focus on edit
            ),
          ),
          const SizedBox(width: 8),
          Text("/ $max"),
        ],
      ),
    );
  }

  Widget _buildAttributesGrid(
      Character character, CharacterViewModel viewModel, int columns) {
    final attributes = character.attributes;
    const double rowWidth = 330.0; // Fixed width for each row

    return Wrap(
      spacing: 16.0, // Horizontal spacing between columns
      runSpacing: 8.0, // Vertical spacing between rows
      children: attributes.map((attribute) {
        return SizedBox(
          width: rowWidth, // Ensure each row has a fixed width
          child: _buildAttributeRow(attribute, viewModel),
        );
      }).toList(),
    );
  }

  Widget _buildStatusEffects(
      Character character, CharacterViewModel viewModel, int columns) {
    final statusEffects = [
      {
        "label": "Major Wound",
        "value": character.hasMajorWound,
        "key": "hasMajorWound"
      },
      {
        "label": "Indefinite Madness",
        "value": character.isIndefinitelyInsane,
        "key": "isIndefinitelyInsane"
      },
      {
        "label": "Temporary Madness",
        "value": character.isTemporarilyInsane,
        "key": "isTemporarilyInsane"
      },
      {
        "label": "Unconscious",
        "value": character.isUnconscious,
        "key": "isUnconscious"
      },
      {"label": "Dying", "value": character.isDying, "key": "isDying"},
    ];

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: statusEffects
          .map((status) => _buildStatusCheckbox(status, viewModel))
          .toList(),
    );
  }

  Widget _buildStatusCheckbox(
      Map<String, dynamic> status, CharacterViewModel viewModel) {
    return SizedBox(
      width: 200, // Fixed width for each checkbox container
      child: Row(
        children: [
          Expanded(
            child: Text(status["label"],
                textAlign: TextAlign.right), // Right-aligned label
          ),
          const SizedBox(width: 8), // Fixed spacing between checkbox and label
          Checkbox(
            value: status["value"],
            onChanged: (val) {
              switch (status["key"]) {
                case "hasMajorWound":
                  viewModel.updateStatus(hasMajorWound: val);
                  break;
                case "isIndefinitelyInsane":
                  viewModel.updateStatus(isIndefinitelyInsane: val);
                  break;
                case "isTemporarilyInsane":
                  viewModel.updateStatus(isTemporarilyInsane: val);
                  break;
                case "isUnconscious":
                  viewModel.updateStatus(isUnconscious: val);
                  break;
                case "isDying":
                  viewModel.updateStatus(isDying: val);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeRow(Attribute attribute, CharacterViewModel viewModel) {
    _controllers.putIfAbsent(attribute.name,
        () => TextEditingController(text: attribute.base.toString()));
    return StatRow(
      name: attribute.name,
      base: attribute.base,
      hard: attribute.hard,
      extreme: attribute.extreme,
      controller: _controllers[attribute.name]!, // manage controllers as before
      onBaseChanged: (value) =>
          viewModel.updateAttribute(attribute.name, value),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiceRollerScreen(
              skillName: attribute.name,
              base: attribute.base,
              hard: attribute.hard,
              extreme: attribute.extreme,
            ),
          ),
        );
      },
    );
  }
}
