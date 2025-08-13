import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';

/// Static accessors so you can drop these into tabs like:
///   CreationRow.info(), CreationRow.attributes(), CreationRow.skills(), CreationRow.background()
class CreationRow {
  const CreationRow._();

  static Widget info() => const _CreationInfoRow();
  static Widget attributes() => const _CreationAttributesRow();
  static Widget skills() => const _CreationSkillsRow();
  static Widget background() => const _CreationBackgroundRow();
}

// ————— Shared small pieces —————

bool _isDraft(BuildContext context) => context.select<CharacterViewModel, bool>(
      (vm) => vm.character?.sheetStatus.isDraft ?? false,
    );

String _label(BuildContext context) =>
    context.select<CharacterViewModel, String>(
      (vm) => vm.rules?.label ?? '—',
    );

Future<void> _confirmDiscardDraft(BuildContext context) async {
  final theme = Theme.of(context);
  final vm = context.read<CharacterViewModel>(); // capture BEFORE await

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Discard draft?'),
      content: const Text('This will delete the current draft sheet.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );

  if (ok == true) {
    await vm.discardCurrent(); // uses captured VM, no context here
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // space below the row
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

// ————— Info tab row —————

class _CreationInfoRow extends StatelessWidget {
  const _CreationInfoRow();

  @override
  Widget build(BuildContext context) {
    if (!_isDraft(context)) return const SizedBox.shrink();

    final label = _label(context);
    final canFinalize = context.select<CharacterViewModel, bool>(
      (vm) => vm.canFinalizeCreation,
    );

    return _Panel(
      child: Row(
        children: [
          Expanded(child: Text('Creation: $label · Draft')),
          OutlinedButton(
            onPressed: () => _confirmDiscardDraft(context),
            child: const Text('Discard Draft'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: canFinalize
                ? () => context.read<CharacterViewModel>().finalizeCreation()
                : null,
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}

// ————— Attributes tab row —————

class _CreationAttributesRow extends StatelessWidget {
  const _CreationAttributesRow();

  @override
  Widget build(BuildContext context) {
    if (!_isDraft(context)) return const SizedBox.shrink();

    final label = _label(context);
    final canFinish = context.select<CharacterViewModel, bool>(
      (vm) => vm.canFinalizeCreation,
    );

    return _Panel(
      child: Row(
        children: [
          Expanded(child: Text('Creation: $label')),
          // renamed
          ElevatedButton(
            onPressed: () =>
                context.read<CharacterViewModel>().rollAttributes(),
            child: const Text('Reroll Attributes'), // was: 'Roll Attributes'
          ),
          const SizedBox(width: 8),
          // new: Finish in Attributes tab
          ElevatedButton(
            onPressed: canFinish
                ? () => context.read<CharacterViewModel>().finalizeCreation()
                : null,
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}

// ————— Skills tab row —————

class _CreationSkillsRow extends StatelessWidget {
  const _CreationSkillsRow();

  @override
  Widget build(BuildContext context) {
    if (!_isDraft(context)) return const SizedBox.shrink();

    final vm = context.read<CharacterViewModel>();
    final label = _label(context);
    final occ = context
        .select<CharacterViewModel, int?>((vm) => vm.occupationPointsRemaining);
    final per = context
        .select<CharacterViewModel, int?>((vm) => vm.personalPointsRemaining);
    final canFinish = context
        .select<CharacterViewModel, bool>((vm) => vm.canFinalizeCreation);

    Widget chip(String title, int? v) => InputChip(
          label: Text('$title: ${v ?? '—'}'),
          onPressed: null,
        );

    return _Panel(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Text('Creation: $label'),
          chip('Occupation', occ),
          chip('Personal', per),
          ElevatedButton(
            onPressed: canFinish ? () => vm.finalizeCreation() : null,
            child: const Text('Finish'),
          ),
          Tooltip(
            message: 'Above base spends points.\n'
                'Dodge = DEX/2; Language (Own) = EDU.\n'
                'Cthulhu Mythos can’t be increased during creation.',
            child: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}

// ————— Background tab row —————
// Minimal (optional finalize shortcut)

class _CreationBackgroundRow extends StatelessWidget {
  const _CreationBackgroundRow();

  @override
  Widget build(BuildContext context) {
    if (!_isDraft(context)) return const SizedBox.shrink();

    final label = _label(context);
    final canFinalize = context
        .select<CharacterViewModel, bool>((vm) => vm.canFinalizeCreation);

    return _Panel(
      child: Row(
        children: [
          Expanded(child: Text('Creation: $label')),
          ElevatedButton(
            onPressed: canFinalize
                ? () => context.read<CharacterViewModel>().finalizeCreation()
                : null,
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }
}
