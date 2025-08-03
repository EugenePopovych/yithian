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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CharacterViewModel>();
    final character = viewModel.character;

    if (character == null) {
      return const Center(
        child: Text('No character loaded.\nPlease create or select a character first.'),
      );
    }

    final characterName = character.name;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(characterName.isNotEmpty ? characterName : "Character Sheet"),
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
