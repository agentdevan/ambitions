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
- Phase 04 repaired the review finding that the repository was a stateless read-modify-write wrapper. `FileLocalScheduleBlockRepository` now routes file access through a shared actor coordinator, so concurrent in-process repository instances serialize create/manage/delete/export/import file access instead of dropping one writer's block.
- The focused test source now includes concurrent upsert coverage using two repository instances pointed at the same file. XCTest execution remains skipped by operator policy, so this is source-level test coverage only until the Xcode pause is lifted.
- `SourceRecord`, `Receipt`, `ReplayTrace`, and You / What Ambitions knows boundary IDs remain inspectable through the existing `ScheduledAmbitionsBlock` helpers.

## P0 Contract Mapping
- Covered create/manage local schedule block behavior through a file-backed repository service for existing `ScheduledAmbitionsBlock` values.
- Covered serialized file access for concurrent in-process repository writes in source and focused test source.
- Covered export/import/delete semantics and trust-boundary IDs in source-level repository coverage.
- Recurrence/protected-time/buffer-specific replacement depth is not claimed by this batch.

## Validation Executed
- `python3 scripts/ambitions-champion-coverage-check.py` -> GREEN.
- `python3 scripts/ios26-prompt-freeze-check.py --check --batch IOS26-T04F-B01 --prompt prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md` -> GREEN.
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B01` -> GREEN.
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B01` -> GREEN.
- `python3 scripts/ambitions-repo-intelligence-preflight.py` -> GREEN.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B01 --prompt prompts/batches/IOS26-T04F-B01-local-schedule-models-and-repositories.md --changed-from cea680fb9c05949f533119c9438cd9402eef3f05 --allow-yellow` -> YELLOW accepted for `proof_receipt_replay`; rerun in an isolated temporary worktree with only B01-owned files plus the narrow validator/coverage repair, no unrelated IOS26 lane files.
- `git diff --check -- <B01 paths>` -> GREEN.

## Validation Not Run
- Xcode, XCTest execution, simulator, device, accessibility, performance, CI, TestFlight, App Store, and release proof remain skipped because `AMBITIONS_SKIP_XCODE_TESTING=1` is set by the operator.

## Yellow Boundary
- Owner: `proof_receipt_replay`.
- Reason: Accepted Yellow boundary carried from Champion Merge for adjacent proof/receipt/replay drift.
- No-claim boundary: This batch only adds a serialized local schedule repository service, focused source-level coverage, and a narrow guard owner-classification validator repair. It does not claim broad proof/receipt/replay completion, accessibility proof, or Xcode/XCTest proof.
- Follow-up gate: `proof_receipt_replay` remains Yellow until the adjacent drift gate is proven Green or owner-accepted.

## Red Blockers
- None after Phase 04 repair. Unrelated dirty work from other IOS26 lanes remains outside the B01 isolated guard proof and outside this batch's claims.
