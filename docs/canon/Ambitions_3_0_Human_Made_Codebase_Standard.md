# Ambitions 3.0 Human-Made Codebase Standard

Status: Active Ambitions 3.0 engineering / handoff canon
Parent doc: [Ambitions 3.0 As Current Baseline Policy](./Ambitions_3_0_As_Current_Baseline_Policy.md)
Architecture companions: [SwiftUI State Contract Architecture Standard](./Ambitions_3_0_SwiftUI_State_Contract_Architecture_Standard.md), [Feature Boundary And File Size Constitution](./Ambitions_3_0_Feature_Boundary_And_File_Size_Constitution.md)
Created: 2026-05-01

---

## Purpose

Ambitions should feel intentionally architected by a senior native product team.

The active codebase must not read like accumulated prompts, migration fragments, or unlabeled historical layers. It may preserve compatibility, but compatibility must be understandable.

---

## Standard

Human-made code in Ambitions has these properties:

- feature folders have clear ownership;
- screens own composition and navigation handoff;
- view state owns renderable facts;
- projectors translate domain/service facts into view state;
- views render state and send typed actions;
- compatibility seams are named, owned, and tested;
- tests protect product contracts rather than stale layout trivia;
- comments explain architecture or compatibility, not prompt history;
- reports record evidence without hype, fake certainty, or release overclaiming.

---

## Compatibility Seam Requirements

Compatibility seams may remain when they protect:

- persisted route values;
- deep links;
- App Intent identifiers;
- widget or Live Activity payload schemas;
- share extension routing;
- stored command values;
- historical import/export compatibility.

Every retained seam must have:

- reason retained;
- owner;
- user-facing exposure status;
- retirement condition;
- test coverage or a documented test gap.

---

## Naming And Comments

New code should use current Ambitions 3.0 product language where practical.

Legacy names may remain only when:

- changing them would break wire, persistence, or platform compatibility;
- the migration is too broad for the current batch and is tracked;
- a compatibility alias is safer than a destructive rename.

Comments should explain why the seam exists and what would retire it. They should not narrate prompt instructions or old batch history.

---

## Handoff Readability

A senior iOS/product engineer should be able to:

- build the app;
- find the active source truth;
- identify each canonical destination owner;
- add a feature through a primitive and feature folder;
- add or modernize tests without weakening product promises;
- preserve privacy, accessibility, release, and compatibility truth.

If a file or folder blocks that first-hour comprehension, the batch report must classify it as maintainability debt and either fix it or route it to F27.5/F28.
