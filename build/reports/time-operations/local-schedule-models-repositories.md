# IOS26-T04F-B01: Local Schedule Models And Repositories

Status: YELLOW

## Scope
- Extended the existing `ScheduledAmbitionsBlock` local schedule model in `Native/Ambitions/Domain/RealityModels.swift`.
- Added local file export/load/upsert/delete helpers for schedule blocks without adding a new top-level destination, cloud dependency, analytics dependency, or Persistence/App wiring.
- Added inspectable local trust IDs for `SourceRecord`, `Receipt`, `ReplayTrace`, and You / What Ambitions knows boundaries.
- Added focused contract harness coverage in `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`.

## Repair Notes
- Removed the Phase 01 SwiftData/App/Persistence wiring from this batch because `persistence_external_surfaces` is locked to Champion Merge prefixes in `docs/codex/concept-lock-registry.yml`.
- Removed the new `LocalScheduleModels.swift` owner gap by extending the existing Time/Reality model owner instead of creating a new parallel model file.
- Removed fresh `Plan`-named schedule fields from this batch. Existing `relatedPlanID` compatibility in `ScheduledAmbitionsBlock` remains untouched.

## P0 Contract Mapping
- Covered create/manage local schedule block behavior through local JSON durability helpers for existing `ScheduledAmbitionsBlock` values.
- Covered export/load/upsert/delete semantics and trust-boundary IDs in focused XCTest source.
- Recurrence/protected-time/buffer-specific replacement depth is not claimed by this batch after the repair narrowed away from new parallel schedule model types.

## Validation Executed
- `python3 scripts/ambitions-champion-coverage-check.py` -> GREEN.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04F-B01 --prompt prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md --allow-yellow` -> YELLOW, accepted `proof_receipt_replay`.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B01 --prompt prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md --changed-from 299c2eb8b94a5351a717ed89862c8e9553e475f4 --allow-yellow` -> YELLOW, accepted `proof_receipt_replay`.
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B01` -> GREEN.
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B01` -> GREEN.
- `git diff --check` -> pass.

## Validation Not Run
- Xcode, XCTest execution, simulator, device, accessibility, performance, CI, TestFlight, App Store, and release proof were not run or claimed because `AMBITIONS_SKIP_XCODE_TESTING=1` is set by the operator.

## Yellow Boundary
- Owner: `proof_receipt_replay`.
- Reason: Accepted Yellow boundary carried from Champion Merge for adjacent proof/receipt/replay drift.
- No-claim boundary: This batch only adds local schedule block trust IDs and local durability helpers. It does not claim broad proof/receipt/replay completion or Smart Attachment drift resolution.
- Follow-up gate: `proof_receipt_replay` remains Yellow until the adjacent drift gate is proven Green or owner-accepted.
