import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/models/create_character_spec.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/services/occupation_storage.dart';
import 'package:coc_sheet/screens/create_character_screen.dart';

class CharacterListScreen extends StatelessWidget {
  final VoidCallback? onCharacterSelected;

  const CharacterListScreen({super.key, this.onCharacterSelected});

  /// Start the new pre-sheet creation flow.
  Future<void> _createNewCharacter(BuildContext context) async {
    // 0) If there is an existing draft, confirm discard first
    final vm = context.read<CharacterViewModel>();
    final hasDraft = vm.character?.sheetStatus.isDraft ?? false;
    if (hasDraft) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Discard current draft?'),
          content: const Text(
            'You already have a draft character. Creating a new one will discard it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (ok != true) return; // abort creating a new character
      await vm.discardCurrent();
      if (!context.mounted) return;
    }

    // 1) Push the CreateCharacterScreen and await the spec.
    final spec = await Navigator.of(context).push<CreateCharacterSpec>(
      MaterialPageRoute(builder: (_) => const CreateCharacterScreen()),
    );

    if (!context.mounted || spec == null) return;

    // 2) Materialize the draft via CharacterViewModel
    try {
      final occStorage = context.read<OccupationStorage>();
      await context.read<CharacterViewModel>().createFromSpec(
            spec,
            occupationStorage: occStorage,
          );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft character created')),
      );
      onCharacterSelected?.call();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Character creation not wired yet: $e')),
      );
    }
  }

  Future<void> _openCharacter(BuildContext context, String id) async {
    final vm = context.read<CharacterViewModel>();
    await vm.loadCharacter(id);
    onCharacterSelected?.call();
  }

  Future<void> _deleteCharacter(BuildContext context, String id) async {
    final vm = context.read<CharacterViewModel>();
    await vm.deleteById(id);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Investigators')),
      body: StreamBuilder<List<Character>>(
        stream: vm.charactersStream(
          // listen to all; we filter below so transitions (draft -> active) are caught
          statuses: SheetStatus.values.toSet(),
        ),
        builder: (context, snap) {
          final all = snap.data ?? const <Character>[];
          final characters = all
              .where((c) =>
                  c.sheetStatus == SheetStatus.active ||
                  c.sheetStatus == SheetStatus.archived)
              .toList();

          if (characters.isEmpty) {
            return const Center(
                child: Text('No characters yet. Tap + to create one!'));
          }
          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final c = characters[index];
              return ListTile(
                title: Text(c.name.isNotEmpty ? c.name : '(unnamed)'),
                subtitle: Text(c.occupation.isNotEmpty ? c.occupation : ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCharacter(context, c.sheetId),
                ),
                onTap: () => _openCharacter(context, c.sheetId),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewCharacter(context),
        tooltip: 'New Character',
        child: const Icon(Icons.add),
      ),
    );
  }
}
