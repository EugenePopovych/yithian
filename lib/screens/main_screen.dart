import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/character_list_screen.dart';
import '../screens/character_sheet_screen.dart';
import '../screens/dice_roller_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/screen_nav_bar.dart';
import '../viewmodels/character_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Sheet by default, Characters if none loaded

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final hasCharacter = context.watch<CharacterViewModel>().hasCharacter;
    if (!hasCharacter && _selectedIndex != 0) {
      // No character: force Characters tab
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCharacter = context.watch<CharacterViewModel>().hasCharacter;
    final screens = [
      CharacterListScreen(
        onCharacterSelected: () {
          setState(() {
            _selectedIndex = 1; // Switch to Sheet tab
          });
        },
      ),
      const CharacterSheetScreen(),
      const DiceRollerScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: ScreenNavBar(
        currentIndex: _selectedIndex,
        hasCharacter: hasCharacter,
        onTap: (int index) {
          // Only allow Sheet tab if character is loaded
          if (index == 1 && !hasCharacter) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please create or load a character first.")),
            );
            return;
          }
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
