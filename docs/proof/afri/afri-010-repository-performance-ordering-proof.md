# AFRI-010 Repository Performance and Ordering Proof

Status: Green for bounded persistence ordering slice
Batch: AMB-362 / AFRI-010
Date: 2026-05-31

## Scope

This proof covers a bounded repository ordering and local query-budget pass for common SwiftData reads. It does not claim release performance readiness.

Changed source:

- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`

## Query Budget Artifact

`RepositoryQueryBudget` defines local focused-test limits for common repository list reads:

- `maxGoalListResults = 500`
- `maxActionableStepResults = 500`
- `maxCaptureListResults = 500`
- `maxReminderListResults = 500`

These are local guardrails for unbounded list materialization. They are not product pagination UI, device performance proof, or release performance claims.

## Deterministic Ordering Snapshot

The repository tie-breaker policy for common reads is:

- goals: `updatedAt` descending, then `id` ascending;
- actionable steps: earliest timing key, then title ascending, then `id` ascending;
- drafts, evidence, captures, and reminders: primary timestamp descending, then `id` ascending.

Focused large-fixture coverage seeds 32 goals in reverse order with identical timestamps and verifies the result snapshot is the ascending ID order bounded by `RepositoryQueryBudget.maxGoalListResults`.

## Validation

Pre guard:

```text
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-362 --prompt /tmp/AMB-362-AFRI-010-guard-prompt.md
```

Result: Green. Report: `build/reports/parallel-implementation-guard/AMB-362-pre.md`.

Focused tests:

```text
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/PersistenceRepositoryTests
```

First repair signal: Red. Swift resolved `max` inside the generic array extension as an instance member instead of the global Swift function.

Repair: changed the budget helper to call `Swift.max`.

Final result: `** TEST SUCCEEDED **`; 18 selected tests, 0 failures.

Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_12-22-46--0400.xcresult`

## Boundaries

This is not full-suite proof, UI proof, device proof, signed archive proof, release readiness, measured production performance proof, privacy/legal signoff, or public accessibility proof.
