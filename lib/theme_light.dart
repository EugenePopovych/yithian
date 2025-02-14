import 'package:flutter/material.dart';

final ThemeData cocThemeLight = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFFB8C6A7), // Soft green
  scaffoldBackgroundColor: Color(0xFFF8F5E4), // Parchment-like background
  hintColor: Color(0xFF4E4E4E), // Darker gray for contrast
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A3B29)), // Dark green
    bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)), // Readable text
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFECE6CC), // Aged paper look for text fields
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF9E9E9E)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF506C57)),
      borderRadius: BorderRadius.circular(8),
    ),
    labelStyle: TextStyle(color: Color(0xFF2A3B29)),
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Color(0xFFB8C6A7),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Color(0xFF2A3B29), // Dark green for selected tab
    unselectedLabelColor: Color(0xFF4E4E4E), // Gray for unselected tabs
    indicator: BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFF506C57), width: 3)), // Greenish indicator
    ),
    indicatorColor: Color(0xFF506C57),
  ),
  iconTheme: IconThemeData(color: Color(0xFF2A3B29)),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFB8C6A7), // Soft green background
    selectedItemColor: Color.fromARGB(255, 29, 66, 29), // Dark green for selected icon
    unselectedItemColor: Color.fromARGB(255, 145, 144, 144), // Muted gray for unselected
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFFB8C6A7), // Match theme
    foregroundColor: Color(0xFF2A3B29),
  ),
);
