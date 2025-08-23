import 'package:flutter/material.dart';

// ---- StatRow layout constants (exported) ----
// Total tile width is used by SkillsTab for column math.
const double kStatRowTileWidth = 366.0;

// Fixed label cell width when *no* delete is shown.
const double kStatRowLabelWidth = 150.0;

// Width of the delete slot (when present, it is placed BEFORE the label).
const double kStatRowDeleteWidth = 40.0;

// Width for Base/Hard/Extreme numeric cells.
const double kStatRowMetricWidth = 56.0;

// Horizontal gap between cells.
const double kStatRowCellGap = 8.0;

// Height of each StatRow (enough for up to 2 lines of label text).
const double kStatRowHeight = 64.0;

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
  final VoidCallback? onDelete;
  final bool showBorder;

  const StatRow({
    super.key,
    required this.name,
    required this.base,
    required this.hard,
    required this.extreme,
    required this.onTap,
    required this.controller,
    required this.onBaseChanged,
    required this.enabled,
    required this.locked,
    required this.occupation,
    this.onDelete, // Provide in draft only (hidden otherwise)
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEditable = enabled && !locked;
    final bool showDelete = onDelete != null;

    // When delete is visible (draft), reduce the label width by exactly the delete slot width,
    // so the total row width remains constant and numeric cells don't move.
    final double effectiveLabelWidth = showDelete
        ? (kStatRowLabelWidth - kStatRowDeleteWidth + kStatRowCellGap)
        : kStatRowLabelWidth;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: kStatRowHeight,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border:
                showBorder ? Border.all(color: Colors.black, width: 1) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!showDelete)
                const SizedBox(width: kStatRowCellGap),

              // DELETE (first) — only shown in draft (when onDelete != null).
              if (showDelete)
                SizedBox(
                  width: kStatRowDeleteWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remove',
                      // IMPORTANT: fire the callback directly; visibility is controlled by caller.
                      onPressed: onDelete,
                      splashRadius: 18,
                    ),
                  ),
                ),

              // LABEL (fixed width; shrinks when delete is visible so total stays constant)
              SizedBox(
                width: effectiveLabelWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Add a tiny top padding when the badge is present so it won't cover the text
                    Padding(
                      padding: EdgeInsets.only(top: occupation ? 12 : 0),
                      child: Text(
                        name,
                        // Wrap instead of ellipsis (keep short to avoid very tall rows)
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
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
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
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

              const SizedBox(width: kStatRowCellGap),

              // BASE (fixed width), with lock overlay
              SizedBox(
                width: kStatRowMetricWidth,
                child: Stack(
                  children: [
                    TextField(
                      controller: controller,
                      enabled: isEditable, // no focus/input if false
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: false,
                        contentPadding: EdgeInsets.zero,
                      ),
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
                          baseOffset: 0,
                          extentOffset: text.length,
                        );
                      },
                    ),
                    if (locked)
                      const Positioned(
                        right: 4,
                        top: 4,
                        child: Tooltip(
                          message: 'Calculated during creation',
                          child: Icon(Icons.lock_outline, size: 14),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: kStatRowCellGap),

              // HARD (fixed)
              SizedBox(
                width: kStatRowMetricWidth,
                child: Text(
                  hard.toString(),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(width: kStatRowCellGap),

              // EXTREME (fixed)
              SizedBox(
                width: kStatRowMetricWidth,
                child: Text(
                  extreme.toString(),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(width: kStatRowCellGap),
            ],
          ),
        ),
      ),
    );
  }
}
