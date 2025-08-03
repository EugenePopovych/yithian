import 'package:flutter/material.dart';
import '../theme_light.dart'; // Import your theme file with color constants

class ScreenNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasCharacter;

  const ScreenNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.hasCharacter,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assignment_ind,
            color: currentIndex == 0
                ? selectedNavColor
                : availableNavColor,
          ),
          label: 'Character',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assignment,
            color: currentIndex == 1 
                ? selectedNavColor
                : availableNavColor,
          ),
          label: 'Sheet',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.casino,
            color: currentIndex == 2
                ? selectedNavColor
                : availableNavColor,
          ),
          label: 'Dice',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            color: currentIndex == 3
                ? selectedNavColor
                : availableNavColor,
          ),
          label: 'Settings',
        ),
      ],
      selectedItemColor: selectedNavColor,
      unselectedItemColor: availableNavColor,
      showUnselectedLabels: true,
    );
  }
}
