import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coc_sheet/services/hive_init.dart';
import 'package:coc_sheet/services/hive_character_storage.dart';
import 'package:coc_sheet/viewmodels/character_viewmodel.dart';
import 'package:coc_sheet/screens/main_screen.dart';
import 'package:coc_sheet/theme_light.dart';

// NEW: inject occupation storage via Provider (interface, not the concrete type)
import 'package:coc_sheet/services/occupation_storage.dart';
import 'package:coc_sheet/services/occupation_storage_json.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  runApp(const CocSheetApp());
}

class CocSheetApp extends StatefulWidget {
  const CocSheetApp({super.key});

  @override
  State<CocSheetApp> createState() => _CocSheetAppState();
}

class _CocSheetAppState extends State<CocSheetApp> {
  late final CharacterViewModel _viewModel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    _viewModel = CharacterViewModel(HiveCharacterStorage());
    await _viewModel.init();
    setState(() => _initialized = true);
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

    return MultiProvider(
      providers: [
        // Provide the OccupationStorage interface so screens/VMs can read it.
        Provider<OccupationStorage>(
          create: (_) => OccupationStorageJson(
            assetPath: 'lib/data/occupations.json',
          ),
        ),
        // Keep your existing CharacterViewModel instance
        ChangeNotifierProvider<CharacterViewModel>.value(
          value: _viewModel,
        ),
      ],
      child: MaterialApp(
        title: 'Call of Cthulhu Character Sheet',
        theme: cocThemeLight,
        home: const MainScreen(),
      ),
    );
  }
}
