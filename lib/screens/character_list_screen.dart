import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/hive_character.dart';
import '../models/character.dart';
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
    String baseName = 'Investigator';
    int sameNames = characters.where((c) => c.name.startsWith(baseName)).length;
    String name = sameNames > 0 ? '$baseName (version ${sameNames + 1})' : baseName;

    final newCharacter = Character(
      name: name,
      age: 25,
      pronouns: '',
      birthplace: '',
      occupation: '',
      residence: '',
      currentHP: 10,
      maxHP: 10,
      currentSanity: 50,
      startingSanity: 50,
      currentMP: 10,
      startingMP: 10,
      currentLuck: 50,
      attributes: [],
      skills: [],
    );
    final id = const Uuid().v4();

    // Use viewmodel to create and set character
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    await viewModel.createCharacter(newCharacter, id: id);

    _refreshList(); // Keep the list in sync

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
