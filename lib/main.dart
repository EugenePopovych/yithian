import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/character_viewmodel.dart';
import 'screens/character_sheet_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CharacterViewModel(),
      child: MaterialApp(
        title: 'Call of Cthulhu Character Sheet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: CharacterSheetScreen(), // 👈 Set this as the start screen
      ),
    );
  }
}
