import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/creation_update_event.dart';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/widgets/stat_row.dart';
import 'package:coc_sheet/widgets/creation_row.dart';
import 'package:coc_sheet/widgets/inline_creation_feedback.dart';
import 'package:coc_sheet/screens/dice_roller_screen.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  final Map<String, TextEditingController> _controllers = {};

  // Positioning relative to the whole StatRow (unchanged layout).
  // Keep the same right anchor…
  static const double _bubbleRightInset = 120; // px from row right edge

  // Lift the bubble *above* the TextField height by ~8px
  static const double _textFieldHeight = 36; // match your field height
  static const double _bubbleTopInset = -(_textFieldHeight + 8);

  // Name cell in StatRow: left padding = 8, name width = 130, icon size = 16
  static const double _crIconLeftInset = 122; // 8 + 130 - 16
  static const double _crIconTopInset  = -2;  // slightly above the text baseline

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
        child: Text(
          'No character loaded.\nPlease create or select a character first.',
        ),
      );
    }

    const double rowWidth = 346.0;
    final columnsCount = (screenWidth / (rowWidth + 16)).floor().clamp(2, 4);
    final sortedSkills = [...character.skills]
      ..sort((a, b) => a.name.compareTo(b.name));

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
          // Draft-only creation panel for Skills (shows pools + Finish)
          CreationRow.skills(),

          Text("Skills", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),

          // Rebuild the skills grid when the last creation update changes
          ValueListenableBuilder<CreationUpdateEvent?>(
            valueListenable: viewModel.lastCreationUpdate,
            builder: (context, event, _) {
              return Row(
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
                          .map(
                            (skill) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: _buildSkillRow(
                                skill,
                                viewModel,
                                draft: character.sheetStatus.isDraft,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRow(
    Skill skill,
    CharacterViewModel viewModel, {
    required bool draft,
  }) {
    // Ensure controller exists and reflects current model value
    _controllers.putIfAbsent(
      skill.name,
      () => TextEditingController(text: skill.base.toString()),
    );
    final ctl = _controllers[skill.name]!;
    final textShouldBe = skill.base.toString();
    if (ctl.text != textShouldBe) {
      ctl.text = textShouldBe;
      ctl.selection = TextSelection.fromPosition(
        TextPosition(offset: ctl.text.length),
      );
    }

    final isCalculated =
        isCalculatedDuringDraft(draft: draft, skillName: skill.name);

    // Occupation badge
    final bool isOcc = viewModel.isOccupationSkill(skill.name);

    // Inline feedback (error/partial) anchored to this row
    final evt = viewModel.lastCreationUpdate.value;
    final bool showFeedback = evt != null &&
        evt.target == ChangeTarget.skill &&
        evt.name == skill.name &&
        (!evt.applied || evt.codes.isNotEmpty);

    final String feedbackText = showFeedback
        ? (evt.friendlyMessages.isNotEmpty
            ? evt.friendlyMessages.first
            : (!evt.applied ? 'Change rejected.' : 'Applied with limits.'))
        : '';
    final bool isError = showFeedback && !evt.applied;
    final bool isWarn = showFeedback && evt.applied && evt.codes.isNotEmpty;

    if (showFeedback) {
      final currentEvt = evt;
      Timer(const Duration(seconds: 3), () {
        if (viewModel.lastCreationUpdate.value == currentEvt) {
          viewModel.lastCreationUpdate.value = null;
        }
      });
    }

    // Credit Rating tooltip (range), shown inline in the name cell
    final bool isCredit = skill.name.toLowerCase() == 'credit rating';
    final range = viewModel.creditRatingRange; // may be null

    return Stack(
      clipBehavior: Clip.none,
      children: [
        StatRow(
          name: skill.name,
          base: skill.base,
          hard: skill.hard,
          extreme: skill.extreme,
          controller: ctl,
          enabled: !isCalculated,
          locked: isCalculated,
          occupation: isOcc,
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
        ),

        // Per-row inline feedback bubble
        if (showFeedback)
          Positioned(
            right: _bubbleRightInset,
            top: _bubbleTopInset,
            child: IgnorePointer(
              ignoring: true,
              child: InlineCreationFeedback(
                message: feedbackText,
                isError: isError,
                isWarning: isWarn,
              ),
            ),
          ),

        // Credit Rating range tooltip (inside the 130px name cell, top-right)
        if (isCredit && range != null)
          Positioned(
            left: _crIconLeftInset,
            top: _crIconTopInset,
            child: Tooltip(
              message: 'Required range: ${range.min}–${range.max}',
              child: const Icon(Icons.info_outline, size: 16),
            ),
          ),
      ],
    );
  }
}

// Helper: which skills are calculated during creation (locked by rules)
bool isCalculatedDuringDraft({required bool draft, required String skillName}) {
  switch (skillName) {
    case 'Dodge':
    case 'Language (Own)':
      return draft;
    default:
      return false;
  }
}
