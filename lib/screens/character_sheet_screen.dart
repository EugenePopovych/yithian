import 'package:flutter/material.dart';
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Character Sheet"),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Character"),
            BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Dice Roller"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Options"),
          ],
        ),
      ),
    );
  }
}
