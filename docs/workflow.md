# Yithian App — Workflow

> This document captures how we collaborate and what to expect at each step.

---

## Document types & ownership

- **Roadmap** (`docs/roadmap.md`) — *Owner: You*
  - Backlog and status tracking (Proposed → Planned → In Progress → Blocked/On Hold → Done/Superseded/Rejected).
- **ADR** (`docs/adr/adr-XXX_short-title.md`) — *Owner: Feature Designer → approval by You*
  - One-page decision record: *why this approach*.
- **Task** (`docs/tasks/task_short-title.md`) — *Owner: Feature Planner → approval by You*
  - Implementation plan: *what to change, where, and how to validate*.
- **Code & Tests** (`lib/**`, `test/**`) — *Owner: Feature Implementer / Bug Fixer*

**Linking:** Roadmap item ↔ ADR(s) ↔ Task(s) ↔ Code/Tests.


---

## Role 1 — Feature Designer

**Input:** A roadmap item (with your comments/constraints).

**Steps:**
1. **Frame the problem** and constraints (rules, UX, storage, performance).
2. **Propose solution(s):**
   - If simple/obvious → propose **one** solution.
   - If complex/ambiguous → propose **2–3** options with pros/cons and risks.
3. **Discuss** options with you; adjust per feedback.
4. **Recommend** one option and call out trade‑offs.
5. **Produce ADR** draft (Context → Decision → Alternatives → Consequences → Follow‑ups).

**Output:** ADR document (status **Proposed**), link from the roadmap item (you may update roadmap).

**Definition of Done (DoD):** ADR status **Accepted** by you and linked from the roadmap.

---

## Role 2 — Feature Planner

**Input:** An **Accepted ADR** to implement.

**Steps:**
1. **Derive a technical plan** aligned to the ADR (data model, services, viewmodels, screens, widgets).
2. When meaningful, present **alternatives** (only if trade‑offs exist) and recommend one.
3. **Enumerate atomic tasks** (preferably one file per task, but not strictly required).
4. For each task, write a **Task document** including:
   - Title (imperative), **Linked ADR**, Scope, Rationale (short),
   - **Files to create/modify** (exact paths),
   - **Detailed steps** (ready for implementation),
   - **Acceptance criteria** (user‑visible and programmatic),
   - **Tests** to add/adjust (unit/widget),
   - **Risk/rollback** notes (if applicable).
5. **Review with you**; incorporate feedback.

**Output:** One or more **Task** documents (status **Planned**), linked from the ADR.

**DoD:** You approve the task set; paths and acceptance criteria are unambiguous.

---

## Role 3 — Feature Implementer

**Input:** A **Task document**.

**Rules of engagement:**
- **No placeholders.** If current code is needed, **request the exact files**. Do not invent missing code.
- Provide **ready‑to‑paste** outputs: full file contents or precise fragments as specified by the task.
- Keep architecture conventions (Provider/MVVM, imports via `package:`, no snackbars, constants, locking of derived fields, etc.).

**Steps:**
1. **Request any missing source files** required by the task.
2. **Generate code** file‑by‑file (new or updated), ready to paste.
3. **Fix compiler & linter issues** surfaced after the change.
4. **Add unit/widget tests** when applicable (per Task doc).
5. **Fix test compilation issues** and **ensure tests pass**.
6. **Summarize changes** and update links back to the Task.

**Output:** Updated/new code files + tests, passing locally.

**DoD:** Project compiles; lints pass (as configured); tests for the change pass; acceptance criteria in Task are met.

---

## Role 4 — Bug Fixer

**Input:** Error messages and your description; related ADRs; relevant source files.

**Steps:**
1. **Request missing context** (logs, stack traces, involved files).
2. Provide an **initial analysis** with 2–3 plausible root causes.
3. Propose **targeted debug output** or a minimal **repro step** if root cause isn’t clear.
4. **Analyze new evidence** and state the most likely root cause.
5. **Propose a fix** (smallest viable change) with ready‑to‑paste code.
6. **Validate**: compile, adjust/add tests if needed, confirm behavior.
7. Iterate until the **fix is confirmed**.

**Output:** Patch (and tests if appropriate), plus a short root‑cause explanation.

**DoD:** Repro is gone; tests pass; rationale documented in the Task/bug note.

---

## File conventions

- **ADR:** `docs/adr/adr-###_short-title.md` (stable ID, kebab‑case title)
- **Task:** `docs/tasks/task_short-title.md`
- **Structure:** `docs/structure.md` (generated)
- **Project overview:** `docs/project.md`

---

## Handoff rules & approvals

- You maintain the **roadmap** statuses; ADRs/Tasks link back to the relevant item.
- **Approvals:**
  - ADRs and Task sets require your approval before implementation.
  - Implementer and Bug Fixer proceed within the approved scope.

---

## Quality gates

- **Build:** No compilation errors/warnings per configured lints.
- **Tests:** New/affected tests pass; avoid flakiness.
- **UX/Rules:** Derived values auto‑update; calculated fields remain locked where defined; navigation contracts (e.g., tap label → dice roller) hold.

---

## Collaboration notes

- When code context is missing, the assistant **asks for exact files** before writing changes.
- Prefer **small, atomic tasks** for easier review and safer integration.
- Keep ADRs concise; put implementation detail into **Tasks**.

