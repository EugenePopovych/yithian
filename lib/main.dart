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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CharacterViewModel _viewModel = CharacterViewModel();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    await _viewModel.init();
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        title: 'Call of Cthulhu Character Sheet',
        theme: cocThemeLight,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ChangeNotifierProvider<CharacterViewModel>.value(
      value: _viewModel,
      child: MaterialApp(
        title: 'Call of Cthulhu Character Sheet',
        theme: cocThemeLight,
        home: const MainScreen(),
      ),
    );
  }
}
