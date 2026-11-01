# What's Training? CoA

A Conquest Reborn (WoW 3.3.5a) trainer-spell tracker inspired by [fusionpit/WhatsTraining](https://github.com/fusionpit/WhatsTraining).

## Usage

A **small floating book button** opens a separate movable training window. Click to toggle it; drag to reposition it; right-click to hide it. The button position is saved. Type `/wtcoa button` to show a hidden button again.

Visit a class trainer and the addon records its visible training services for the current character. The window offers **All**, **Available**, **Next Level**, **Upcoming**, **Requirements**, and **Learned** filters, with spell icons, tooltips, level requirements, and costs when the client provides those fields.

## Installation

Download [v1.3.1-dev ZIP](https://github.com/uncle-bone/WhatsTraining-CoA) or use the packaged addon, and extract the `WhatsTraining-CoA` folder into `Interface/AddOns`. The TOC must be `WhatsTraining-CoA/WhatsTraining-CoA.toc`.

## Accuracy and compatibility

Supports a class registry for 21 custom classes. Designed as a standalone window to avoid conflicts with Blizzard, DragonUI and ElvUI frames. **Not yet verified in-game.** The 13,311 archived spell-rank records do not establish class or trainer assignment and are kept as research, not shown as verified trainable spells. The future-spell catalog can only become complete with authoritative trainer assignments.

## Commands (fallback / diagnostics)

- `/wtcoa` – toggle the window.
- `/wtcoa button` – restore the floating icon.
- `/wtcoa scan` – scan a currently open trainer.
- `/wtcoa status` – show observed trainer count.

## Maintainer, attribution, license

CoA adaptation maintained by **Uncle Bone**. Contact: https://github.com/downingwow. Inspired by [What's Training? by fusionpit](https://github.com/fusionpit/WhatsTraining), MIT-licensed; third-party license notices in the package remain intact.

Version: **1.3.1-dev**.