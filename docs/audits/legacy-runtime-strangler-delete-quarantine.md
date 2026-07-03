# Legacy Runtime Strangler Delete Quarantine

Status: AMB-1716 Implemented Yellow

Snapshot date: 2026-07-02

Repo state inspected before this slice: `16062c59b324567ece4d4c3ad11e2a54c6f57afc`
on `main`

Scope: AMB-1666 -> AMB-1716 only. This slice deletes or quarantines the first
legacy `Core/Runtime` owner batch only where current proof shows the move is
safe. It does not start source migration parents, migrate runtime authority,
change Swift behavior, or prove full LocalRuntimeOS completion.

Evidence class: Implemented Yellow. AMB-1716 proves one test-support file was
quarantined out of production runtime ownership and the retained guard ceiling
was lowered. It does not prove runtime correctness, device behavior,
accessibility behavior, privacy/legal approval, TestFlight readiness, App Store
readiness, or Green AMB-1666 status.

AMB-1730 supersession: the current legacy runtime production-file ceiling is
`95` after the standalone PlanningEngine and TimeEngine owner-move batches
recorded in `docs/audits/legacy-runtime-strangler-import-replacement.md`. The
AMB-1716 `111` count below remains the historical count for this quarantine
slice only.

## Canonical Constraints

Runtime mutation law remains:

```text
Command -> Event -> Projection -> Receipt -> Replay
```

Remediation direction remains:

```text
law over lore
deep runtime, boring UI
delete before naming
Green requires linked evidence
proof automation outranks prose
```

Persistent surfaces remain Today / Goals / Time / You. Capture remains the
global composer. Motion remains behavior under Stage/Motion. R2 and Source
Atlas remain public/reference/freshness infrastructure only; they are not a
private life graph backend.

## Quarantined File

Moved out of production runtime owner:

- From: `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift`
- To: `Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift`

Supporting proof:

- `CoreRuntimeCanonicalOwnershipTests.testAMB1716QuarantinesTestSupportOutsideProductionRuntimeOwner`
  asserts the test-support path exists and the old production runtime path is
  absent.
- `LargeStoreFixtureGeneratorTests` still compile and pass against the moved
  test-support file.
- `scripts/ambitions-legacy-runtime-production-use-guard.py` now treats
  `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift` as an
  AMB-1716 retired legacy owner path.
- Active legacy runtime production-file ceiling is now `111`.

## Yellow Non-Moves

The AMB-1713 `Test-only support` classification was broader than the safe
delete/quarantine proof available in this slice. AMB-1716 attempted wider moves
and kept the following files Yellow because compile proof showed production
coupling:

- `Native/Ambitions/Core/Runtime/RuntimeCoreUmbrellaGate.swift`
- `Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime.swift`
- `Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime+02-GoldenVerticalSliceInput.swift`
- `Native/Ambitions/Core/Runtime/GoldenVerticalSliceRuntime+03-GoldenVerticalSliceRuntime.swift`

Evidence:

- Moving `RuntimeCoreUmbrellaGate.swift` caused production compile failures for
  `RuntimeCoreChainSegment` in `LifeConsequenceEngine+02-LifeConsequenceRecord.swift`.
- Moving the Golden Vertical Slice runtime files caused production compile
  failures for `GoldenVerticalSliceProgramRecord` and `GoldenVerticalSliceRecord`
  in `FirstRunActivationRuntime.swift`.

Those files remain under `Core/Runtime` as explicit Yellow debt until a
follow-up owner-move or quarantine leaf proves a replacement owner and removes
the production coupling.

## Validation Run

- `xcodegen generate`
  - Result: passed.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --self-test`
  - Result: passed on the final working tree.
- `python3 scripts/ambitions-legacy-runtime-production-use-guard.py --json`
  - Result: passed on the final working tree with `valid: true`,
    `baselineLegacyRuntimeFiles: 111`, `currentLegacyRuntimeFiles: 111`,
    `legacyRuntimeFileCeiling: 111`, `findingCount: 0`.
- `python3 scripts/ambitions-remediation-governance-check.py`
  - Result: passed on the final working tree with `changed_paths=8`.
- `git diff --check`
  - Result: passed on the final working tree.
- `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,id=8ACCD665-4807-4102-B526-5A1AE20686A8' -only-testing:AmbitionsTests/CoreRuntimeCanonicalOwnershipTests -only-testing:AmbitionsTests/LargeStoreFixtureGeneratorTests -parallel-testing-enabled NO -resultBundlePath artifacts/amb-1716/results/focused-large-store-quarantine-regenerated.xcresult test`
  - Result: passed. Executed 7 selected tests, with 0 failures.
  - Result bundle:
    `artifacts/amb-1716/results/focused-large-store-quarantine-regenerated.xcresult`.

## Validation Not Run

- Full test suite was not run.
- Device tests were not run.
- UI, accessibility, performance, privacy/legal, TestFlight, and App Store
  readiness validation were not run.
- No release or Green runtime-authority claim is made.

## Failed Attempts Kept As Evidence

- XcodeBuildMCP `test_sim` for the focused runtime support tests timed out after
  300 seconds before returning a result.
- Earlier shell xcodebuild attempts with wider quarantines failed as described
  in `Yellow Non-Moves`.
- `artifacts/amb-1716/results/focused-large-store-quarantine.xcresult` failed
  while the generated Xcode project still reflected the temporary wider move;
  `xcodegen generate` was rerun before the passing focused result bundle.

## Closeout Boundary

- Final Architecture Tree inspected: yes, through
  `docs/truth/PRODUCT_DESIGN_TRUTH.md`.
- Canonical owners touched:
  - Legacy production runtime owner removal for one test-support file:
    `Core/Runtime`
  - Test support:
    `Native/AmbitionsTests/Runtime/Support`
  - Quality/repo governance scripts
  - `docs/audits`
- Files moved or created:
  - `Native/AmbitionsTests/Runtime/Support/LargeStoreFixtureGenerator.swift`
  - `docs/audits/legacy-runtime-strangler-delete-quarantine.md`
- Files updated:
  - `Native/AmbitionsTests/Runtime/CoreRuntimeCanonicalOwnershipTests.swift`
  - `scripts/ambitions-legacy-runtime-production-use-guard.py`
  - `docs/audits/legacy-runtime-production-use-guard.md`
  - `docs/audits/legacy-runtime-strangler-classification.md`
  - `docs/audits/runtime-authority-map.md`
- Old/non-canonical paths removed:
  - `Native/Ambitions/Core/Runtime/LargeStoreFixtureGenerator.swift`
- Compatibility shims left behind: none added.
- Yellow architecture debt remains: yes. `111` legacy runtime production files
  remain under `Core/Runtime`, including production-coupled files that need
  follow-up owner movement before AMB-1666 can be Green.
- Next repair train: a follow-up AMB-1666 runtime owner-move or quarantine leaf
  before parent Green; do not move to M01 source migration parents until M00/M02
  governance/baseline sequence is reconciled.
- No equivalent folder/path interpretation was used.
- No Green runtime authority, release, or product-completion claim is made.
