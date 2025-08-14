import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String name;
  final int base;
  final int hard;
  final int extreme;
  final VoidCallback onTap;
  final TextEditingController controller;
  final ValueChanged<int> onBaseChanged;
  final bool enabled;
  final bool locked;
  final bool occupation;

  const StatRow({
    super.key,
    required this.name,
    required this.base,
    required this.hard,
    required this.extreme,
    required this.controller,
    required this.onBaseChanged,
    required this.onTap,
    this.enabled = true,
    this.locked = false,
    this.occupation = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEditable = enabled && !locked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),

            // Name cell (fixed 130). We stack the "Occ" pill without changing width.
            SizedBox(
              width: 130,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // add a tiny top padding when the badge is present so it won't cover the text
                  Padding(
                    padding: EdgeInsets.only(top: occupation ? 12 : 0),
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (occupation)
                    Positioned(
                      left: 0,
                      top: -2,
                      child: Tooltip(
                        message: 'Occupation skill',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Occ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Base value field (fixed 60), with lock inside top-right when locked
            SizedBox(
              width: 60,
              child: Stack(
                children: [
                  TextField(
                    controller: controller,
                    enabled: isEditable, // no focus/input if false
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {
                      if (!isEditable) return;
                      final newValue = int.tryParse(value);
                      if (newValue != null && newValue >= 0) {
                        onBaseChanged(newValue);
                      }
                    },
                    onTap: () {
                      if (!isEditable) return;
                      final text = controller.text;
                      controller.selection = TextSelection(
                          baseOffset: 0, extentOffset: text.length);
                    },
                  ),
                  if (locked)
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: Tooltip(
                        message: 'Calculated during creation',
                        child: Icon(Icons.lock_outline, size: 14),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(
              width: 60,
              child: Text(
                hard.toString(),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                extreme.toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
