import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coc_sheet/models/create_character_spec.dart';
import 'package:coc_sheet/models/occupation.dart';
import 'package:coc_sheet/models/classic_rules.dart' show AttrKey;
import 'package:coc_sheet/services/occupation_storage_json.dart';
import 'package:coc_sheet/viewmodels/create_character_view_model.dart';

const double kOccupationListHeight = 260;

bool _skillNeedsSpecialization(String s) {
  final ls = s.toLowerCase();
  return ls.contains('(any)') || ls.contains('(other)');
}

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({
    super.key,
    this.onCreate,
  });

  /// Optional: if provided, will be called on Create; otherwise Navigator.pop(spec).
  final void Function(CreateCharacterSpec spec)? onCreate;

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreditRatingHint extends StatelessWidget {
  const _CreditRatingHint({required this.creditMin, required this.creditMax});
  final int creditMin;
  final int creditMax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Credit Rating: $creditMin–$creditMax (set on sheet)',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController(text: '20');

  List<Occupation> _allOccupations = const [];
  List<Occupation> _filtered = const [];
  bool _loadingOcc = true;

  @override
  void initState() {
    super.initState();
    _loadOccupations();
  }

  Future<void> _loadOccupations() async {
    setState(() => _loadingOcc = true);
    try {
      final list = await OccupationStorageJson.instance.getAll();
      setState(() {
        _allOccupations = list;
        _filtered = list;
        _loadingOcc = false;
      });
    } catch (e) {
      setState(() => _loadingOcc = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load occupations: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _onCreatePressed(CreateCharacterViewModel vm) {
    final occ = vm.occupation!;
    final spec = CreateCharacterSpec(
      name: vm.name.trim(),
      age: vm.age,
      attributes: vm.attributes,
      luck: vm.luck,
      occupationId: occ.id,
      selectedSkills: vm.selectedSkills.map((s) {
        if (_skillNeedsSpecialization(s)) {
          final spec = _Body._specCtrls[s]?.text.trim();
          if (spec != null && spec.isNotEmpty) {
            // Replace "(Any)" or "(Other)" with the chosen specialization
            return s.replaceAll(
              RegExp(r'\((Any|Other)\)', caseSensitive: false),
              '($spec)',
            );
          }
        }
        return s;
      }).toList()
        ..sort(),
    );

    if (widget.onCreate != null) {
      widget.onCreate!(spec);
    } else {
      Navigator.of(context).pop(spec);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateCharacterViewModel>(
      create: (_) => CreateCharacterViewModel(),
      child: Consumer<CreateCharacterViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Create Character'),
            ),
            body: _Body(
              vm: vm,
              nameCtrl: _nameCtrl,
              ageCtrl: _ageCtrl,
              allOccupations: _allOccupations,
              filtered: _filtered,
              loadingOcc: _loadingOcc,
              onFilterChanged: (q) {
                final qq = q.trim().toLowerCase();
                setState(() {
                  _filtered = _allOccupations.where((o) {
                    if (o.name.toLowerCase().contains(qq)) return true;
                    if (o.id.toLowerCase().contains(qq)) return true;
                    return o.mandatorySkills.any((s) => s.toLowerCase().contains(qq)) ||
                        o.skillPool.any((s) => s.toLowerCase().contains(qq));
                  }).toList(growable: false);
                });
              },
              onCreate: () => _onCreatePressed(vm),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.vm,
    required this.nameCtrl,
    required this.ageCtrl,
    required this.allOccupations,
    required this.filtered,
    required this.loadingOcc,
    required this.onFilterChanged,
    required this.onCreate,
  });

  final CreateCharacterViewModel vm;
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;

  final List<Occupation> allOccupations;
  final List<Occupation> filtered;
  final bool loadingOcc;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onCreate;

  // Controllers for specialization inputs keyed by base skill (e.g., 'Art/Craft (Any)').
  static final Map<String, TextEditingController> _specCtrls = {};

  TextEditingController _ctrlFor(String skill) {
    return _specCtrls.putIfAbsent(skill, () => TextEditingController());
  }

  /// Returns selected skills that require a non-empty specialization but don't have it yet.
  List<String> _missingSpecs(Set<String> selected) {
    return selected
        .where(_skillNeedsSpecialization)
        .where((s) => _ctrlFor(s).text.trim().isEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = vm.isReadyToCreate && _missingSpecs(vm.selectedSkills).isEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          // Name
          Text('Name', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter name',
            ),
            onChanged: vm.setName,
          ),
          const SizedBox(height: 16),

          // Age
          Text('Age', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: ageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Age',
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) vm.setAge(n);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text('Move ${vm.move} • HP ${vm.hp} • MP ${vm.mp} • Sanity ${vm.sanity} • Luck ${vm.luck} • DB ${vm.damageBonus.db} (Build ${vm.damageBonus.build})'),
            ],
          ),
          const SizedBox(height: 16),

          // Attributes grid + reroll
          Row(
            children: [
              Text('Attributes', style: theme.textTheme.titleMedium),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: vm.rerollAttributes,
                icon: const Icon(Icons.casino),
                label: const Text('Reroll'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AttributesGrid(attrs: vm.attributes),
          const SizedBox(height: 8),
          Text('Pools: Occupation ${vm.occupationPoints} • Personal ${vm.personalPoints}',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),

          // Occupation picker
          Text('Occupation', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _OccupationPicker(
            loading: loadingOcc,
            occupations: filtered,
            selected: vm.occupation,
            onQueryChanged: onFilterChanged,
            onSelected: vm.selectOccupation,
          ),
          const SizedBox(height: 16),
          if (vm.occupation != null) ...[
            _CreditRatingHint(
              creditMin: vm.occupation!.creditMin,
              creditMax: vm.occupation!.creditMax,
            ),
            const SizedBox(height: 12),
          ],

          // Skills multi-select (after occupation chosen)
          if (vm.occupation != null) ...[
            _SpecScope(
              map: _Body._specCtrls,
              child: _OccupationSkills(
                vm: vm,
                occupation: vm.occupation!,
                selected: vm.selectedSkills,
                onChanged: vm.setOccupationSkills,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Create button
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: isReady ? onCreate : null,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributesGrid extends StatelessWidget {
  const _AttributesGrid({required this.attrs});

  final Map<String, int> attrs;

  @override
  Widget build(BuildContext context) {
    final keys = [
      AttrKey.str,
      AttrKey.con,
      AttrKey.dex,
      AttrKey.app,
      AttrKey.pow,
      AttrKey.siz,
      AttrKey.intg,
      AttrKey.edu,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple responsive columns: 2 on narrow, 4 on wide
        final columns = constraints.maxWidth > 720 ? 4 : 2;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 8) / columns;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keys.map((k) {
            final v = attrs[k] ?? 0;
            final hard = (v / 2).floor();
            final extreme = (v / 5).floor();
            return SizedBox(
              width: itemWidth,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(k, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SquareValue(v),
                          _SquareValue(hard),
                          _SquareValue(extreme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SquareValue extends StatelessWidget {
  const _SquareValue(this.value);
  final int value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text('$value'),
      ),
    );
  }
}

class _OccupationPicker extends StatefulWidget {
  const _OccupationPicker({
    required this.loading,
    required this.occupations,
    required this.selected,
    required this.onSelected,
    required this.onQueryChanged,
  });

  final bool loading;
  final List<Occupation> occupations;
  final Occupation? selected;
  final ValueChanged<Occupation?> onSelected;
  final ValueChanged<String> onQueryChanged;

  @override
  State<_OccupationPicker> createState() => _OccupationPickerState();
}

class _OccupationPickerState extends State<_OccupationPicker> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return Column(
      children: [
        TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search occupation…',
            border: OutlineInputBorder(),
          ),
          onChanged: widget.onQueryChanged,
        ),
        const SizedBox(height: 8),
        if (widget.loading)
          const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ))
        else
          Container(
            height: kOccupationListHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              primary: false,
              itemCount: widget.occupations.length,
              itemBuilder: (context, i) {
                final o = widget.occupations[i];
                return RadioListTile<Occupation>(
                  value: o,
                  groupValue: sel,
                  title: Text(o.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'CR ${o.creditMin}–${o.creditMax} • ${o.selectCount} skills'),
                      const SizedBox(height: 2),
                      Text(
                        ([...o.mandatorySkills, ...o.skillPool].join(', ')),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2, // optional, trim if list is long
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onChanged: (v) => widget.onSelected(v),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SpecScope extends InheritedWidget {
  const _SpecScope({required super.child, required this.map});

  final Map<String, TextEditingController> map;

  static Map<String, TextEditingController> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_SpecScope>();
    assert(scope != null, 'No _SpecScope found in context');
    return scope!.map;
  }

  @override
  bool updateShouldNotify(covariant _SpecScope oldWidget) => oldWidget.map != map;
}

class _OccupationSkills extends StatelessWidget {
  const _OccupationSkills({
    required this.vm,
    required this.occupation,
    required this.selected,
    required this.onChanged,
  });

  final CreateCharacterViewModel vm;
  final Occupation occupation;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final mandatory = occupation.mandatorySkills.toSet();
    final limit = occupation.selectCount;
    final optionalSelected = selected.difference(mandatory).length;
    final optionalLimit = (limit - mandatory.length).clamp(0, 999);
    final disableUnchecked = optionalSelected >= optionalLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Occupation Skills  ${selected.length} / ${occupation.selectCount}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (mandatory.isNotEmpty) ...[
          Text('Mandatory', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mandatory
                .map((s) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilterChip(
                            label: Text(s), selected: true, onSelected: null),
                        if (_skillNeedsSpecialization(s)) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 160,
                            child: TextField(
                              controller: _SpecScope.of(context).putIfAbsent(
                                  s, () => TextEditingController()),
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Specialization',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        Text('Choose from pool', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: occupation.skillPool.map((s) {
            final isSelected = selected.contains(s);
            final canTurnOn = isSelected || !disableUnchecked;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilterChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: canTurnOn
                      ? (on) {
                          final next = {...selected};
                          if (on) {
                            next.add(s);
                          } else {
                            next.remove(s);
                          }
                          // Always preserve mandatory
                          next.addAll(mandatory);
                          onChanged(next);
                        }
                      : null,
                ),
                if (isSelected && _skillNeedsSpecialization(s)) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 160,
                    child: TextField(
                      controller: _SpecScope.of(context)
                          .putIfAbsent(s, () => TextEditingController()),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Specialization',
                        ),
                        // reflect in readiness immediately
                        onChanged: (_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            onChanged(
                                selected); // triggers vm.setOccupationSkills -> notifyListeners()
                          });
                        }
                    ),
                  ),
                ],
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
