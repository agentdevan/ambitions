# Ambitions 3.0 As Current Baseline Policy

Status: Active Ambitions 3.0 repository baseline canon
Parent doc: [Ambitions 3.0 Source Of Truth Override](./Ambitions_3_0_Source_Of_Truth_Override.md)
Companion docs: [Human-Made Codebase Standard](./Ambitions_3_0_Human_Made_Codebase_Standard.md), [Active History Archive Policy](./Ambitions_3_0_Active_History_Archive_Policy.md)
Created: 2026-05-01

---

## Purpose

Ambitions 3.0 is the current product baseline.

The active repo should read as if Ambitions was built from the current canon as its foundation. A new engineer, designer, QA reviewer, or product reviewer should not need to know older launches, older tabs, older shell models, older batch names, or prior canon eras to understand the current app.

This policy does not erase implementation history. It controls how history may appear in active surfaces.

---

## Active Baseline Rule

Active guidance starts from Ambitions 3.0:

1. `README.md`
2. `docs/README.md`
3. `docs/canon/README.md`
4. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
5. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
6. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
7. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
8. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
9. `docs/canon/Ambitions_3_0_Product_Language_System.md`
10. target primitive, surface, state-machine, privacy, accessibility, QA, release, or dependency docs

Older docs may be referenced only as:

- historical evidence;
- archived or superseded context;
- still-binding older canon for domains Ambitions 3.0 does not replace;
- compatibility evidence for persisted routes, deep links, App Intents, widget payloads, or stored values.

Active implementation guidance must point to current canon first.

---

## Active Surface Rule

Active product, code, tests, roadmaps, and handoff docs should describe Ambitions directly in current language.

They should not read like migration notes from older concepts.

Allowed active references to older concepts must explain:

- why the reference remains;
- whether it is user-facing;
- who owns the seam;
- what test coverage protects it;
- what condition retires it.

---

## 3.0 Effectively Equals 1.0 Standard

For current comprehension, Ambitions 3.0 is treated as the clean baseline.

This means:

- active user-facing app copy must not expose legacy product language;
- active docs must describe the current product directly;
- handoff docs must not require knowing the rebuild journey;
- old names may exist only as safe compatibility seams;
- old launch names, old tabs, old shell models, and old batch history must not be presented as current product direction.

---

## Green Criteria

Baseline reset work is Green only when:

- active source-truth docs agree on Ambitions 3.0 as current baseline;
- active docs do not imply older canon is current;
- user-facing legacy language is removed or proven absent;
- retained compatibility seams are documented;
- historical evidence remains labeled as historical, archived, supporting, or compatibility-only;
- release, accessibility, privacy, device, and App Store claims stay evidence-gated.
