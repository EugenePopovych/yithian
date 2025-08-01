import 'package:flutter/material.dart';

class ScreenNavBar extends StatelessWidget {
  final int currentIndex;
  final bool hasCharacter;
  final ValueChanged<int> onTap;

  const ScreenNavBar({
    super.key,
    required this.currentIndex,
    required this.hasCharacter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Characters',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.assignment_ind,
            color: hasCharacter ? null : Colors.grey,
          ),
          label: 'Sheet',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.casino),
          label: 'Dice',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
