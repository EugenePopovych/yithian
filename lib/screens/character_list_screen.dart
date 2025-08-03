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

    // Count how many sheets start with the same base name
    int sameNames = characters.where((c) => c.name.startsWith(baseName)).length;

    String name = baseName;
    String profession = baseProfession;

    // Build initial sheet name
    String sheetName = "$name - $profession";
    if (sameNames > 0) {
      sheetName = "$sheetName (version ${sameNames + 1})";
    }

    final newCharacter = Character(
      sheetName: sheetName,
      name: name,
      age: 25,
      pronouns: '',
      birthplace: '',
      occupation: profession,
      residence: '',
      currentHP: 10,
      maxHP: 10,
      currentSanity: 50,
      startingSanity: 50,
      currentMP: 10,
      startingMP: 10,
      currentLuck: 50,
      attributes: [
        Attribute(name: "Strength", base: 50),
        Attribute(name: "Dexterity", base: 50),
        Attribute(name: "Constitution", base: 50),
        Attribute(name: "Intelligence", base: 50),
        Attribute(name: "Power", base: 50),
        Attribute(name: "Size", base: 50),
        Attribute(name: "Education", base: 50),
        Attribute(name: "Appearance", base: 50),
      ],      
      skills: [
        Skill(name: "Accounting", base: 5),
        Skill(name: "Anthropology", base: 1),
        Skill(name: "Appraise", base: 5),
        Skill(name: "Archaeology", base: 1),
        Skill(name: "Art/Craft", base: 5), // This will later be split into subskills
        Skill(name: "Charm", base: 15),
        Skill(name: "Climb", base: 20),
        Skill(name: "Credit Rating", base: 0),
        Skill(name: "Cthulhu Mythos", base: 0),
        Skill(name: "Disguise", base: 5),
        Skill(name: "Dodge", base: 50),
        Skill(name: "Drive Auto", base: 20),
        Skill(name: "Electrical Repair", base: 10),
        Skill(name: "Fast Talk", base: 5),
        Skill(name: "Fighting (Brawl)", base: 25),
        Skill(name: "Firearms (Handgun)", base: 20),
        Skill(name: "Firearms (Rifle/Shotgun)", base: 25),
        Skill(name: "First Aid", base: 30),
        Skill(name: "History", base: 5),
        Skill(name: "Intimidate", base: 15),
        Skill(name: "Jump", base: 20),
        Skill(name: "Language (Own)", base: 50),
        Skill(name: "Law", base: 5),
        Skill(name: "Library Use", base: 20),
        Skill(name: "Listen", base: 20),
        Skill(name: "Locksmith", base: 1),
        Skill(name: "Mechanical Repair", base: 10),
        Skill(name: "Medicine", base: 1),
        Skill(name: "Natural World", base: 10),
        Skill(name: "Navigate", base: 10),
        Skill(name: "Occult", base: 5),
        Skill(name: "Operate Heavy Machinery", base: 1),
        Skill(name: "Persuade", base: 10),
        Skill(name: "Pilot", base: 1),
        Skill(name: "Psychology", base: 10),
        Skill(name: "Psychoanalysis", base: 1),
        Skill(name: "Ride", base: 5),
        Skill(name: "Science", base: 1), // Later can add subskills
        Skill(name: "Sleight of Hand", base: 10),
        Skill(name: "Spot Hidden", base: 25),
        Skill(name: "Stealth", base: 20),
        Skill(name: "Survival", base: 10),
        Skill(name: "Swim", base: 20),
        Skill(name: "Throw", base: 20),
        Skill(name: "Track", base: 10),
      ]
    );

    final id = const Uuid().v4();
    final viewModel = Provider.of<CharacterViewModel>(context, listen: false);
    await viewModel.createCharacter(newCharacter, id: id);

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
