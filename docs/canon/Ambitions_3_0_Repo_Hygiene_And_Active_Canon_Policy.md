# Ambitions 3.0 — Repo Hygiene And Active Canon Policy

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Source override: [Ambitions 3.0 Source Of Truth Override](./Ambitions_3_0_Source_Of_Truth_Override.md)  
Last updated: 2026-04-30

---

## Purpose

This policy keeps the Ambitions repo clean during the 3.0 rebuild.

The repo should not feel like a pile of historical prompts, temporary artifacts, stale design plans, or legacy product language.

Cleanup must be intelligent. Do not delete evidence, compatibility routes, tests, or migration history blindly.

---

## Cleanup Thesis

Ambitions 3.0 repo hygiene has four jobs:

1. Make active canon obvious.
2. Keep historical material out of the active path.
3. Prevent generated/scratch artifacts from returning.
4. Migrate legacy wording and identifiers safely with tests.

---

## Active Canon Rule

Active Ambitions 3.0 work should begin from:

1. `Ambitions_3_0_Source_Of_Truth_Override.md`
2. `Ambitions_3_0_Front_End_Redesign_Index.md`
3. `Ambitions_3_0_Rebuild_Operating_Model.md`
4. `Ambitions_3_0_Documentation_System_Index.md`
5. `Ambitions_3_0_Primitive_Architecture.md`
6. `Ambitions_3_0_Product_Language_System.md`
7. Target primitive/surface docs

Older docs are supporting history only unless the 3.0 override or documentation index explicitly keeps them binding for a domain not replaced by 3.0.

---

## Generated Artifact Rule

Generated/scratch artifacts must not be committed.

Ignored paths/patterns include:

- `/tmp/`
- `tmp/`
- `*.ndjson`
- `*.log`
- `*.tmp`

Tracked scratch artifacts should be removed when their blob SHAs are available and deletion can be done safely.

---

## Historical Doc Policy

Historical docs should live in one of these states:

| State | Location | Meaning |
|---|---|---|
| Active 3.0 canon | `docs/canon/Ambitions_3_0_*` | Current rebuild source of truth. |
| Binding older canon | `docs/canon/*` | Still binding only where 3.0 does not replace it. |
| Archived / superseded | `docs/archive/` | Historical evidence only. |
| Batch evidence | `docs/codex/` | Implementation status/history only. |
| Generated output | `tmp/`, `output/`, generated presentation folders | Should not be active canon. |

Do not treat archived or batch evidence as current product direction.

---

## Legacy Language Cleanup Policy

The Product Language System decides preferred language.

Legacy user-facing language must be removed from:

- SwiftUI strings
- accessibility labels
- App Intents titles/dialogs/phrases
- preview fixtures
- screenshot/demo content
- active docs
- tests that assert visible copy

Legacy words may remain temporarily only in:

- this cleanup policy
- migration/deprecation docs
- copy guard docs
- compatibility tests explicitly marked compatibility-only
- internal code identifiers scheduled for migration
- older archived docs

---

## Highest-Priority Code Migration Targets

These should be migrated in scoped, tested batches:

| Legacy code term | Target direction | Notes |
|---|---|---|
| `startFocus` | `startStepSession` | Command/action migration. |
| `focusSession` / `TodayFocus*` | `StepSession` / `TodayStep*` | Requires type/file-wide migration. |
| `NowActionKind.focus` | `NowActionKind.startStepSession` or equivalent | Requires service/test migration. |
| `activeFocus` | `activeStepSession` | Requires external snapshot/widget/test migration. |
| `bestNextMove` | `recommendedStep` | Today execution projection migration. |
| `capturesInbox` | `capture` / `needsAPlace` depending route | Requires routing compatibility review. |
| `Insights` | `Reviews`, `Plan`, or `You` depending context | Do not blindly rename; route ownership matters. |
| `Profile` | `You` | User-facing copy first, route compatibility second. |
| `Habits` | `Goals`, `Steps`, or `Reviews` depending context | Requires semantic review. |

---

## Cleanup Levels

### Level 1 — Safe cleanup

- ignore generated artifacts
- remove committed scratch files when safe
- update active indexes
- add archive notices
- update user-facing copy

### Level 2 — Compatibility-safe cleanup

- update App Intent titles/dialogs/phrases
- update previews and fixtures
- update accessibility labels
- update tests that assert copy

### Level 3 — Code identifier migration

- rename enums, actions, models, and routes
- update all call sites
- update tests
- preserve migration adapters where needed
- run build/tests

### Level 4 — Archive pruning

- move superseded docs into `docs/archive/`
- remove duplicate generated docs
- update source maps
- keep evidence needed for roadmap/batch history

---

## Do Not Delete Without Replacement

Do not delete:

- compatibility tests before replacement tests exist
- domain models still used by app code
- source-of-truth maps before 3.0 links replace them
- batch registry/history files
- privacy/trust rules still binding outside 3.0
- acceptance gates stricter than 3.0

---

## Required Cleanup Evidence

Every cleanup batch should report:

- files changed
- files intentionally not changed
- generated artifacts removed or ignored
- legacy terms removed
- legacy terms intentionally retained and why
- tests run or not run
- remaining cleanup debt

---

## Current Known Cleanup Debt

As of this policy, active code still contains legacy internal terms that require scoped migration rather than blind deletion:

- `startFocus`
- `focus`
- `TodayFocus*`
- `activeFocus`
- `bestNextMove`
- `capturesInbox`

These are not accepted long-term. They are migration targets.

---

## Acceptance Criteria

The repo is clean when:

- active 3.0 canon is obvious
- generated artifacts do not return
- active docs do not read as historical junk
- legacy user-facing copy is removed
- remaining legacy identifiers are tracked migration debt
- cleanup work does not break builds or erase useful evidence
