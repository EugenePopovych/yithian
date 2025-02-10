import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/character_viewmodel.dart';
import '../widgets/attribute_widget.dart';
import '../widgets/skill_widget.dart';

class CharacterSheetScreen extends StatelessWidget {
  const CharacterSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final characterVM = Provider.of<CharacterViewModel>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Character Sheet"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Info"),
              Tab(text: "Attributes"),
              Tab(text: "Skills"),
              Tab(text: "Background"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(characterVM),
            _buildAttributesTab(characterVM),
            _buildSkillsTab(characterVM),
            _buildBackgroundTab(characterVM),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Sheet"),
            BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Dice"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
          onTap: (index) {
            if (index == 1) {
              // Dice roller screen is disabled for now
              // Navigator.pushNamed(context, '/dice');
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoTab(CharacterViewModel characterVM) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(labelText: "Character Name"),
            controller: TextEditingController(text: characterVM.character.name),
            onChanged: (value) => characterVM.updateName(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesTab(CharacterViewModel characterVM) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: characterVM.character.attributes.map((attribute) =>
        AttributeWidget(attribute: attribute, onTap: () {
          // Dice roller screen is disabled for now
          // Navigator.pushNamed(context, '/dice', arguments: attribute);
        })
      ).toList(),
    );
  }

  Widget _buildSkillsTab(CharacterViewModel characterVM) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: characterVM.character.skills.map((skill) =>
        SkillWidget(skill: skill, onTap: () {
          // Dice roller screen is disabled for now
          // Navigator.pushNamed(context, '/dice', arguments: skill);
        })
      ).toList(),
    );
  }

  Widget _buildBackgroundTab(CharacterViewModel characterVM) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Text("Character background and notes go here."),
    );
  }
}
