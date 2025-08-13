import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/screens/info_tab.dart';
import 'package:coc_sheet/screens/attributes_tab.dart';
import 'package:coc_sheet/screens/skills_tab.dart';
import 'package:coc_sheet/screens/background_tab.dart';
import 'package:coc_sheet/models/sheet_status.dart';

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
          // Subtle background change for drafts
          backgroundColor: (viewModel.character?.sheetStatus.isDraft ?? false)
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : null,

          centerTitle: false,
          titleSpacing: 16,
          // Editable sheet name in AppBar with "(draft)" suffix when in creation mode
          title: SizedBox(
            height: 36,
            child: TextField(
              controller: _sheetNameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Sheet Name",
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                // ➜ italic "(draft)" when draft
                suffix: (viewModel.character?.sheetStatus.isDraft ?? false)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '(draft)',
                          style: (Theme.of(context).textTheme.titleMedium ??
                                  Theme.of(context).textTheme.titleLarge)
                              ?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    : null,
              ),
              style: Theme.of(context).appBarTheme.titleTextStyle ??
                  Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
              onChanged: (val) => viewModel.updateCharacterSheetName(val),
            ),
          ),
          // no actions needed
          actions: const [],
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
