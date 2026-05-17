# Ambitions 3.0 — FAANG Handoff Readiness Gate

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Documentation System Index](./Ambitions_3_0_Documentation_System_Index.md)  
Repo hygiene policy: [Ambitions 3.0 Repo Hygiene And Active Canon Policy](./Ambitions_3_0_Repo_Hygiene_And_Active_Canon_Policy.md)  
Last updated: 2026-04-30

---

## Purpose

This gate defines what must be true before the Ambitions repository can be handed to a world-class external product/engineering team and reasonably completed without additional founder explanation.

This is not a vibe check. It is an evidence gate.

---

## Current Status

The repository is not handoff-complete until every acceptance category in this document is proven with repository evidence.

A cleaner README, better source order, and active 3.0 canon are necessary but not sufficient.

---

## Handoff-Complete Definition

The repo is FAANG-handoff ready only when a new team can:

1. Understand what Ambitions is.
2. Understand what Ambitions is not.
3. Know the active source of truth without asking the founder.
4. Build and run the app.
5. Run tests.
6. Know which features are implemented, planned, partial, deferred, or explicitly out of scope.
7. Continue the Ambitions 3.0 build sequence from documented batches.
8. Identify every canonical destination, object, state machine, user action, and receipt/proof flow.
9. Avoid legacy language and historical drift.
10. Verify release readiness using evidence, not assumptions.

---

## Gate 1 — File Inventory

A complete tracked-file inventory must exist.

Required artifact:

```text
docs/audits/faang-handoff-file-inventory.csv
```

Each tracked file must be classified as exactly one of:

| Class | Meaning |
|---|---|
| active-code | Used by app, packages, tests, widgets, app intents, persistence, services, previews, or CI. |
| active-canon | Current 3.0 or still-binding canon. |
| implementation-control | Codex/batch/build/release workflow file. |
| test-fixture | Preview, fixture, mock, or deterministic test material. |
| archived-evidence | Historical evidence intentionally preserved under archive. |
| generated-remove | Generated/scratch output that must be deleted from git. |
| migrate-or-rename | Useful content, wrong path/name/language. |
| delete | No future value and safe to remove. |

No file may remain unclassified.

---

## Gate 2 — Generated Artifact Purge

No tracked generated artifact may remain unless it is intentionally committed product output and named as such.

Failing examples:

- `tmp/`
- local inspection dumps
- generated slide builder scratch files
- `.ndjson` inspection logs
- build outputs
- local audit output outside `docs/audits/`

Ignored generated paths are not enough. Existing tracked generated files must be deleted or intentionally moved into a named permanent docs/presentations location.

---

## Gate 3 — Active Canon Clarity

A new team must be able to open the repo and know the active read order.

Required files must agree:

- `README.md`
- `docs/README.md`
- `docs/canon/README.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Documentation_System_Index.md`
- `docs/codex/CONTEXT_INDEX.md`

Any older v2 or historical doc referenced as active must be explicitly justified as still binding where 3.0 has not replaced it.

---

## Gate 4 — Legacy Language Removal

User-facing strings, previews, screenshot fixtures, App Intents, notifications, widgets, and active docs must not use deprecated language except inside explicit migration/copy-guard documents.

Allowed legacy references:

- language system docs
- copy guard docs
- migration/deprecation docs
- repo hygiene docs
- compatibility tests that explicitly state compatibility purpose
- archived historical evidence

All other legacy language is failing debt.

---

## Gate 5 — Internal Identifier Migration Plan

Any remaining legacy internal identifier must be either migrated or explicitly tracked.

Known migration targets include:

- `startFocus`
- `focus` where it means execution session instead of cognitive context
- `TodayFocus*`
- `activeFocus`
- `bestNextMove`
- `capturesInbox`
- legacy `Profile`, `Insights`, or `Habits` compatibility seams

These must not leak into user-facing UI.

---

## Gate 6 — Build And Test Proof

Handoff readiness requires local or CI evidence for:

- clean working tree before and after audit
- `xcodegen generate`
- app build for simulator
- unit tests
- UI tests, where currently supported
- unsigned release archive sanity check
- no new Swift compile warnings caused by cleanup

If a test cannot be run, the handoff report must say why and identify the exact missing environment dependency.

---

## Gate 7 — Roadmap Continuation Proof

A team must know what to build next.

Required evidence:

- current implementation status in `docs/codex/BATCH_REGISTRY.md`
- active 3.0 implementation sequence in `Ambitions_3_0_Front_End_Implementation_Batch_Plan.md`
- gap baseline in `Ambitions_3_0_Current_Implementation_Gap_Audit.md`
- release gates in `Ambitions_3_0_Release_Readiness_And_Evidence_Gates.md`
- clear F-series next batch prompt or batch folder entry

---

## Gate 8 — Traceability Matrix

A handoff-ready repo needs a traceability matrix from product doctrine to implementation evidence.

Required artifact:

```text
docs/audits/faang-handoff-traceability-matrix.md
```

It must map:

| Canon claim | Owning doc | Owning code path | Test/preview evidence | Status |
|---|---|---|---|---|
| Example: Capture asks what needs a place | Product Language System / Placement Resolver | Capture feature | UI test / preview | implemented / partial / planned |

---

## Gate 9 — No Orphan Active Docs

Every active doc must be linked from at least one of:

- root README
- docs README
- canon README
- 3.0 documentation index
- source override
- Codex context index

Docs not linked from any active index must be either linked, archived, or deleted.

---

## Gate 10 — Handoff Report

Required final artifact:

```text
docs/audits/faang-handoff-readiness-report.md
```

It must include:

- files deleted
- files moved
- files intentionally retained
- active source-of-truth confirmation
- legacy language scan result
- internal identifier migration result
- build/test result
- remaining risks
- exact next implementation batch
- explicit pass/fail for each gate in this document

---

## Pass / Fail Rule

The repository is not FAANG-handoff ready until all ten gates pass.

Partial cleanup may be useful, but it must not be described as complete handoff readiness.

## Active Completion Train

The current handoff completion path is governed by `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`.

F27 has passed by current train evidence. F28 is conditional repair only if F27 or F27.5 is PARTIAL/FAIL. F29 final handoff packaging is Green by current train evidence. F30 Beyond 3.0 Continuation Plan is Green, and the train must stop after final closeout rather than starting post-train implementation automatically.
