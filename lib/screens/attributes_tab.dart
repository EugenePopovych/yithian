import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coc_sheet/models/attribute.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/widgets/stat_row.dart';
import 'package:coc_sheet/screens/dice_roller_screen.dart';
import 'package:coc_sheet/widgets/creation_row.dart';

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
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    final character = viewModel.character;
    final screenWidth = MediaQuery.of(context).size.width;
    final columns = (screenWidth / 300).floor().clamp(2, 4);

    if (character == null) {
      return const Center(
        child: Text(
            'No character loaded.\nPlease create or select a character first.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draft-only creation panel for this tab (bordered)
          CreationRow.attributes(),

          _buildSection(
            "Health, Sanity, Magic Points",
            _buildHealthSanityLuck(viewModel,
                draft: character.sheetStatus.isDraft),
          ),
          const SizedBox(height: 16),
          _buildSection("Attributes", _buildAttributesGrid(viewModel, columns)),
          const SizedBox(height: 16),
          _buildSection("Derived", _buildDerived(viewModel)),
          const SizedBox(height: 16),
          _buildSection(
              "Status Effects", _buildStatusEffects(viewModel, columns)),
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

  Widget _buildHealthSanityLuck(CharacterViewModel viewModel,
      {bool draft = false}) {
    final c = viewModel.character!;
    int p(String v, int fb) => int.tryParse(v) ?? fb;

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: [
        _buildStatBox(
          "Health",
          c.currentHP,
          c.maxHP,
          (val) => viewModel.updateHealth(p(val, c.currentHP), c.maxHP),
          locked: draft,
        ),
        _buildStatBox(
          "Sanity",
          c.currentSanity,
          c.startingSanity,
          (val) => viewModel.updateSanity(
              p(val, c.currentSanity), c.startingSanity),
          locked: draft,
        ),
        _buildStatBox(
          "Magic",
          c.currentMP,
          c.startingMP,
          (val) =>
              viewModel.updateMagicPoints(p(val, c.currentMP), c.startingMP),
          locked: draft,
        ),
        // Luck stays editable
        _buildStatBox(
          "Luck",
          c.currentLuck,
          99,
          (val) => viewModel.updateLuck(p(val, c.currentLuck)),
        ),
      ],
    );
  }

  Widget _buildStatBox(
  String label,
  int current,
  int max,
  Function(String) onChanged, {
  bool locked = false,
  bool showMax = false, // default: hide the "/ max" text
}) {
  final controller = TextEditingController(text: current.toString());

  return SizedBox(
    width: 180,
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, textAlign: TextAlign.right),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !locked, // blocks focus & typing when locked
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              // lock icon inside the field (top-right)
              suffixIcon: locked
                  ? const Padding(
                      padding: EdgeInsets.only(top: 0, right: 6),
                      child: Tooltip(
                        message: 'Calculated during creation',
                        child: Icon(Icons.lock_outline, size: 16),
                      ),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            onChanged: (val) => onChanged(val),
            onTap: () => controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            ),
          ),
        ),
        if (showMax) ...[
          const SizedBox(width: 8),
          Text("/ $max"),
        ],
      ],
    ),
  );
}

  Widget _buildAttributesGrid(CharacterViewModel viewModel, int columns) {
    final character = viewModel.character!;
    const double rowWidth = 330.0;

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: character.attributes.map((attribute) {
        return SizedBox(
          width: rowWidth,
          child: _buildAttributeRow(attribute, viewModel),
        );
      }).toList(),
    );
  }

  Widget _buildStatusEffects(CharacterViewModel viewModel, int columns) {
    final character = viewModel.character!;
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
      width: 200,
      child: Row(
        children: [
          Expanded(
            child: Text(status["label"], textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
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
      controller: _controllers[attribute.name]!,
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

  Widget _buildDerived(CharacterViewModel vm) {
    Widget pill(String label, String value) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(width: 8),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );

    final move = vm.movementRate?.toString() ?? '—';
    final build = vm.buildValue?.toString() ?? '—';
    final db = vm.damageBonusText; // e.g., "-1d4", "0", "+1d6"

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        pill('Move', move),
        pill('Build', build),
        pill('Damage Bonus', db),
      ],
    );
  }
}
