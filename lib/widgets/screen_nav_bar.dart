import 'package:flutter/material.dart';

class ScreenNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ScreenNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_ind),
          label: 'Character',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.casino),
          label: 'Dice',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
