# IOS26-T04F-B01: Local Schedule Models And Repositories

Status: YELLOW

## Scope
- Kept the local schedule model on the existing `ScheduledAmbitionsBlock`/`ScheduledBlockWriteIntent` seam in `Native/Ambitions/Domain/RealityModels.swift`.
- Added a file-backed local schedule repository service in `Native/Ambitions/Services/LocalScheduleBlockRepository.swift`.
- Routed confirmed Time schedule writes through that repository from `Native/Ambitions/Services/AmbitionsCommandExecutor.swift`.
- Added focused repository coverage in `Native/AmbitionsTests/Services/LocalScheduleBlockRepositoryTests.swift`.

## Repair Notes
- The first draft tried to place the repository contract under `Native/Ambitions/Persistence`, but the active concept lock still blocks that path for this batch. The repository seam was moved into `Native/Ambitions/Services` to stay inside the allowed surface.
- The repository reuses the existing local file helpers instead of adding a second persistence graph or a new top-level product object.
- `SourceRecord`, `Receipt`, `ReplayTrace`, and You / What Ambitions knows boundary IDs remain inspectable through the existing `ScheduledAmbitionsBlock` helpers.

## P0 Contract Mapping
- Covered create/manage local schedule block behavior through a file-backed repository service for existing `ScheduledAmbitionsBlock` values.
- Covered export/import/delete semantics and trust-boundary IDs in source-level repository coverage.
- Recurrence/protected-time/buffer-specific replacement depth is not claimed by this batch.

## Validation Executed
- `python3 scripts/ambitions-champion-coverage-check.py` -> GREEN.
- `python3 scripts/ios26-prompt-freeze-check.py --check --batch IOS26-T04F-B01 --prompt prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md` -> GREEN.
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B01` -> GREEN.
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B01` -> GREEN.
- `python3 scripts/ambitions-repo-intelligence-preflight.py` -> GREEN.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B01 --prompt prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md --changed-from cea680fb9c05949f533119c9438cd9402eef3f05 --allow-yellow` -> YELLOW accepted for `proof_receipt_replay`; no blocked concept violations.
- `git diff --check` -> GREEN after isolating unrelated T04G-B02 prompt whitespace in `stash@{0}`.

## Validation Not Run
- Xcode, XCTest execution, simulator, device, accessibility, performance, CI, TestFlight, App Store, and release proof remain skipped because `AMBITIONS_SKIP_XCODE_TESTING=1` is set by the operator.

## Yellow Boundary
- Owner: `proof_receipt_replay`.
- Reason: Accepted Yellow boundary carried from Champion Merge for adjacent proof/receipt/replay drift.
- No-claim boundary: This batch only adds a local schedule repository service and source-level coverage. It does not claim broad proof/receipt/replay completion, accessibility proof, or Xcode/XCTest proof.
- Follow-up gate: `proof_receipt_replay` remains Yellow until the adjacent drift gate is proven Green or owner-accepted.

## Red Blockers
- None after Phase 04 repair. The unrelated `Native/Ambitions/Persistence/*` edits and T04G-B02 prompt whitespace were isolated in `stash@{0}` named `codex-ios26-t04f-b01-isolate-unrelated-20260525`.
