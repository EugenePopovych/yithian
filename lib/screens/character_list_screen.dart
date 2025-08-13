// lib/screens/character_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coc_sheet/models/character.dart';
import 'package:coc_sheet/models/sheet_status.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/screens/create_character_dialog.dart';

class CharacterListScreen extends StatelessWidget {
  final VoidCallback? onCharacterSelected;

  const CharacterListScreen({super.key, this.onCharacterSelected});

  Future<void> _createNewCharacter(BuildContext context) async {
    final vm = context.read<CharacterViewModel>();
    final req = await showCreateCharacterDialog(context);
    if (req == null) return;
    await vm.createCharacter(
      name: req.name,
      occupation: req.occupation,
      status: req.status,
    );
    onCharacterSelected?.call();
  }

  Future<void> _openCharacter(BuildContext context, String id) async {
    final vm = context.read<CharacterViewModel>();
    await vm.loadCharacter(id);
    onCharacterSelected?.call();
  }

  Future<void> _deleteCharacter(BuildContext context, String id) async {
    final vm = context.read<CharacterViewModel>();
    // Provide this in the VM:
    // Future<void> deleteById(String sheetId) { await _storage.delete(sheetId); if (_character?.sheetId == sheetId) clearCharacter(); }
    await vm.deleteById(id);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Investigators')),
      body: StreamBuilder<List<Character>>(
        stream: vm.charactersStream(
          statuses: const {SheetStatus.active, SheetStatus.archived},
        ),
        builder: (context, snap) {
          final characters = snap.data ?? const <Character>[];
          if (characters.isEmpty) {
            return const Center(child: Text('No characters yet. Tap + to create one!'));
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
