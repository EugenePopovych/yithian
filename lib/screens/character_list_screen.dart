import 'package:coc_sheet/models/sheet_status.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/hive_character.dart';
import '../models/character.dart';
import '../models/attribute.dart';
import '../models/skill.dart';
import '../viewmodels/character_viewmodel.dart';

class CharacterListScreen extends StatefulWidget {
  final VoidCallback? onCharacterSelected; // <-- ADD THIS

  const CharacterListScreen({super.key, this.onCharacterSelected});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  late Box<HiveCharacter> characterBox;
  List<Character> characters = [];
  List<String> hiveKeys = [];

  @override
  void initState() {
    super.initState();
    characterBox = Hive.box<HiveCharacter>('characters');
    _refreshList();
  }

  void _refreshList() {
    final entries = characterBox.toMap().entries.toList();
    hiveKeys = entries.map((e) => e.key as String).toList();
    characters = entries.map((e) => e.value.toCharacter()).toList();
    setState(() {});
  }

  Future<void> _createNewCharacter() async {
    // Choose defaults for new character
    String baseName = 'Randolph Carter';
    String baseProfession = 'Detective';

    String name = baseName;
    String profession = baseProfession;

    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    await viewModel.createCharacter(
      name: name,
      occupation: profession,
      status: SheetStatus.draft_free
    );

    _refreshList();

    if (!mounted) return;

    // Call the callback to switch to the sheet tab!
    widget.onCharacterSelected?.call();
  }

  void _deleteCharacter(int index) async {
    final key = hiveKeys[index];
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    if (viewModel.hasCharacter && viewModel.characterId == key) {
      viewModel.clearCharacter();
    }

    await characterBox.delete(key);
    _refreshList();
  }

  Future<void> _openCharacter(int index) async {
    final key = hiveKeys[index];
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);

    await viewModel.loadCharacter(key);

    // Call the callback to switch to the sheet tab!
    widget.onCharacterSelected?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Investigators'),
      ),
      body: characters.isEmpty
          ? const Center(child: Text('No characters yet. Tap + to create one!'))
          : ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return ListTile(
                  title: Text(character.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCharacter(index),
                  ),
                  onTap: () => _openCharacter(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCharacter,
        tooltip: 'New Character',
        child: const Icon(Icons.add),
      ),
    );
  }
}
