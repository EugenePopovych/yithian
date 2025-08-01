# Copilot Instructions for yithian (Call of Cthulhu 7ed Character Sheet)

## Project Overview
- This is a Flutter app for managing Call of Cthulhu 7th Edition character sheets.
- Main app code is in `lib/`, organized by feature: `models/`, `viewmodels/`, `screens/`, and `widgets/`.
- Data flow follows a ViewModel pattern: UI in `screens/` and `widgets/` interacts with business logic in `viewmodels/`, which manipulates data in `models/`.
- Persistent storage uses Hive (see `lib/models/hive_*.dart`).

## Key Workflows
- **Build:** Use standard Flutter commands, e.g. `flutter build apk` or `flutter run` for development.
- **Test:** Run tests with `flutter test`. Test files are in `test/` and mirror the structure of `lib/`.
- **Code Generation:** If you change model classes with Hive annotations, run `flutter pub run build_runner build` to regenerate adapters.

## Project-Specific Patterns
- **Attributes and Skills:** Defined in `lib/models/attribute.dart` and `lib/models/skill.dart`. Character logic is in `character.dart` and `character_viewmodel.dart`.
- **UI:** Each tab/screen is a separate widget in `lib/screens/`. Shared UI components are in `lib/widgets/`.
- **State Management:** ViewModels (in `lib/viewmodels/`) expose methods for updating character state, which are called from UI widgets.
- **Builder Pattern:** Character creation hints at a builder pattern (see comments in `character_viewmodel.dart`).

## Conventions
- Use explicit ViewModel methods for all state changes (do not mutate models directly in UI).
- Keep business logic out of widgets/screens; place it in ViewModels.
- When adding new persistent fields, update Hive adapters and rerun code generation.

## Integration & Dependencies
- Uses Hive for local storage (see `pubspec.yaml` for dependencies).
- Follows standard Flutter project structure for multiplatform (Android/iOS/web/desktop).

## Examples
- To add a new character attribute: update `attribute.dart`, `hive_attribute.dart`, and adapters, then expose it in `character_viewmodel.dart` and update UI in `attributes_tab.dart`.
- To add a new screen: create a widget in `lib/screens/`, add navigation in `main.dart` or relevant parent screen.

## References
- `pubspec.yaml`: dependencies and build config
- `lib/models/`: data structures and Hive integration
- `lib/viewmodels/`: business logic and state
- `lib/screens/`, `lib/widgets/`: UI
- `test/`: unit tests

---
For more, see the README or code comments. If a workflow or pattern is unclear, ask for clarification or check for recent conventions in the codebase.
