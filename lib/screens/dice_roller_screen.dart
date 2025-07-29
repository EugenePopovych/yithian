import 'dart:math';
import 'package:flutter/material.dart';

class DiceRollerScreen extends StatefulWidget {
  final String? skillName;
  final int? base;
  final int? hard;
  final int? extreme;

  const DiceRollerScreen({super.key, this.skillName, this.base, this.hard, this.extreme});

  @override
  State<DiceRollerScreen> createState() => _DiceRollerScreenState();
}

class _DiceRollerScreenState extends State<DiceRollerScreen> {
  int _bonusDice = 0;
  int _penaltyDice = 0;
  bool _hasRolled = false;
  int? _result;
  List<int> _tensDice = [];
  int? _unitsDie;
  int? _finalTens;
  String? _evaluationText;

  void _resetRoll() {
    setState(() {
      _hasRolled = false;
      _result = null;
      _tensDice = [];
      _unitsDie = null;
      _finalTens = null;
      _evaluationText = null;
    });
  }

  void _rollDice() {
    final rng = Random();
    int net = _bonusDice - _penaltyDice;

    // Always roll 1 units die
    int units = rng.nextInt(10); // 0..9
    // If units die is 0, treat as "10"
    int unitsDisplay = units == 0 ? 10 : units;
    // Roll all tens dice needed (base + abs(net))
    int diceCount = 1 + net.abs();
    List<int> tensDice = List.generate(diceCount, (_) => rng.nextInt(10) * 10); // 0, 10, ..., 90

    // Show all tens dice
    int chosenTens;
    if (net > 0) {
      // Bonus: choose the lowest tens
      chosenTens = tensDice.reduce(min);
    } else if (net < 0) {
      // Penalty: choose the highest tens
      chosenTens = tensDice.reduce(max);
    } else {
      // No bonus or penalty: only first tens die
      chosenTens = tensDice[0];
    }

    // Compute the final result
    int total = chosenTens + units;
    // Special case: 00 is 100 in CoC
    if (chosenTens == 0 && units == 0) total = 100;

    String? eval;
    if (_showThresholds()) {
      if (total <= widget!.extreme!) {
        eval = "Extreme Success";
      } else if (total <= widget!.hard!) {
        eval = "Hard Success";
      } else if (total <= widget!.base!) {
        eval = "Regular Success";
      } else {
        eval = "Failure";
      }
    }

    setState(() {
      _hasRolled = true;
      _tensDice = tensDice;
      _unitsDie = unitsDisplay;
      _finalTens = chosenTens;
      _result = total;
      _evaluationText = eval;
    });
  }

  void _adjustBonus(int delta) {
    setState(() {
      _bonusDice = (_bonusDice + delta).clamp(0, 3);
      _resetRoll();
    });
  }

  void _adjustPenalty(int delta) {
    setState(() {
      _penaltyDice = (_penaltyDice + delta).clamp(0, 3);
      _resetRoll();
    });
  }

  bool _showThresholds() =>
      widget.skillName != null &&
      widget.base != null &&
      widget.hard != null &&
      widget.extreme != null;

  @override
  Widget build(BuildContext context) {
    final hasSkill = _showThresholds();
    final netDice = _bonusDice - _penaltyDice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSkill) ...[
                Text(widget.skillName!, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Base: ${widget.base}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text('Hard: ${widget.hard}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Text('Extreme: ${widget.extreme}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bonusPenaltyControl(
                    label: "Bonus",
                    value: _bonusDice,
                    onAdd: () => _adjustBonus(1),
                    onRemove: () => _adjustBonus(-1),
                  ),
                  const SizedBox(width: 24),
                  _bonusPenaltyControl(
                    label: "Penalty",
                    value: _penaltyDice,
                    onAdd: () => _adjustPenalty(1),
                    onRemove: () => _adjustPenalty(-1),
                  ),
                ],
              ),
              if (netDice != 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    netDice > 0
                        ? 'Net: $netDice Bonus Dice'
                        : 'Net: ${-netDice} Penalty Dice',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _rollDice,
                child: const Text('ROLL'),
              ),
              const SizedBox(height: 24),
              if (_hasRolled) _buildResultArea(hasSkill: hasSkill, netDice: netDice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bonusPenaltyControl({
    required String label,
    required int value,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? onRemove : null,
            ),
            Text(value.toString(), style: const TextStyle(fontSize: 20)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: value < 3 ? onAdd : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultArea({required bool hasSkill, required int netDice}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Roll: ${_result ?? "-"}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tens Dice: [${_tensDice.map((d) => d.toString().padLeft(2, '0')).join(', ')}]'),
            const SizedBox(width: 12),
            Text('Units: ${_unitsDie ?? "-"}'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Final Dice Used: ${_finalTens?.toString().padLeft(2, '0') ?? "-"} (tens) + ${_unitsDie ?? "-"} (units)',
          style: TextStyle(color: Colors.grey[700]),
        ),
        if (hasSkill && _evaluationText != null) ...[
          const SizedBox(height: 14),
          Text(
            _evaluationText!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ],
    );
  }
}
