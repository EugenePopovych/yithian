# YET-001: Fighting and Firearms as Specialized Skill Families

## Status
Accepted

## Context
- **Problem:** In the current system, *Fighting (Brawl)*, *Firearms (Handguns)*, and *Firearms (Rifle/Shotgun)* exist as standalone skills. They are not treated as families, so users cannot add new specializations like *Fighting (Axe)* or *Firearms (SMG)*.
- **Rules:** Call of Cthulhu 7e defines Fighting and Firearms as *skill families* (open categories). Other families already supported: Art/Craft, Science, Language (Other), Pilot.
- **Architecture:** Our `SkillSpecialization` model supports families and specializations, and persistence (`HiveSkill`) already has `category` + `specialization`. No schema change needed.
- **Roadmap link:** [Roadmap.md](../roadmap.md#must-have) → "Turn Fighting and Firearms into categories of specialized skills":contentReference[oaicite:1]{index=1}.
- **Constraints:**  
  - Must seed *Fighting (Brawl)*, *Firearms (Handguns)*, and *Firearms (Rifle/Shotgun)* automatically (to preserve expected defaults).  
  - No change to specialization logic beyond adding families.  
  - Occupation data may need alignment (if occupations explicitly reference e.g. "Firearms (Rifle/Shotgun)").

## Decision
- Add `familyFighting` constant to `SkillSpecialization`, alongside existing `familyFirearms`.
- Extend `SkillSpecialization.families` to include Fighting.
- Update seeding logic (`CreationRuleSet.seedClassicSkills`) to:
  - Auto-add Fighting (Brawl).  
  - Auto-add Firearms (Handguns).  
  - Auto-add Firearms (Rifle/Shotgun).  
- UI: SkillsTab “Add Specialization Skill” menu includes Fighting as selectable family (like Art/Craft).
- Persistence: No schema change, existing `HiveSkill` supports category/specialization.

## Alternatives Considered
- **A. Keep Fighting as only Brawl (no family):**  
  → Rejected: not RAW compliant; prevents representation of weapons like axe/sword.
- **B. Add custom skills feature now:**  
  → Rejected: scope creep; covered by separate roadmap item “Custom Skills”.
- **C. Hardcode additional variants (Fighting: Axe, Sword, etc.):**  
  → Rejected: inflexible, not scalable, diverges from specialization framework.

## Consequences
- **Positive:**  
  - Aligns with CoC 7e rules (RAW).  
  - Consistency: Fighting/Firearms behave like other families.  
  - Easy extensibility: users can add specializations as needed.  
- **Negative:**  
  - Skill list may become longer; requires user discipline.  
  - Occupation JSONs may need double-check to ensure references align.  
- **Rules compliance:** RAW compliant.  
- **UX impact:** Seamless; users already familiar with specialization UI.  
- **Persistence impact:** None; Hive already supports. No migration needed.

## Follow-ups
- [ ] Add `familyFighting` to `SkillSpecialization`.  
- [ ] Update `families` list.  
- [ ] Update seeding in `seedClassicSkills`.  
- [ ] Adjust UI: include Fighting in specialization picker.  
- [ ] Unit tests: ensure defaults exist in fresh Classic character.  
- [ ] Cross-check Occupation JSON references (may need explicit Firearms/Fighting entries).  

## References
- Roadmap: "Turn Fighting and Firearms into categories of specialized skills":contentReference[oaicite:2]{index=2}  
- Project overview: Skills and specialization model:contentReference[oaicite:3]{index=3}  
- CoC 7e Rulebook: Skills chapter (Fighting & Firearms families).
