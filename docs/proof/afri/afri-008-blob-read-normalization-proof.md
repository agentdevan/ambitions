# AFRI-008 Blob Read Normalization Proof

Status: Green for bounded persistence slice
Batch: AMB-360 / AFRI-008
Date: 2026-05-31

## Scope

This proof covers a bounded repository read-path normalization pass for goal, plan, and step objects used by common Today, Goals, Time, and You-facing queries.

Changed source:

- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/AmbitionsTests/Persistence/PersistenceRepositoryTests.swift`

## What Changed

- Changed goal, plan, and step repository mapping to prefer normalized SwiftData fields for ordinary reads.
- Added explicit `includeSnapshotFallback` mapping flags so whole-object snapshot decoding is opt-in instead of the default.
- Kept snapshot storage as an audit/export and one-cycle additive migration fallback boundary.
- Preserved explicit goal detail fallback for additive fields that are not fully normalized yet, including current life graph snapshot coverage.
- Added repository coverage that corrupts stored goal, plan, and step snapshots and verifies `listGoals`, `listSteps`, and `listActionableSteps` still load from normalized fields.

## Storage And Read-Path Comparison

Before this slice, repository mapping attempted whole-object snapshot decoding for goal, plan, and step reads before using normalized columns.

After this slice:

- `listGoals()` composes goals and plans through normalized goal, plan, section, and step fields.
- `listSteps(goalID:)` maps steps from normalized step fields.
- `listActionableSteps()` filters and maps from normalized step fields.
- `goal(id:)` still opts into snapshot fallback for one migration cycle so additive detail-only fields can survive until they are normalized separately.

The focused repository test uses invalid JSON snapshot blobs as a hard guard: common list/actionable reads would fail if they still depended on decoding those whole-object snapshots.

## Validation

Pre guard:

```text
python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-360 --prompt /tmp/AMB-360-AFRI-008-guard-prompt.md
```

Result: Green. Report: `build/reports/parallel-implementation-guard/AMB-360-pre.md`.

Focused tests:

```text
xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/PersistenceRepositoryTests
```

First repair signal: Red. Swift could not resolve method references after `RepositoryMapping.step` gained an external `includeSnapshotFallback` label.

Repair: changed the affected calls to explicit throwing closures.

Final result: `** TEST SUCCEEDED **`; 17 selected tests, 0 failures.

Result bundle: `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.31_12-04-32--0400.xcresult`

## Boundaries

This is not a full persistence schema migration, full-suite proof, UI proof, device proof, signed archive proof, release readiness, measured performance benchmark, privacy/legal signoff, or public accessibility proof.
