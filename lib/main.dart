import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/hive_character.dart';
import 'models/hive_attribute.dart';
import 'models/hive_skill.dart';
import 'viewmodels/character_viewmodel.dart';
import 'screens/main_screen.dart';
import 'theme_light.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HiveCharacterAdapter());
  Hive.registerAdapter(HiveAttributeAdapter());
  Hive.registerAdapter(HiveSkillAdapter());
  await Hive.openBox<HiveCharacter>('characters');
  await Hive.openBox('settings');
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
        theme: cocThemeLight,
        home: MainScreen(), 
      ),
    );
  }
}
