import 'package:flutter/material.dart';

final ThemeData cocThemeDark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF2A3B29), // Dark green shade
  scaffoldBackgroundColor: Color(0xFF1C1C1C), // Deep blackish background
  hintColor: Color(0xFF9E9E9E), // Soft gray for contrast
  textTheme: TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB8C6A7)), // Soft green
    bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFC0C0C0)), // Readable text
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF2F3E2F), // Muted green fill for text fields
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF506C57)),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF81A380)),
      borderRadius: BorderRadius.circular(8),
    ),
    labelStyle: TextStyle(color: Color(0xFFB8C6A7)),
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: Color(0xFF2A3B29),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Color(0xFFB8C6A7),
    unselectedLabelColor: Color(0xFF9E9E9E),
    indicator: BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFF81A380), width: 3)),
    ),
  ),
  iconTheme: IconThemeData(color: Color(0xFFB8C6A7)),
);
