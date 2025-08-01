import 'package:flutter/material.dart';
import '../screens/character_list_screen.dart';
import '../screens/character_sheet_screen.dart';
import '../screens/dice_roller_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/screen_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Sheet by default

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CharacterListScreen(),    // Index 0: Character list
      const CharacterSheetScreen(),   // Index 1: Sheet
      const DiceRollerScreen(),       // Index 2: Dice
      const SettingsScreen(),         // Index 3: Settings
    ];
    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: ScreenNavBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
