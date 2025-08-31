# YIT-002: refactor categories for skills

## Status
[Accepted]

## Context
- We have to simplify the way categories for specialized skills are set
- This is a follow-up for YET-001

## Decision
- We always know the category when the skill is created. For default skills we can hardcode this. Later on only the specialized skills are created and we know their category.
- Change how Skill instances are created in CreationRuleSet and CharacterViewModel. Change how new specialization Skill is added in CharacterViewModel
- No need to support legacy versions and old character sheets. No need to parse skill names.

## Consequences
- **Positive:** This should improve and simplify the UI for specialized skills
- **Negative:** delete support of legacy skills

## Follow-ups
- [+] Code changes required (files/modules).  
- [ ] Update roadmap
- [ ] Update assets
- [+] Add or update unit tests.  

## References
- Related YITs: [YIT-001]  
