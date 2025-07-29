import 'package:flutter/material.dart';
import '../screens/character_sheet_screen.dart';
import '../screens/dice_roller_screen.dart';
import '../screens/settings_screen.dart'; // You may need to create this
import '../widgets/screen_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CharacterSheetScreen(),
      const DiceRollerScreen(), // Opens in generic mode (no skill)
      const SettingsScreen(),   // Create a stub if you don't have it
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
