# Title: YIT-002 Refactor categories for skills

## Linked Design Document
- `docs/design/YET-001 fighting-firearms-as-families.md` (follow-up)

## Context
- Current grouping logic in `SkillsTab` relies on parsing skill names (`"Science (Any)"`, regex for `(Any)`) and ad-hoc checks.
- This creates edge cases (groups without **Add** button, missing generics).
- We always know a skill’s **category** at creation; we can encode it directly and remove parsing.
- Generic family rows should be created as structured rows with consistent naming:
  - `"<Family> (Any)"`  
  - Exception: for the **Language** family, the generic is `"Language (Other)"`.
- Legacy skills are out of scope; no need to support them.

## Scope / Decision
- **Models**
  - Always set `category` on `Skill` instances when they belong to a family.
  - Generic rows:
    - `category = <Family>`
    - `specialization = null`
    - `name = "<Family> (Any)"` (or `"Language (Other)"` for Language).
    - `canUpgrade = false`
  - Specialized rows: `category = <Family>`, `specialization = "<Spec>"`, `name = displayName(...)`.
- **CreationRuleSet**
  - Seed generic rows for: Science, Art/Craft, Pilot, Survival, Firearms.
  - Seed Language generic row as `"Language (Other)"`.
  - Keep specialized defaults (Fighting Brawl, Firearms Handguns & Rifle/Shotgun).
  - Remove legacy entries (`"Science (Any)"`, `"Firearms (Any)"`, etc.) from `fixed` map.
- **CharacterViewModel**
  - `_applyClassicToCurrentCharacter`: do not rebuild skills.
  - When adding a specialization, set `category` and `specialization` explicitly.
  - When ensuring generics, add `"<Family> (Any)"` or `"Language (Other)"`.
- **UI (SkillsTab)**
  - Group strictly by `category`.
  - Generic row = `s.category == family && s.specialization == null`.
  - Specs = `s.category == family && s.specialization != null`.
  - Families always exist because generics are seeded; in **Draft** mode, **Add** button always visible.
  - Remove `familyCategoryOf`, `findGenericForCategory`, legacy `(Any)` parsing.

## Files to change
- `lib/models/creation_rule_set.dart`
- `lib/viewmodels/character_viewmodel.dart`
- `lib/screens/skills_tab.dart`
- `lib/models/skill.dart` (if needed to adjust `displayName` for `(Any)` logic)

## Acceptance Criteria
- New Classic draft contains:
  - `Science (Any)`, `Art/Craft (Any)`, `Pilot (Any)`, `Survival (Any)`, `Firearms (Any)`, `Language (Other)`.
  - `Fighting (Brawl)`, `Firearms (Handguns)`, `Firearms (Rifle/Shotgun)` seeded.
- Each family renders with at least one row (generic).
- Add button is present for all families in Draft, even if no specializations exist.
- No code path parses skill names for categories when displaying specialized gorups in UI.
- Unit tests updated:
  - Verify generics seeded correctly.
  - Verify Language generic is `"Language (Other)"`.
  - Verify grouping in SkillsTab is category-based only.

## Risks
- Breaking existing saved characters that rely on legacy `(Any)` names without category.
- Accepted: no legacy support required.

## Rollback
- Revert to old grouping/parsing functions (`familyCategoryOf`, legacy `(Any)` detection).
