# Yithian App — Project Overview (`project.md`)

This document captures the stable, project‑wide context I need to design, plan, and implement features without guesswork. It complements the living roadmap and Design/Task files.

---

## Documentation map (start here)

**project.md** — This file. High‑level purpose, scope, architecture, rules, coding/testing standards, and project‑wide constraints. The stable reference for design/implementation.

**workflow.md** — How we work together: roles, step‑by‑step workflows, approvals, definitions of done, and how Design/Tasks connect to the roadmap.

**structure.md** — Auto‑generated code map (by tool/gen_structure.dart): files, classes, enums, public APIs, and private type names. Read‑only; regenerate to keep it fresh.

**roadmap.md** — Backlog and priorities (maintained by you). Contains statuses and links to Design/Tasks; not an implementation spec.

## Source code location

Source code is located in public repository https://github.com/EugenePopovych/yithian

---

## 1) Purpose & Scope

- **Goal:** A Call of Cthulhu 7e companion focused on **character creation** and **character sheet** management with optional quality‑of‑life tools (dice roller, occupations data).
- **Primary flows:**
  - **Character creation** (currently Classic; roadmap: Freestyle and Point‑Buy).
  - **Character sheet editing** (post‑creation, normal mode).
  - **Dice roller** (plain/ad‑hoc + skill rolls; roadmap: Luck spending on d100 results).
- **Target users:** Keepers/Players who want a fast, rules‑aware digital sheet.

---

## 2) Product Principles

- **Rules‑aware, not rules‑police:** Enforce RAW where it helps; allow house rules where it improves UX.
- **Draft → Final model:** Creation happens in a draft state; after finalization, only lawful edits are allowed, and calculated fields remain locked.

---

## 3) Platforms & Distribution

- **Flutter (stable channel)** targeting: Android, iOS, Web, Desktop (where feasible).
- **Theming:** `theme_light.dart` and `theme_dark.dart` exist; default is readable, high‑contrast dark preferred for play.

---

## 4) Architecture

- **Pattern:** Provider + MVVM.
  - **Models:** `lib/models/*` — domain entities (Character, Attribute, Skill, Occupation, etc.).
  - **ViewModels:** `lib/viewmodels/*` — presentation logic (e.g., `CharacterViewModel`, `CreateCharacterViewModel`, `DiceRollingViewModel`).
  - **Services:** `lib/services/*` — persistence (`CharacterStorage`, `HiveCharacterStorage`), data sources (`OccupationStorage*`), IDs (`SheetIdGenerator`).
  - **UI:** `lib/screens/*`, `lib/widgets/*` — screens compose widgets; widgets are stateless where possible.
- **Creation engine:**
  - **Rule sets** under `models`: `CreationRuleSet` (base), `ClassicCreationRuleSet` (implemented), with helper mixin `SkillPointPools`.
  - **Routing:** `CreationRules.forStatus(SheetStatus)` returns a rule set given sheet status; add Freestyle/Point‑Buy here.
- **State:** Keep logic in ViewModels; Widgets remain thin. Use `ValueNotifier`/`ChangeNotifier` for reactive bits already present.
- **Derived stats & rolls:** `classic_rules.dart` provides HP/MP/Sanity/Move and damage bonus calculations and dice utilities.

---

## 5) Data & Persistence

- **Local storage:** Hive via `HiveCharacter`, `HiveAttribute`, `HiveSkill` mappers and `HiveCharacterStorage` service.
- **Schema notes:**
  - `services/hive_init.dart` defines `Schema.current` and meta keys; migrations must be explicit in Design/Tasks.
  - When adding or changing fields in `Character`, mirror in `HiveCharacter` and mapping methods.
- **Reference data:** Occupations via `OccupationStorageJson` (asset path `kDefaultOccupationsAsset`) with a `kCurrentSchemaVersion` guard.

---

## 6) Domain Rules (CoC 7e)

- **Attributes:** STR, CON, DEX, APP, INT, POW, SIZ, EDU (`AttrKey.all`).
- **Derived values:**
  - HP from CON/SIZ; MP from POW; Sanity from POW; Movement from STR/DEX/SIZ and Age.
  - Damage Bonus/Build from STR+SIZ.
  - Age effects may alter attributes and EDU checks (see `classic_rules.dart`).
- **Skills:**
  - Base values provided by rules; some are **specialized families** (Art/Craft, Science, Language(Other), Pilot, Firearms).
  - Helper: `SkillSpecialization` offers `parse`, `displayName`, `isOfFamily`, and `families`.
- **Creation modes:**
  - **Classic:** Roll attributes; allocate occupation/personal skill points; credit rating range enforced.
  - **Freestyle (roadmap):** No constraints; user sets attributes/skills freely.
  - **Point‑Buy (roadmap):** Fixed pools for attributes/skills; RAW‑compatible optional rule.

---

## 7) UX & Interaction Standards

- **Navigation:** `MainScreen` tabs for List/Sheet/Roller/Settings; `ScreenNavBar` controls.
- **Creation screens:** Inline feedback is preferred (`InlineCreationFeedback`).
- **Stat rows:** `StatRow` displays base/hard/extreme; tapping label can open Dice Roller with context (skill name + thresholds).
- **Consistent sizing:** Use shared constants (e.g., `kStatRow*` sizes) for layout stability.
- **Accessibility:**
  - High contrast and large tap targets in play views.
  - Avoid fine text for critical numbers; use spacing (`kStatRowMetricWidth`) instead of color alone.

---

## 8) Coding Standards

- **Imports:** Use `package:coc_sheet/...` absolute imports; avoid relative `..` imports except within same small module when justified.
- **Nullability:** Prefer non‑nullable with required parameters; explicit optionals.
- **Names:** Kebab‑case for files, UpperCamel for types, lowerCamel for members; private fields start with \_, private functions don't start with \_.
- **No placeholders:** If code context is missing, request the exact files before writing changes.

---

## 9) Testing Standards

- **Where:** `test/**` for unit and widget tests.
- **Focus areas:**
  - public interfaces of model and viewmodel classes
  - correct CoC 7ed rules implementation
- **Style:**
  - Deterministic tests (seed RNG where used);
  - avoid time‑based flakiness.
  - Don't implement the rules logic in the tests. Use static hardcoded expected values instead (but put the rules in comments to explain these expected values).

---

## 10) Documents & Workflow

- **Roadmap:** Maintained by owner (you). Status vocabulary: Proposed · Planned · In Progress · Blocked · On Hold · Done · Superseded · Rejected.
- **Design Documents:** One page; Context → Decision → Alternatives → Consequences → Follow‑ups. Accepted design document gates implementation.
- **Tasks:** From an Accepted Design Document, enumerate atomic tasks (ideally one file per task), including: files to change, steps, acceptance criteria, and tests.
- **Execution roles:** Feature Designer → Feature Planner → Feature Implementer → Bug Fixer (see `workflow.md`).

---

## 11) Known Gaps & Roadmap Hooks

- **Creation modes:** Add `FreestyleCreationRuleSet` and `PointBuyCreationRuleSet`; wire in `CreationRules.forStatus` for `draftFree` / `draftPoints`.
- **Indefinite Insanity threshold:** Add to `Character` + Hive mapping; surface in UI with daily reset helper.
- **Dice Roller Luck:** Provide post‑roll Luck spending workflow; coordinate with `CharacterViewModel.updateLuck`.
- **Duplicate typedef:** Unify `typedef SheetId = String` into a single `types.dart` and re‑export.
- **Occupation data singleton:** Reconcile `OccupationStorageJson.instance` with constructor requirements (asset path).

---

## 12) Tooling & Automation

- **Structure map:** `docs/structure.md` is generated by `tool/gen_structure.dart` (analyzer‑based, v0.5+). Run:
  ```bash
  dart run tool/gen_structure.dart
  ```
- **CI (optional):** Regenerate `docs/structure.md` on push; fail if diff exists to keep docs fresh.

---

## 13) Performance & Quality Targets

- **Startup:** Hive init should be fast; perform adapters/register in a single pass (`initHive()`).
- **UI:** Avoid jank on list/sheet updates; prefer batching ViewModel notifications.
- **Data:** Keep character lists streaming (`charactersStream`) without heavy transformations in the UI.

---

## 14) Privacy & Offline Behavior

- **Default:** All data local; no network calls required for core features.
- **Exports/Imports (future):** Any sharing features must be opt‑in and documented in an Design Document.

---

## 15) Contribution Notes (for assistant)

- Never invent missing code; always **ask for the specific files** needed.
- Provide **ready‑to‑paste** full files or precise fragments.
- **Small, clear steps:** Features land as Design Document → Task(s) → atomic code changes (ready‑to‑paste) with tests.
- When adding fields/models, update Hive mappers and migrations and adjust tests accordingly.
- Keep documents linked: Roadmap ↔ Design Document ↔ Task ↔ Code/Tests.

