import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/skill.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/creation_rule_set.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/widgets/stat_row.dart';
import 'package:coc_sheet/widgets/creation_row.dart';
import 'package:coc_sheet/screens/dice_roller_screen.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _Tile {
  final Widget child;
  final double weight; // approximate number of "rows" this tile costs
  const _Tile(this.child, this.weight);
}

class _SkillsTabState extends State<SkillsTab> {
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
    final vm = Provider.of<CharacterViewModel>(context, listen: true);
    final character = vm.character;

    if (character == null) {
      return const Center(
        child: Text(
          'No character loaded.\nPlease create or select a character first.',
        ),
      );
    }

    final draft = character.sheetStatus.isDraft;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draft-only creation panel for Skills (shows pools + Finish)
          CreationRow.skills(),

          const SizedBox(height: 12),

          // Layout with vertical fill ordering
          LayoutBuilder(
            builder: (context, constraints) {
              // Build the tile list first (groups for categories that have specs, solo rows otherwise)
              final tiles = _buildSkillTiles(context, vm, character, draft);

              // Determine number of columns based on available width and a comfortable minimum card width
              const gutter = 16.0;
              final total = constraints.maxWidth;

// Fit as many whole tiles as possible:  [tile][gutter][tile][gutter]...
// Use integer division to avoid rounding up and causing overflow.
              int columns = ((total + gutter) ~/ (kStatRowTileWidth + gutter));
              if (columns < 1) columns = 1;
              if (columns > 4) columns = 4; // optional sanity cap

              final columnsData = _splitTilesByWeight(tiles, columns);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(columns, (i) {
                  final colChildren = <Widget>[];
                  final colTiles = columnsData[i];
                  for (var j = 0; j < colTiles.length; j++) {
                    if (j > 0) colChildren.add(const SizedBox(height: 12));
                    // Fix width per tile and avoid stretch so trailing icons won't overflow/overlap
                    colChildren.add(
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: kStatRowTileWidth,
                          child: colTiles[j].child,
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: i == columns - 1 ? 0 : 16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // <-- not stretch
                        children: colChildren,
                      ),
                    ),
                  );

                }),
              );
            },
          ),
        ],
      ),
    );
  }

  List<_Tile> _buildSkillTiles(
    BuildContext context,
    CharacterViewModel vm,
    Character c,
    bool draft,
  ) {
    // Families that support specializations — these render as grouped tiles.
    const specFamilies = {
      'Language',
      'Science',
      'Art/Craft',
      'Pilot',
      'Survival'
    };

    final all = List<Skill>.from(c.skills);

    bool isLegacyAnyGeneric(String name, String category) {
      // e.g., "Science (Any)"
      final m = RegExp(r'^(.*)\s*\(\s*Any\s*\)$').firstMatch(name);
      if (m == null) return false;
      final cat = m.group(1)!.trim();
      return cat == category;
    }

    Skill? findGenericForCategory(String category) {
      // 1) Plain family name used as generic (e.g., "Science")
      final plain = firstWhereOrNull(
        all,
        (s) => !s.isSpecialized && s.name == category,
      );
      if (plain != null) {
        return plain;
      }

      // 2) Structured generic (if you ever create them that way)
      final structured = firstWhereOrNull(
        all,
        (s) =>
            !s.isSpecialized &&
            s.category == category &&
            s.specialization == null,
      );
      if (structured != null) {
        return structured;
      }

      // 3) Legacy templates
      if (category == 'Language') {
        // Important: "Language (Own)" is NOT a generic template
        final langOther = firstWhereOrNull(
          all,
          (s) => !s.isSpecialized && s.name == 'Language (Other)',
        );
        if (langOther != null) {
          return langOther;
        }
      }

      final legacyAny = firstWhereOrNull(
        all,
        (s) => !s.isSpecialized && isLegacyAnyGeneric(s.name, category),
      );
      return legacyAny;
    }

    List<Skill> specsFor(String category) {
      final list = all
          .where((s) => s.isSpecialized && s.category == category)
          .toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));
      return list;
    }

    /// Determine if a skill belongs to a specialization family and return that category.
    /// - Specialization → its .category
    /// - Generic (plain "Science", "Art/Craft", etc.) → that family name
    /// - Otherwise → null
    String? familyCategoryOf(Skill s) {
      if (s.isSpecialized && specFamilies.contains(s.category)) {
        return s.category!;
      }
      // Plain generic family names (ensure "Language (Own)" is NOT treated as family)
      if (!s.isSpecialized &&
          specFamilies.contains(s.name) &&
          s.name != 'Language (Own)') {
        return s.name;
      }
      return null;
    }

    // Sort alphabetically by display name for stable order.
    final sorted = List<Skill>.from(all)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    final consumed = <Skill>{};
    final tiles = <_Tile>[];

    for (var idx = 0; idx < sorted.length; idx++) {
      final s = sorted[idx];
      if (consumed.contains(s)) {
        continue;
      }

      final family = familyCategoryOf(s);
      if (family != null) {
        // Build the group *here* at this alphabetical position.
        final generic = findGenericForCategory(family);
        final specs = specsFor(family);

        if (generic == null && specs.isEmpty) {
          continue;
        }

        if (generic != null) consumed.add(generic);
        consumed.addAll(specs);

        final tile = _buildSpecGroupTile(
          context: context,
          vm: vm,
          draft: draft,
          category: family,
          generic: generic, // locked row first if present
          specs: specs, // then all specializations
        );

        // Weight ≈ number of rows: generic (if any) + specs + header(0.8)
        final weight = (generic != null ? 1.0 : 0.0) + specs.length + 0.8;
        tiles.add(_Tile(tile, weight));
        continue;
      }

      // Not a family member → solo row.
      consumed.add(s);
      final row = _buildSkillRowSolo(s, vm, false, draft: draft);
      tiles.add(_Tile(row, 1.0));
    }

    return tiles;
  }

  List<List<_Tile>> _splitTilesByWeight(List<_Tile> tiles, int columns) {
    final result = List.generate(columns, (_) => <_Tile>[]);
    final total = tiles.fold<double>(0, (s, t) => s + t.weight);
    final targetPerCol = (total / columns);

    double acc = 0;
    int col = 0;

    for (final t in tiles) {
      if (col >= columns) {
        // Overflow safety: dump into last column
        result[columns - 1].add(t);
        continue;
      }
      result[col].add(t);
      acc += t.weight;

      // Move to next column if we've met/exceeded the target
      if (acc >= targetPerCol && col < columns - 1) {
        col += 1;
        acc = 0;
      }
    }

    return result;
  }

  /// Null-safe finder returning T? (used to avoid 'null as T' casts in firstWhere)
  T? firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final it in items) {
      if (test(it)) return it;
    }
    return null;
  }

// A single row widget for non-grouped skills (or families without specializations yet)
  Widget _buildSkillRowSolo(Skill skill, CharacterViewModel vm, bool? lockedSkill,
      {required bool draft}) {
    _controllers.putIfAbsent(
      skill.displayName,
      () => TextEditingController(text: skill.base.toString()),
    );
    final ctl = _controllers[skill.displayName]!;
    final textShouldBe = skill.base.toString();
    if (ctl.text != textShouldBe) {
      ctl.text = textShouldBe;
      ctl.selection =
          TextSelection.fromPosition(TextPosition(offset: ctl.text.length));
    }

    final locked = lockedSkill! || isCalculatedDuringDraft(draft: draft, skillName: skill.name);
    final isOcc = vm.isOccupationSkill(skill.displayName);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        StatRow(
          name: skill.displayName,
          base: skill.base,
          hard: skill.hard,
          extreme: skill.extreme,
          onTap: () {
            if (!draft) {
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
            }
          },
          controller: ctl,
          onBaseChanged: (v) {
            vm.updateSkill(skill: skill, newValue: v);
          },
          enabled: !locked,
          locked: locked,
          occupation: isOcc,
          onDelete: null,
        ),
        if (draft) _buildCreationBubbleFor(skill.displayName, context, vm),
      ],
    );
  }

// A grouped tile for a specialization family (header + generic + specialization rows)
  Widget _buildSpecGroupTile({
    required BuildContext context,
    required CharacterViewModel vm,
    required bool draft,
    required String category,
    required Skill? generic,
    required List<Skill> specs,
  }) {
    final children = <Widget>[];

    // 1) Generic locked row first (if present), borderless inside the group
    if (generic != null) {
      children.add(
        _buildSkillRowSolo(
          generic,
          vm,
          true,
          draft: draft,
        )._asBorderless(), // helper extension below makes showBorder=false
      );
    }

    // Small gap between generic and first spec for clarity (optional)
    if (generic != null && specs.isNotEmpty) {
      children.add(const SizedBox(height: 4));
    }

    // 2) Specialization rows (editable), borderless inside the group
    for (var i = 0; i < specs.length; i++) {
      final s = specs[i];
      children.add(
        _buildSpecRowBorderless(
          skill: s,
          vm: vm,
          draft: draft,
          category: category,
        ),
      );
      if (i < specs.length - 1) {
        children.add(const SizedBox(height: 4));
      }
    }

    // 3) Bottom “+ Add” row (same height as StatRow)
    if (draft) {
      children.add(const SizedBox(height: 4));
      children.add(
        _AddRow(
          label: 'Add $category',
          enabled: true,
          onTap: () async {
            final spec = await _promptForSpecialization(context, category);
            if (spec == null || spec.trim().isEmpty) return;
            await vm.addSpecializedSkill(
              category: category,
              specialization: spec.trim(),
            );
            if (mounted) setState(() {});
          },
        ),
      );
    }

    // 4) Whole group looks like one skill: a single thin black border, no header, no alt background
    return Container(
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildSpecRowBorderless({
    required Skill? skill,
    required CharacterViewModel vm,
    required bool draft,
    required String category,
  }) {
    if (skill == null) return const SizedBox.shrink();

    _controllers.putIfAbsent(
      skill.displayName,
      () => TextEditingController(text: skill.base.toString()),
    );
    final ctl = _controllers[skill.displayName]!;
    final textShouldBe = skill.base.toString();
    if (ctl.text != textShouldBe) {
      ctl.text = textShouldBe;
      ctl.selection = TextSelection.fromPosition(
        TextPosition(offset: ctl.text.length),
      );
    }

    final isOcc = vm.isOccupationSkill(skill.displayName);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        StatRow(
          name: skill.isSpecialized
              ? (skill.specialization ?? skill.displayName)
              : skill.displayName,
          base: skill.base,
          hard: skill.hard,
          extreme: skill.extreme,
          controller: ctl,
                    onBaseChanged: (value) => vm.updateSkill(skill: skill, newValue: value),
          onTap: () {
            if (!draft) {
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
            }
          },
          enabled: skill.isSpecialized,
          locked: !skill.isSpecialized,
          occupation: isOcc,
          onDelete: draft
              ? () async {
                  await vm.removeSkillByName(skill.displayName);
                  if (mounted) setState(() {});
                }
              : null,
          showBorder: false, // no inner border; group has the border
        ),
        if (draft) _buildCreationBubbleFor(skill.displayName, context, vm),
      ],
    );
  }

  Future<String?> _promptForSpecialization(
      BuildContext context, String category) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add $category specialization'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText:
                  category == 'Language' ? 'e.g., Latin' : 'e.g., Biology',
            ),
            onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  String _creationMessageText(String key) {
    switch (key) {
      case 'forbidden_generic_template':
        return 'Edit the specialization, not the template.';
      case 'forbidden_calculated':
        return 'This value is calculated during creation.';
      case 'no_points_remaining':
        return 'No points remaining in the selected pool.';
      case 'partial_due_to_pool':
        return 'Raised partially (pool limit).';
      case 'forbidden_cthulhu_mythos':
        return 'Cannot increase Cthulhu Mythos with normal points.';
      default:
        return key;
    }
  }

  Widget _buildCreationBubbleFor(
      String skillName, BuildContext context, CharacterViewModel vm) {
    final evt = vm.lastCreationUpdate.value;
    final visible = evt != null &&
        evt.target == ChangeTarget.skill &&
        evt.name.toLowerCase() == skillName.toLowerCase() &&
        evt.result.messages.isNotEmpty;

    if (!visible) return const SizedBox.shrink();

    final msg = evt.result.messages.first;
    return Positioned(
      right: 8,
      top: -6,
      child: _Bubble(
        text: _creationMessageText(msg),
        color: Theme.of(context).colorScheme.errorContainer,
        textColor: Theme.of(context).colorScheme.onErrorContainer,
      ),
    );
  }

// Helper: which skills are calculated during creation (locked by rules)
  bool isCalculatedDuringDraft(
      {required bool draft, required String skillName}) {
    switch (skillName) {
      case 'Dodge':
      case 'Language (Own)':
        return draft;
      default:
        return false;
    }
  }
}

extension on Widget {
  // Convenience to reuse _buildSkillRowSolo output but hide its border inside the group
  Widget _asBorderless() {
    if (this is! Stack) return this;
    final stack = this as Stack;
    final base = stack.children.firstWhere((w) => w is StatRow, orElse: () => this);
    if (base is StatRow) {
      return Stack(
        clipBehavior: stack.clipBehavior,
        children: [
          StatRow(
            name: base.name,
            base: base.base,
            hard: base.hard,
            extreme: base.extreme,
            onTap: base.onTap,
            controller: base.controller,
            onBaseChanged: base.onBaseChanged,
            enabled: base.enabled,
            locked: base.locked,
            occupation: base.occupation,
            onDelete: base.onDelete,
            showBorder: false, // override
          ),
          ...stack.children.skip(1), // keep bubbles/overlays
        ],
      );
    }
    return this;
  }
}

class _AddRow extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  const _AddRow({required this.label, required this.enabled, this.onTap});

  static const double _kStatRowHeight = 48.0; // height of one StatRow

  @override
  Widget build(BuildContext context) {
    // Mimic StatRow height & padding; no internal border (group draws it)
    return SizedBox(
      height: _kStatRowHeight,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.add, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  const _Bubble({required this.text, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    final fg = textColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: ShapeDecoration(
          color: bg,
          shape: const StadiumBorder(),
          shadows: const [
            BoxShadow(
                blurRadius: 4,
                spreadRadius: 0,
                offset: Offset(0, 1),
                color: Colors.black12)
          ],
        ),
        child: Text(text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg)),
      ),
    );
  }
}
