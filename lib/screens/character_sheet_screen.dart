import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';
import '../screens/info_tab.dart';
import '../screens/attributes_tab.dart';
import '../screens/skills_tab.dart';
import '../screens/background_tab.dart';

class CharacterSheetScreen extends StatefulWidget {
  const CharacterSheetScreen({super.key});

  @override
  CharacterSheetScreenState createState() => CharacterSheetScreenState();
}

class CharacterSheetScreenState extends State<CharacterSheetScreen> {
  final List<Widget> _tabs = [
    const InfoTab(),
    AttributesTab(),
    const SkillsTab(),
    BackgroundTab()
  ];

  late TextEditingController _sheetNameController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final character = context.read<CharacterViewModel>().character;
    _sheetNameController = TextEditingController(text: character?.sheetName ?? '');
  }

  @override
  void dispose() {
    _sheetNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CharacterViewModel>();
    final character = viewModel.character;

    if (character == null) {
      return const Center(
        child: Text('No character loaded.\nPlease create or select a character first.'),
      );
    }

    // Keep controller in sync if character changes
    if (_sheetNameController.text != character.sheetName) {
      _sheetNameController.text = character.sheetName;
      _sheetNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _sheetNameController.text.length),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          // Editable sheet name in AppBar
          title: SizedBox(
            height: 36,
            child: TextField(
              controller: _sheetNameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Sheet Name",
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: Theme.of(context).appBarTheme.titleTextStyle ??
                  Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              onChanged: (val) => viewModel.updateCharacterSheetName(val),
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Attributes"),
              Tab(text: "Skills"),
              Tab(text: "Background"),
            ],
          ),
        ),
        body: TabBarView(
          children: _tabs,
        ),
      ),
    );
  }
}
