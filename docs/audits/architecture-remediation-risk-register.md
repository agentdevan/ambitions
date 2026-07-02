# Architecture Remediation Risk Register

Status: AMB-1657 evidence baseline

Snapshot date: 2026-07-02

Repo state: `0055a18a1fab4d2c62d6dc73bf7597e630d07b8e` on `main`

This register records risk signals from static source and configuration scans.
It is not a defect list and not remediation proof. Every risk is proof-bounded
to the evidence cited here.

## Risk Summary

| ID | Risk signal | Evidence | Proof status | Next follow-up |
| --- | --- | --- | --- | --- |
| ARR-001 | Core concentration may hide duplicate authority. | `Native/Ambitions/Core`: 722 Swift files, 151098 LOC. | Implemented Yellow baseline evidence only. | AMB-1658 governance rules, then runtime authority map. |
| ARR-002 | Legacy runtime and persistence scaffolding remain active when touched. | `Core/Runtime`: 115 Swift files, 25514 LOC. `Core/Persistence`: 34 Swift files, 7485 LOC. | Implemented Yellow baseline evidence only. | Require owner decision before any source migration touches these paths. |
| ARR-003 | LocalRuntimeOS is large enough to need stricter authority mapping before edits. | `Core/LocalRuntimeOS`: 329 Swift files, 64459 LOC. | Implemented Yellow baseline evidence only. | Map command, event, projection, receipt, replay, storage, and side-effect owners before migration. |
| ARR-004 | Split-file pressure can preserve lore by filename rather than law. | 257 Swift files contain `+02`, `+03`, or `+04`. | Implemented Yellow baseline evidence only. | Use delete-before-naming rule in later refactors. |
| ARR-005 | Broad architecture nouns are common. | Filename hits: `Service` 141, `Runtime` 109, `Engine` 81, `Ledger` 43, `System` 34, `Kernel` 25, `Coordinator` 10, `Manager` 1. | Implemented Yellow baseline evidence only. | AMB-1658 should block new broad nouns unless ownership and deletion/collapse proof exists. |
| ARR-006 | Oversized production/support files need risk tracking. | 5 production/support Swift files exceed 600 LOC, including `RuntimeDoctorRepairOperator.swift`, `SourceAtlasLaunchFloorShardIndexModels.swift`, and `ExternalSurfaceSnapshotBuilder.swift`. | Implemented Yellow baseline evidence only. | Later source trains should reduce risk only with scoped tests and no fake Green. |
| ARR-007 | Test mass can make build/test evidence expensive to interpret. | 421 Swift test/support-test files; largest file is `AmbitionsUITests.swift` at 3186 LOC. | Implemented Yellow baseline evidence only. | Governance should require focused validation names and exact not-run lists. |
| ARR-008 | Direct persistence/write candidates need runtime-law review. | Static scan found 43 production/support write-marker files and 12 SwiftData context/model-only files. | Candidate evidence only, not proof of illegal writes. | Runtime authority map must classify writes before migration. |
| ARR-009 | Widget, App Intent, and share extension files cross runtime/projection boundaries. | Static scan found 33 production candidate files across `AppUI`, app intents, `Projection/ExternalSnapshots`, widget extension, and share extension. | Candidate evidence only, not proof of illegal mutation. | Require Command -> Event -> Projection -> Receipt -> Replay boundary review before edits. |
| ARR-010 | `Projection/SurfaceLenses` concentration may become competing product logic. | `Projection/SurfaceLenses`: 135 Swift files, 28901 LOC. | Implemented Yellow baseline evidence only. | Later migration should distinguish projection from runtime authority. |
| ARR-011 | Package/platform floors differ across local packages. | Root package uses Swift tools 6.2 and iOS/macOS 26. `AmbitionsExperienceKernel` uses Swift tools 5.9 and iOS 17/macOS 13. | Implemented Yellow baseline evidence only. | Package governance should decide whether this is intentional compatibility or migration debt. |
| ARR-012 | Source-present final-tree inventory can be overclaimed. | `scripts/ambitions-architecture-inventory.py --json` reported 207 source-present entries and 0 blocking entries. | Source-present only; not runtime, build, visual, device, accessibility, privacy, or review proof. | Closeouts must keep claims at source-present unless exact proof artifacts exist. |

## Explicit Non-Claims

- No Swift behavior was changed.
- No source migration was started.
- No runtime authority was moved.
- No build or test pass is claimed by this document.
- No device behavior is claimed by this document.
- No accessibility behavior is claimed by this document.
- No privacy, legal, TestFlight, App Store, or launch claim is made here.

## Required Governance Follow-Up

The next M00 item should install governance rules before any source migration
parent starts. At minimum, AMB-1658 should require:

- Baseline documents linked before source migration.
- Proof-status taxonomy on all architecture closeouts.
- No Green language without linked current evidence for the exact claim.
- New architecture names blocked unless deletion/collapse and exact owner are proven.
- `Core/Runtime`, `Core/Persistence`, and external mutation candidates treated as Yellow until classified.
- Command -> Event -> Projection -> Receipt -> Replay preserved as the runtime mutation law.
- Today / Goals / Time / You, global Capture, and Motion as behavior preserved as product canon.
