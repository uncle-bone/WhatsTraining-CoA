# What's Training? CoA

A Conquest Reborn (WoW 3.3.5a) trainer tracker adapting the original [What's Training?](https://github.com/fusionpit/WhatsTraining) interaction model.

**Use the ? tab attached to the spellbook. There is no permanent on-screen floating button.** Open the spellbook, click the ? icon on its right edge, and view categorized trainer spells with costs and spell tooltips.

## Functionality

- Spellbook-attached trainer view (Available, Next Level, Upcoming, Requires, Known).
- Captures observed services from class trainers per character; retains them in SavedVariables.
- Displays spell name, rank, level, cost and tooltip when available from the modified 3.3.5a client.
- Includes all 21 custom Conquest of Azeroth class names in the class registry.
- Does not transmit chat messages or replace other addon channels.
- Intended for Blizzard UI, DragonUI and ElvUI; live compatibility testing is still necessary.

## Limitations

The 13,311 rank records extracted from local client data do not prove trainer/class assignments. Until the trainer assignments are verified, future spells not yet observed cannot be displayed comprehensively. In-game API compatibility and UI overlap need verification.

## Installation

Extract `WhatsTraining-CoA` into `Interface/AddOns`, ensuring the addon contains `WhatsTraining-CoA.toc` directly inside. Open the in-game spellbook, then its ? tab. Open a trainer to populate observations. Diagnostics: `/wtcoa status` and `/wtcoa scan`.

## Credits and license

CoA adaptation: **Uncle Bone** ([contact](https://github.com/downingwow)). Original: [fusionpit/WhatsTraining](https://github.com/fusionpit/WhatsTraining). WotLK port: [anhility/WhatsTraining_WotLK](https://github.com/anhility/WhatsTraining_WotLK). Preserve existing upstream MIT license notices.
