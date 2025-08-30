# Yithian App Roadmap

This file contains short description of all features planned or implemented in scope of the project.
The items are listed in the order of priority for the project, descending.

---

## Status vocabulary (use consistently)

**Proposed · Planned · In Progress · Blocked · On Hold · Done · Superseded · Rejected**

---

## Must Have
- Turn Fighting and Firearms into categories of specialized skills
    Context: Currently we have Fighting (Brawl), Firearms (Handguns) and Firearms (Rifle/Shotgun) as separate skills without possibilities to add more specializations. Let's make them categories like "Art/Craft", "Science", "Language". 
    Status: planned
    Notes: No need to update or improve the current logic of specialization skills, it will be changed later in scope of Custom Skills feature. Make sure that skills Fighting (Brawl), Firearms (Handguns) and Firearms (Rifle/Shotgun) are added automatically.

- Freestyle Creation Method
  Context: the user should be able to create a character using free rules similar to dholehouse.com Freestyle method
  Linked Design docs: 
  Status: Planned
  Notes: should be available along with the Classic creation method, should not interfere with it. Should follow the same flow, as Classic method - Creation Screen that allows to setup and adjust all the parameters, it creates draft Character which is then edited additionally by user.

## Good to Have
- Add Edit mode to Skills tab
    Context: in normal mode widgets like Add specialization skills are hidden. But sometimes during the game it's needed to add new specialization or custom skill. For these cases we should introduce new Edit mode that makes these changes possible.
    Status: planned 

- Dice Roller Screen - add possibility to spend Luck after rolls
  Context: it's a useful feature for the regular use
  Status: Planned
  Notes: give user more freedom and ignore the traditional rules for when they can use it or not. Make it available for all d100 rolls.

- Point-Buy Creation Method
  Context: the user should be able to create a character using point-buy rules
  Status: Planned
  Notes: should follow the same flow as Classic and Freestyle methods.

- Classic Creation Method update
  Context: improve the Classic creation method by providing the following changes for Attributes:
    - reassign rolled values to the other attributes
    - introduce attribute points pool that is used when the user decreases and increases values of attributes
    - on the Creation screen it is not allowed to increase the attribute if there's not enough points in the pool
    - after the draft is created this pool is not available and attributes work as usually in this mode
  Status: Planned
  Notes: attribute points pool would be probably introduced in Freestyle Creation Method already. In any case it should adhere the CoC 7ed rules here.

- Indefinite insanity support
  Context: the user should be able to see current indefinite insanity value (80% of Sanity at the beginning of the day) and update it at any points
  For future consideration: changing Sanity may trigger reaching this state automatically.
  Status: planned

- Biography field
  Context: there's no special field for Biography (or Backstory) for the character on the Background tab. Should be added
  Notes: should work exactly as all other fields on Background tab.
  Status: Planned

- Research: Mobile Version
  Context: Flutter allows to deploy the app to the mobile platforms. We should investigate how difficult it would be.
  Notes: research task. The output should be new roadmap items that describe the steps necessary for mobile version. We should consider how the app works on different Android and IPhone devices, what additional mobile features could be used or adjusted to. We should investigate what we have to do with the UI layouts to make them work properly.
  Status: Planned

- Research: Web Version
  Context: Flutter allows to deploy the app to the web platform. We should investigate how difficult it would be.
  Notes: research task. The output should be new roadmap items that describe the steps necessary for the web-version. We should consider how the app works on different browsers, what additional web features could be used or adjusted to. We should investigate what we have to do with the UI layouts to make them work properly.
  Status: Planned

- General UI improvements:
  Context: there are several ideas how to improve the UI:
    - change cursor and add other visual highltghts to the clickable elements like skills.
  Status: planned

- Custom skills
  Context: to provide max flexibility and to comply with popular practices we have to allow user to create their own skills at any time.
  Notes: the more I think about it the more I understand that specialized skills are just custom skills. This could make the whole system a bit easier.
  Status: proposed

- Training checkbox for skills
  Context: as a user I want to mark my skills as Available For Training. I may also want to set it automatically when the skill is tested successfully.
  Status: proposed

- Undo/Redo functionality
  Context: undo/redo functionality makes the app usage much more convenient. We should be able to undo each change 
  Status: proposed

- PDF export:
  Context: generate PDF with character sheet based on the current character
  Note: the PDF should be as close to the standard character sheet as possible
  Status: proposed

- Different settings
  Context: add support for other settings (Modern, Gaslight, Regency etc.)... 

## Could Have
- Hints for attributes and skills
  Context: Hints for attributes and skills (both attributes tab, skills tab and creation screen) that explains the numbers thematically (according to the table in CoC 7ed rules).
  Status: Proposed

- Add a button to switch from Classic Creation method to Freestyle method
  Context: At some point the user may decide they want to keep current results in Classic method but then switch to Freestyle method to avoid some rules constraints.
  Notes: not sure if this feature is necessary. The user may just finish current character creation and update anything without any problems in normal mode
  Status: Proposed

- Fight tab
    Context: as a user I want to manage fighting scenes easily. I want to have a quick access to the necessary skills and their rolls, my HP and damage rolls. I also want to manage my firearms easily - ammo, reloads, malfunctions, autofire/bursts etc. I want all UI to be presented on one single tab, including rolls.
    Status: Proposed

- Support optional creation rules from the official rulebook
    Context: most of the rules are already implemented in scope of other features. Analyze the rulebook and implement the optional rules that are missing.
    Status: Proposed

- Folders in characters list
    Context: currently all the characters are displayed in one single list. Allow possibility to create folders for them to group characters. Folders can be nested.
    Status: proposed

- Add portrait image
    Context: add possibility to load picture file as a portrait on the info tab.
    Status: proposed

- Character file-synchronization
    Context: allow synchronization through cloud on different devices. Analyze possible solutions, add new roadmap items for implementation
    Status: proposed

- Gear and Weapons database
    Context: gather the database of different gear and weapons, mentioned in rulebook and other materials. Easily search, filter and add to character's gear.
    Status: proposed

- Scan paper character sheet
    Context: allow converting real character sheets from photos into the app
    Status: proposed

- Import pdf's
    Context: convert existing pdf character sheet into the app
    Status: proposed

- Import json from dholehouse.org

---

## Completed
- [x] Finished Feature (with link to design/task).  
