# Ambitions Beyond 3.0 Roadmap

Status: Future-canon continuation plan
Date: 2026-05-01

## Purpose

This roadmap carries the Ambitions 3.0 product identity, evidence discipline,
and local-first trust posture into future work without silently replacing the
active 3.0 source of truth.

It is not a feature implementation batch, release approval, App Store plan, or
permission to supersede Ambitions 3.0 canon. Future canon must follow
`docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`.

## Current Baseline

Ambitions 3.0 is the active source of truth. The current native app has Green
train evidence through F29, and F27 passed after the F28 Goal Detail
trust/memory UI proof repair/rebaseline.

Latest recorded local proof:

- `scripts/test-local.sh`: PASS, 779 unit tests and 29 UI tests.
- Full-suite log: `output/logs/test-local-20260501-220744.log`.
- `scripts/build-local.sh`: PASS on the `iPhone 17` simulator.
- Build log: `output/logs/build-local-20260501-224535.log`.

Claims still not made:

- physical-device verification;
- public accessibility conformance;
- TestFlight readiness;
- App Store submission readiness;
- final RC lock;
- signed archive/App Store Connect validation;
- rendered external-platform proof.

## Continuation Principles

- Preserve the top-level IA: `Today / Goals / Capture / Plan / You`.
- Preserve the core loop:
  `Capture -> Place -> Plan -> Do Today -> Close / Recover -> Save Proof`.
- Treat Ambitions as an intelligent life organization system, not an AI-wrapper
  product.
- Keep future canon explicit: source-of-truth override, documentation index,
  supersession map, migration plan, release claim state, and archive/update plan.
- Retire compatibility seams only after route, schema, widget, App Intent,
  import/export, persistence, and tests prove the replacement.
- Keep release claims evidence-bound.

## Roadmap Lanes

### Lane 1: Release Evidence Closure

Goal: convert internal simulator confidence into human/operator release proof.

Order:

1. Human operator review using `docs/handoff/Ambitions_3_0_Testing_And_Release_Proof.md`.
2. Physical-device install and smoke proof.
3. Manual VoiceOver, Dynamic Type, Reduce Motion, touch target, and cognitive-load review.
4. Rendered widget, Live Activity, Lock Screen, Dynamic Island, Shortcuts/Siri,
   and App Intent proof on platform surfaces.
5. Signed archive and App Store Connect validation.
6. TestFlight readiness decision.

Stop rule: no public release claim until the corresponding evidence exists.

### Lane 2: Maintainability And Extraction

Goal: reduce large-file and compatibility-seam risk without destabilizing
product behavior.

First refactor candidates:

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`

Preferred approach:

- extract projector/state/helper seams before adding behavior;
- protect behavior with focused product-contract tests;
- keep visible copy and route compatibility stable;
- avoid broad cleanup that mixes multiple feature owners.

### Lane 3: Compatibility Seam Retirement

Goal: intentionally retire old internal naming where it no longer protects
users, data, routes, widgets, App Intents, or imports.

Candidate seams:

- `Profile` internal naming behind the You surface;
- `Insights` route/model compatibility for contextual intelligence;
- `Habits` route/model compatibility for Ritual/Plan continuity;
- `activeFocus`, `TodayFocus*`, and `.focus` Today compatibility;
- internal `.failed` taxonomy where visible language already stays humane.

Retirement condition: each seam has a replacement map, migration impact review,
focused tests, and rollback path.

### Lane 4: Product Depth After 3.0

Goal: deepen the existing primitives instead of adding new top-level
destinations.

Candidate depth:

- richer Today execution session continuity;
- Goal Detail path/proof/decision depth;
- Capture placement confidence and correction loops;
- Plan reflow and recovery decision quality;
- You-owned memory correction, export/import, and trust history;
- Reviews and proof history integration after the current local proof seams are
  stable.

Guardrail: do not create top-level Tasks, Habits, Insights, Calendar, or AI tabs.

### Lane 5: Codex Operating System Continuity

Goal: keep future trains reproducible and honest.

Required future-train setup:

- update `docs/codex/BATCH_REGISTRY.md` and `docs/codex/CONTEXT_INDEX.md`;
- create or select a manifest under `docs/codex/batch-trains/`;
- define Green/Yellow/Red gates before implementation;
- keep one active batch at a time unless explicitly authorized;
- stage, commit, and push each Green batch before continuing;
- preserve exact validation logs and stop on untrusted validation.

## First Future Decision

Before any Beyond 3.0 implementation starts, choose one path:

- Release evidence closure if the next goal is external readiness.
- Maintainability extraction if the next goal is engineering durability.
- Product depth if the next goal is native experience growth.
- Future-canon authoring if Ambitions 3.1 or 4.0 is being introduced.

The default safest first move is Release Evidence Closure because it converts
existing train evidence into human/operator proof without changing product
behavior.

## Non-Goals

- No backend/account/sync expansion without explicit canon and dependency review.
- No new top-level navigation destinations.
- No silent memory or personalization behavior.
- No App Store/TestFlight/release-readiness claim by implication.
- No broad historical rewrite or deletion without archive-policy approval.
