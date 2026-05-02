# Ambitions Beyond 3.0 Roadmap

Status: Continuity roadmap; represented operationally by the Ambitions 4.0 Execution Program
Date: 2026-05-01

## Purpose

This roadmap carries the Ambitions 3.0 product identity, evidence discipline,
and local-first trust posture into future work without silently replacing the
active 3.0 source of truth.

It is not a feature implementation batch, release approval, App Store plan, or
permission to supersede Ambitions 3.0 canon. Future canon must follow
`docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`.

## Operational Bridge

Beyond 3.0 remains the link-stable continuity name for these roadmap files. Active post-3.0 execution is now governed by `docs/canon/Ambitions_4_0_Execution_Program.md` and the 4.0 global execution order. Queued 4.0 batches are not implemented, not shipped, and not release-proven.

## Current Baseline

Ambitions 3.0 is the active source of truth. The current native app has Green
train evidence through F30. F27 passed after the F28 Goal Detail
trust/memory UI proof repair/rebaseline, F27.5 completed with no critical maintainability blocker, F29 created the final engineer handoff package, and F30 created the final closeout.

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

Status: formal Ambitions 4.0 train created; Product Depth train queued/blocked and not started.
Required approval phrase to start Product Depth train:
`Start Product Depth Train`.

Candidate depth:

- richer Today execution session continuity;
- Goal Detail path/proof/decision depth;
- Capture placement confidence and correction loops;
- Plan reflow and recovery decision quality;
- You-owned memory correction, export/import, and trust history;
- Reviews and proof history integration after the current local proof seams are
  stable.

Guardrail: do not create top-level Tasks, Habits, Insights, Calendar, or AI tabs.

Formal lane assets:

- `docs/canon/Ambitions_Product_Depth_Plan.md`
- `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md`
- `docs/codex/batches/PD01_Product_Depth_Canon_Inventory_And_Ownership_Map_Prompt.md`

PD01-PD18 remain queued/blocked and not started. Formalizing the lane does not start
Product Depth, PXOS, ME, CS, AOS, REC02, or app implementation.

### Lane 5: Codex Operating System Continuity

Goal: keep future trains reproducible and honest.

Required future-train setup:

- update `docs/codex/BATCH_REGISTRY.md` and `docs/codex/CONTEXT_INDEX.md`;
- create or select a manifest under `docs/codex/batch-trains/`;
- define Green/Yellow/Red gates before implementation;
- keep one active batch at a time unless explicitly authorized;
- stage, commit, and push each Green batch before continuing;
- preserve exact validation logs and stop on untrusted validation.



### Lane 6: Product Experience OS Future Canon

Goal: define the future user-facing product experience system before major
post-3.0 product-depth or intelligence UI implementation.

PXOS sits beside AmbitionsOS. AmbitionsOS owns internal future intelligence and
runtime architecture. PXOS owns how that intelligence appears to users through
surfaces, copy, navigation, interaction, trust, proof, recovery, accessibility,
visual hierarchy, and release-safe product messaging.

Status: future canon created; PXOS train queued/blocked and not started. Required approval
phrase to start PXOS train: `Start PXOS Future-Canon Train`.

## First Future Decision

Before any Ambitions 4.0 queued batch starts, choose one path:

- Release evidence closure if the next goal is external readiness.
- Maintainability extraction if the next goal is engineering durability.
- Product depth if the next goal is native experience growth.
- Future-canon authoring if a later product version is being introduced.

The default safest first move is Release Evidence Closure because it converts
existing train evidence into human/operator proof without changing product
behavior.

Status as of 2026-05-02: the pre-train hardening pass selected Release Evidence
Closure as the first post-F30 train and started REC01 Release Evidence Truth
Inventory. This is evidence/status work only. It does not start AOS, ME, CS,
Product Depth, or app implementation.

## Non-Goals

- No backend/account/sync expansion without explicit canon and dependency review.
- No new top-level navigation destinations.
- No silent memory or personalization behavior.
- No App Store/TestFlight/release-readiness claim by implication.
- No broad historical rewrite or deletion without archive-policy approval.

## AmbitionsOS Future-Canon Authoring Path

AmbitionsOS is added as a future-canon continuation plan under this roadmap. It is not current implementation truth, does not supersede Ambitions 3.0 by implication, does not create release approval, and does not start implementation automatically.

AmbitionsOS consolidates pending Goal Intelligence, Path Requirements, Path Evolution, Life Commitments, Daily Operating System, Calendar/Reminders replacement strategy, offline-first, source-truth, privacy, performance, local/on-device intelligence boundaries, maintainability extraction planning, compatibility seam retirement planning, and Codex OS continuity under one parent architecture:

- `docs/canon/AmbitionsOS_Index.md`
- `docs/canon/AmbitionsOS_Core_Architecture.md`
- `docs/canon/AmbitionsOS_Runtime_Contract.md`
- `docs/codex/AMBITIONSOS_AOS_TRAIN_CONTROL_SYSTEM.md`

Lane 2 now points to `docs/canon/Ambitions_Beyond_3_0_Maintainability_Extraction_Plan.md` and `docs/codex/batch-trains/ME01_ME12_MAINTAINABILITY_EXTRACTION_TRAIN.md`.

Lane 3 now points to `docs/canon/Ambitions_Beyond_3_0_Compatibility_Seam_Retirement_Plan.md` and `docs/codex/batch-trains/CS01_CS10_COMPATIBILITY_SEAM_RETIREMENT_TRAIN.md`.

Lane 5 now points to `docs/codex/AMBITIONS_CODEX_OS_CONTINUITY_PROTOCOL.md`, AmbitionsOS evidence/traceability protocols, reusable skills, review boards, and train-control assets.

AOS implementation is queued/blocked through `docs/codex/batch-trains/AOS01_AOS30_AMBITIONSOS_LOCAL_INTELLIGENCE_TRAIN.md`. The first post-F30 path selected by the 2026-05-02 pre-train hardening pass is Release Evidence Closure. Maintainability Extraction, Compatibility Seam Retirement, Product Depth, and AOS implementation remain not started unless explicitly activated later. Product Depth is formalized as `docs/codex/batch-trains/PD01_PD18_PRODUCT_DEPTH_TRAIN.md` and starts only with `Start Product Depth Train`.


## Post-F30 Activation Status

As of 2026-05-02, Ambitions 3.0 is complete by F30 closeout evidence and F17-F30 is historical Green train evidence. AmbitionsOS remains future canon, not current implementation truth. The first safe post-3.0 train selected after pre-train hardening is Release Evidence Closure, beginning with REC01 Release Evidence Truth Inventory. This activation does not start AOS, ME, CS, Product Depth, or any app implementation work. Product Depth is formalized as an Ambitions 4.0 queued train but remains blocked/not started.


## PXOS Future-Canon Path

PXOS is added as future user-facing product experience canon under this roadmap. It does not supersede Ambitions 3.0, does not claim implementation, does not start PXOS, and does not start REC02, AOS, ME, CS, or Product Depth. PXOS should exist before major user-facing implementation so future work has surface hierarchy, copy, visual, accessibility, trust, recovery, and release-claim gates.
