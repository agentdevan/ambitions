# Champion Merge Persistence / External Surfaces

Batch: `AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01`

Status: Yellow - Xcode testing intentionally skipped by user instruction until local Xcode/simulator repair.

## Concept

Persistence, export/delete/reset, widgets, Live Activities, App Intents, share extension object paths, and external-surface snapshots.

## Canonical Owners

- `persistence`: `Native/Ambitions/Persistence`
- `external_surfaces`: `Native/Ambitions/ExternalSnapshots`, `Native/AmbitionsWidgetExtension`, `Native/AmbitionsShareExtension`, `Native/Ambitions/App`

## Competing Implementations

- Portable snapshot export/import previously carried goal feedback receipts but not canonical action receipt history or entity revision tombstones.
- External snapshot/widget/live activity route fallbacks still used legacy `plan` compatibility strings in active external-surface paths.

## Better Fragments Rescued

- Canonical action receipt history is now represented in portable snapshots through `PortableStoredActionReceiptHistoryRecord`.
- Entity revision tombstones are included in receipt/export counts so replacement history is not stranded outside portable restore.
- Widget/live activity external routes now fall back to canonical `time` tab strings while preserving legacy `plan` route compatibility in app routing tests.

## Active Code Changed

- `Native/Ambitions/Persistence/PortableSnapshotContracts.swift`
- `Native/Ambitions/Persistence/PortableSnapshotService.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceContractModels.swift`
- `Native/Ambitions/ExternalSnapshots/ExternalSurfaceSnapshotBuilder.swift`
- `Native/Ambitions/ExternalSnapshots/NextStepActivityAttributes.swift`
- `Native/AmbitionsWidgetExtension/NextStepLiveActivityWidget.swift`
- `Native/AmbitionsTests/App/ExternalSurfaceSnapshotTests.swift`
- `Native/AmbitionsTests/App/ExternalWidgetProjectionTests.swift`
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `Native/AmbitionsTests/Persistence/PortableSnapshotServiceTests.swift`

## Runtime Wires

- SourceRecord: not newly introduced in this batch; persistence/export remains local repository backed.
- Receipt: action receipt history and revision tombstones now round-trip through portable snapshots.
- ReplayTrace: no new replay path introduced; replay/receipt history is preserved for downstream inspection.
- You inspection: no new You surface added; exported/restored trust history remains available through canonical repositories.
- Reset/delete: replace-local-store still routes through the existing explicit reset closure.

## Tests Run

- `python3 scripts/ambitions-champion-coverage-check.py --batch AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01.md`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01 --prompt prompts/batches/champion-merge/AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01.md --changed-from b99ecba042dcadb003958655a9326220a432ea10`
- `git diff --check`

## Tests Not Run

- Xcode focused test lanes were intentionally skipped after the user instructed Codex to skip Xcode testing until local repair.
- The runner attempted `make xcode-focused-test ... PortableSnapshotServiceTests`; that lane was interrupted and killed to honor the skip-Xcode instruction.

## Proof Boundary

This batch may claim guard/static validation and source-level consolidation only. It may not claim focused XCTest proof, release readiness, full runtime consolidation, accessibility validation, performance validation, privacy/legal signoff, or that all duplicate/unused code has been removed.

## Concept Lock Update

`persistence_external_surfaces` remains locked with `YELLOW_XCODE_SKIPPED` until focused Xcode lanes can run.

## Next Action

Continue to `AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01`, with all Xcode lanes skipped until the local Xcode/simulator issue is fixed.
