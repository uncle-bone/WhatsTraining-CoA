# What's Training? CoA

> **[Download](https://github.com/uncle-bone/WhatsTraining-CoA/releases)**

A Conquest Reborn (WoW 3.3.5a) trainer tracker, adapted by **Uncle Bone** from the [What's Training?](https://github.com/fusionpit/WhatsTraining) interaction model.

This pre-release adds spellbook compatibility for Blizzard, Ascension, and DragonUI spellbook frames. It needs in-game validation across those UI configurations; tab placement and reopening behavior are not yet confirmed.

Open the spellbook and click its attached **?** tab. There is no permanent floating launcher.

## Current development features
- Spellbook-attached page with Available, Next Level, Upcoming, Requires and Known filters.
- Search and spell tooltips including verification status.
- Captures services actually observed at trainers, preserving per-character status and accumulating an offline catalog by custom class across the same SavedVariables account.
- Displays name, rank, required level, and cost when the client API supplies them.
- Recognizes the 21 custom Conquest of Azeroth class names.
- Does not transmit data or join chat channels.

## Evidence and limitations
The rank chains in [CoA-Research](https://github.com/uncle-bone/CoA-Research) are not proof of trainer assignments. Only captured trainer services are marked VERIFIED. Zero authoritative complete trainer-to-spell or pricing maps have yet been established. Past costs and availability may be outdated. Opening a trainer refreshes them. UI placement and trainer API compatibility need in-game verification.

## Installation
Extract the ZIP so that `Interface/AddOns/WhatsTraining-CoA/WhatsTraining-CoA.toc` exists. Open the spellbook and its ? tab. Visit trainers to build the catalog. Diagnostics: `/wtcoa status` and `/wtcoa scan`.

## Credits
Maintainer: [Uncle Bone](https://github.com/uncle-bone). Original: [fusionpit/WhatsTraining](https://github.com/fusionpit/WhatsTraining). WotLK port: [anhility/WhatsTraining_WotLK](https://github.com/anhility/WhatsTraining_WotLK). The upstream MIT license notice remains included.
