import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coc_sheet/viewmodels/dice_rolling_viewmodel.dart';

class DiceRollerScreen extends StatelessWidget {
  final String? skillName;
  final int? base;
  final int? hard;
  final int? extreme;

  const DiceRollerScreen({
    super.key,
    this.skillName,
    this.base,
    this.hard,
    this.extreme,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DiceRollingViewModel>(
      create: (_) {
        final vm = DiceRollingViewModel();
        if (skillName != null && base != null && hard != null && extreme != null) {
          vm.setSkillContext(SkillContext(
            skillName: skillName!,
            target: base!,
            hard: hard!,
            extreme: extreme!,
          ));
          vm.setMode(DiceMode.skillD100);
        } else {
          // Default entry without a skill: show dice pad; user can choose either plain d100 or ad-hoc pool.
          vm.setMode(DiceMode.plainD100);
        }
        return vm;
      },
      child: const _DiceRollerBody(),
    );
  }
}

class _DiceRollerBody extends StatelessWidget {
  const _DiceRollerBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiceRollingViewModel>();
    final hasSkill = vm.hasSkillContext;

    final title = hasSkill
        ? 'Roll: ${vm.skillContext!.skillName}'
        : (vm.mode == DiceMode.adHoc ? 'Roll: Dice Pool' : 'Roll: d100');

    final showBonusPenalty = vm.mode == DiceMode.skillD100 ||
        vm.mode == DiceMode.plainD100 ||
        (vm.mode == DiceMode.adHoc && vm.dicePool.containsKey(DieType.d100));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hasSkill) _SkillThresholds(vm: vm),
                  if (showBonusPenalty) _BonusPenaltyRow(vm: vm),
                  if (showBonusPenalty) const SizedBox(height: 16),
                  if (!hasSkill) _DicePad(vm: vm),
                  if (vm.mode == DiceMode.adHoc) ...[
                    const SizedBox(height: 12),
                    _SelectedDiceRow(vm: vm),
                  ],
                  const SizedBox(height: 16),
                  _RollButton(vm: vm),
                  const SizedBox(height: 24),
                  _ResultArea(vm: vm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillThresholds extends StatelessWidget {
  final DiceRollingViewModel vm;
  const _SkillThresholds({required this.vm});

  @override
  Widget build(BuildContext context) {
    final sc = vm.skillContext!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sc.skillName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _ChipKV(label: 'Target', value: '${sc.target}%'),
            _ChipKV(label: 'Hard', value: '${sc.hard}%'),
            _ChipKV(label: 'Extreme', value: '${sc.extreme}%'),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ChipKV extends StatelessWidget {
  final String label;
  final String value;
  const _ChipKV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _BonusPenaltyRow extends StatelessWidget {
  final DiceRollingViewModel vm;
  const _BonusPenaltyRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _Stepper(
          label: 'Bonus dice',
          value: vm.bonusDice,
          onChanged: (v) => vm.setBonusDice(v),
        ),
        const SizedBox(width: 24),
        _Stepper(
          label: 'Penalty dice',
          value: vm.penaltyDice,
          onChanged: (v) => vm.setPenaltyDice(v),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          tooltip: 'Decrease',
        ),
        Text('$value'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(value + 1),
          tooltip: 'Increase',
        ),
      ],
    );
  }
}

/// Dice pad shown when no skill is provided.
/// - Tapping d100 switches to plain d100 mode (single-roll d100).
/// - Tapping other dice switches to adHoc mode and adds that die to the pool.
class _DicePad extends StatelessWidget {
  final DiceRollingViewModel vm;
  const _DicePad({required this.vm});

  @override
  Widget build(BuildContext context) {
    final buttons = <_DieButtonData>[
      _DieButtonData('d3', DieType.d3),
      _DieButtonData('d4', DieType.d4),
      _DieButtonData('d6', DieType.d6),
      _DieButtonData('d8', DieType.d8),
      _DieButtonData('d10', DieType.d10),
      _DieButtonData('d12', DieType.d12),
      _DieButtonData('d20', DieType.d20),
      _DieButtonData('d100', DieType.d100),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose dice:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: buttons.map((b) {
            return OutlinedButton(
              onPressed: () {
                if (b.type == DieType.d100) {
                  vm.setMode(DiceMode.plainD100);
                  vm.resetResults(); // clear last ad-hoc result if any
                } else {
                  if (vm.mode != DiceMode.adHoc) {
                    vm.clearDice();
                    vm.setMode(DiceMode.adHoc);
                  }
                  vm.addDie(b.type, 1);
                }
              },
              child: Text(b.label),
            );
          }).toList(),
        ),
        if (vm.mode == DiceMode.plainD100) ...[
          const SizedBox(height: 8),
          Text(
            'Plain d100 mode selected. Tap ROLL to roll a d100.',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
        if (vm.mode == DiceMode.adHoc) ...[
          const SizedBox(height: 8),
          Text(
            'Dice Pool mode selected. Add multiple dice, then tap ROLL.',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ],
    );
  }
}

class _DieButtonData {
  final String label;
  final DieType type;
  _DieButtonData(this.label, this.type);
}

/// Shows the currently selected dice in ad-hoc mode and allows +/- management.
class _SelectedDiceRow extends StatelessWidget {
  final DiceRollingViewModel vm;
  const _SelectedDiceRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    final entries = vm.dicePool.entries.toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));

    if (entries.isEmpty) {
      return Text('No dice in pool yet.', style: TextStyle(color: Colors.grey[700]));
    }

    String labelOf(DieType t) {
      switch (t) {
        case DieType.d3:
          return 'd3';
        case DieType.d4:
          return 'd4';
        case DieType.d6:
          return 'd6';
        case DieType.d8:
          return 'd8';
        case DieType.d10:
          return 'd10';
        case DieType.d12:
          return 'd12';
        case DieType.d20:
          return 'd20';
        case DieType.d100:
          return 'd100';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected Dice:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: entries.map((e) {
            final text = '${e.value}×${labelOf(e.key)}';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).chipTheme.backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(text),
                  const SizedBox(width: 6),
                  _MiniIconButton(
                    icon: Icons.remove,
                    tooltip: 'Remove one',
                    onPressed: () => vm.removeDie(e.key, 1),
                  ),
                  _MiniIconButton(
                    icon: Icons.add,
                    tooltip: 'Add one',
                    onPressed: () => vm.addDie(e.key, 1),
                  ),
                  _MiniIconButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Remove all',
                    onPressed: () => vm.removeDie(e.key, e.value),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: vm.clearDice,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
          ),
        ),
      ],
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  const _MiniIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _RollButton extends StatelessWidget {
  final DiceRollingViewModel vm;
  const _RollButton({required this.vm});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (vm.mode) {
      case DiceMode.skillD100:
        label = 'ROLL (d100 vs Skill)';
        break;
      case DiceMode.plainD100:
        label = 'ROLL (d100)';
        break;
      case DiceMode.adHoc:
        label = 'ROLL (Dice Pool)';
        break;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          switch (vm.mode) {
            case DiceMode.skillD100:
            case DiceMode.plainD100:
              vm.rollD100();
              break;
            case DiceMode.adHoc:
              vm.rollAdHoc();
              break;
          }
        },
        child: Text(label),
      ),
    );
  }
}

class _ResultArea extends StatelessWidget {
  final DiceRollingViewModel vm;
  const _ResultArea({required this.vm});

  @override
  Widget build(BuildContext context) {
    // Decide which result to show based on mode.
    if (vm.mode == DiceMode.adHoc) {
      final res = vm.lastAdHocResult;
      if (res == null) return const SizedBox.shrink();

      String labelOf(DieType t) {
        switch (t) {
          case DieType.d3:
            return 'd3';
          case DieType.d4:
            return 'd4';
          case DieType.d6:
            return 'd6';
          case DieType.d8:
            return 'd8';
          case DieType.d10:
            return 'd10';
          case DieType.d12:
            return 'd12';
          case DieType.d20:
            return 'd20';
          case DieType.d100:
            return 'd100';
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total: ${res.total}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ...res.details.map((d) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '${labelOf(d.type)} → ${d.rolls.join(", ")}  (subtotal: ${d.subtotal})',
              ),
            );
          }),
        ],
      );
    } else {
      final res = vm.lastD100Result;
      if (res == null) {
        return const SizedBox.shrink();
      }
      final br = res.breakdown;

      // Evaluation only with skill context.
      String? evaluation;
      if (vm.hasSkillContext) {
        final t = vm.skillContext!;
        if (br.value <= t.extreme) {
          evaluation = 'Extreme Success';
        } else if (br.value <= t.hard) {
          evaluation = 'Hard Success';
        } else if (br.value <= t.target) {
          evaluation = 'Regular Success';
        } else {
          evaluation = 'Failure';
        }
      }

      String tens(int d) => (d * 10 == 0) ? '00' : '${d * 10}';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Result: ${br.value}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('Ones die: ${br.onesDigit}'),
          const SizedBox(height: 4),
          Text('Tens candidates: ${br.tensCandidates.map(tens).join(", ")}'),
          const SizedBox(height: 4),
          Text('Chosen tens: ${tens(br.chosenTensDigit)}'),
          const SizedBox(height: 8),
          Text(
            'Net bonus: ${br.netBonusCount}, Net penalty: ${br.netPenaltyCount}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          if (evaluation != null) ...[
            const SizedBox(height: 14),
            Text(
              evaluation,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ],
      );
    }
  }
}
