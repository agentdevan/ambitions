# Ambitions Master Codex System

This is standing behavior context for Codex sessions in the Ambitions repo.

Ambitions 3.0 is the active source of truth. This file is an operating guide, not product canon. When this file conflicts with Ambitions 3.0 canon, the 3.0 canon wins.

## Mandatory Context

Before non-trivial work, use this read order:

1. `README.md`
2. `docs/README.md`
3. `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
4. `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
5. `docs/canon/Ambitions_3_0_Rebuild_Operating_Model.md`
6. `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
7. `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
8. `docs/canon/Ambitions_3_0_Product_Language_System.md`
9. The target Ambitions 3.0 primitive, surface, state-machine, privacy, accessibility, QA, release, or dependency doc.
10. `docs/codex/BATCH_REGISTRY.md` for implementation status truth only.

Then choose:

1. one context pack from `.codex/context-packs/`,
2. one or more skills from `.codex/skills/`,
3. one operation protocol from `.codex/operations/`, and
4. one focused validation pack from `.codex/validation/`.

## Current Handoff Reality

The FAANG handoff audit is PARTIAL. Generated scratch artifacts were purged and active 3.0 indexes were improved, but the full UI test suite failed with 10 UI smoke failures, legacy-language hits remain, and internal identifier migration debt remains. Future Codex runs must treat those as active risks until fixed or intentionally rebaselined with evidence.

## Product Identity

Ambitions is a premium iPhone-native life execution system. It helps raw intent become placed structure, placed structure become believable plans, believable plans become one clear step, real life become closure, and progress become proof.

Core loop: `Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof`.

Canonical destinations: `Today / Goals / Capture / Plan / You`.

Ambitions is not a generic task app, calendar clone, habit tracker, productivity score app, chatbot, or AI-wrapper product.

## Default Workflow

1. Inspect repo state.
2. Reconcile Ambitions 3.0 source truth.
3. Classify the task and choose the narrowest context pack, skill, operation, and validation pack.
4. Plan the touch budget before edits when work spans multiple files or layers.
5. Implement additively and preserve compatibility.
6. Run focused validation first; broaden only when risk requires it.
7. Update docs/status truth only when evidence changed.
8. Close out with files changed, commands run, results, failed/not-run checks, risks, and next prompt.

## Claim Discipline

Do not claim implemented, tested, device-verified, release-ready, accessibility-verified, TestFlight-ready, App Store-ready, or FAANG-handoff-ready unless the repo evidence proves that exact status.
