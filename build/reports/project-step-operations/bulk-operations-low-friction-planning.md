# IOS26-T04H-B05 Bulk Operations And Low-Friction Planning

Status: Yellow
Batch: IOS26-T04H-B05
Train: TRAIN_04H / Project Step Operations / Todoist Things Replacement

## Files changed

- `Native/Ambitions/Domain/ProjectStepOperationModels.swift`
- `Native/AmbitionsTests/Domain/ProjectStepOperationModelsTests.swift`
- `Native/Ambitions/Domain/ReminderModels.swift`
- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `Native/AmbitionsTests/Persistence/ReminderRepositoryTests.swift`
- `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`
- `Native/AmbitionsTests/Domain/IOS26CrossAppJourneyContractHarnessTests.swift`
- `prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md`
- `build/reports/project-step-operations/bulk-operations-low-friction-planning.md`
- `build/reports/project-step-operations/IOS26-T04H-B05.md`

## End-user job

Move life commitments quickly with local, inspectable project-step operations.

## Replacement app floor

Project-step bulk operations now have a local `ProjectStepOperationKind` taxonomy, a bulk downstream contract model, and a replacement-claim harness that keeps `SourceRecord` / `Receipt` / `ReplayTrace` / `What Ambitions knows` boundaries explicit.

## P0 contract status

Source-present and test-present for the sealed batch slice, but not Green because wrapper Xcode validation did not produce passing proof and the post parallel guard is Yellow with accepted locked-concept boundaries.

## Implementation behavior

- `ProjectStepOperationKind` covers move, hold, schedule, unschedule, waiting, blocked, proof attachment, bulk downstream contract, and receipt.
- `ProjectStepBulkDownstreamContract` keeps the contract local, inspectable, replayable, and tied to `What Ambitions knows`.
- `ProjectStepBulkReplacementClaimHarnessFixture` blocks broad replacement claims unless the local evidence set is present.
- `ReminderTrigger.markedMissedTrigger(updatedAt:)` preserves the current `triggerAt` while shifting state to `needsRecovery`, which keeps the reminder recovery path local and inspectable.

## Tests run

- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04H-B05`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch IOS26-T04H-B05 --prompt prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md --allow-yellow`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04H-B05 --prompt prompts/batches/IOS26-T04H-B05-bulk-operations-and-low-friction-planning.md --changed-from 8b0e099336449c97463a22799a793e4eb341cfe4 --allow-yellow` (Yellow; accepted locks only)
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04H-B05`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04H-B05`
- `python3 scripts/ambitions-unsupported-claim-scan.py build/reports/project-step-operations/bulk-operations-low-friction-planning.md build/reports/project-step-operations/IOS26-T04H-B05.md`
- `scripts/codex-forbidden-claim-scan.sh build/reports/project-step-operations/IOS26-T04H-B05.md build/reports/project-step-operations/bulk-operations-low-friction-planning.md`
- `make xcode-focused-test BATCH=IOS26-T04H-B05 TEST=AmbitionsTests/ProjectStepOperationModelsTests` (stopped after overlapping B05 wrapper/xcodebuild processes made evidence unreliable)
- `scripts/ambitions-xcode-benchmark.sh --status`
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04H-B05 --lane build-for-testing` (failed; `.codex/xcode-summaries/IOS26-T04H-B05/20260525T110506Z/build-for-testing-summary.json`)
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04H-B05 --lane focused-test --test AmbitionsTests/Domain/ProjectStepOperationModelsTests` (failed; `.codex/xcode-summaries/IOS26-T04H-B05/20260525T111234Z/focused-test-summary.json`)
- `scripts/ambitions-xcode-validate.sh --batch IOS26-T04H-B05 --lane build-for-testing` after stale harness compile repair (failed; `.codex/xcode-summaries/IOS26-T04H-B05/20260525T111800Z/build-for-testing-summary.json`)
- `git diff --check`

## Validation not run

- Passing Xcode, XCTest, simulator, device, and archive validation were not produced.
- No passing Xcode/XCTest result bundle was produced in this turn.
- The wrapper-focused Xcode attempt was stopped after overlapping B05 wrapper/xcodebuild processes were detected against the same simulator and derived data.
- Phase 04 repair reran the requested wrapper lanes. `build-for-testing` first failed on stale test harness compile issues in `IOS26CalendarP0ContractHarnessTests` and `IOS26CrossAppJourneyContractHarnessTests`; those compile-only test harness issues were repaired. The post-repair `build-for-testing` attempt then failed on `ProjectStepOperationModels.swift` duplicate/inconsistent declarations while concurrent B06/B07 runner phases were active in the same checkout, so the result is not usable as clean B05 build proof.
- The Phase 04 focused-test lane did not produce XCTest proof; it failed to install the test runner because `.codex/DerivedData/Ambitions/Build/Products/Debug-iphonesimulator/Ambitions.app` was missing a bundle ID.
- Device, accessibility, performance, CI, TestFlight, App Store, and release validation are not proven here.

## Proof artifacts

- `build/reports/project-step-operations/bulk-operations-low-friction-planning.md`
- `build/reports/project-step-operations/IOS26-T04H-B05.md`

## Accessibility status

- Not verified.

## Privacy/local-first status

- Preserved. No cloud LLM, hosted personal-data backend, or external analytics dependency was introduced.

## Performance status

- Not measured.

## Claims allowed

- Source-present local bulk project-step operation contracts.
- Local inspection and replay-safe replacement-claim harness behavior.
- The reminder helper recovery path that preserves `triggerAt` during missed-trigger handling.

## Claims forbidden

- Release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion.

## Yellow items

- Xcode validation remains blocked/unproven; the focused wrapper attempt was stopped after overlapping B05 validation processes made the evidence unreliable.
- Phase 04 Xcode validation remains blocked/unproven after wrapper reruns. The current checkout also has active B06/B07 runner phases, so a further B05 wrapper retry would not satisfy the clean single-lane proof requirement.
- The accepted `proof_receipt_replay` Yellow boundary remains in effect.
- Current batch proof is source/test/report level only.
- `persistence_external_surfaces` remains accepted Yellow only for the scoped SwiftData reminder mapping repair needed to preserve local receipt/replay mapping. No broader persistence, external-surface, export/delete/reset, widget/share-extension, Xcode, release, accessibility, privacy/legal, or performance proof is claimed.

## Red items

- None.

## Guard fields

- Champion coverage status: GREEN
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: YELLOW
- Parallel guard pre report: `build/reports/parallel-implementation-guard/IOS26-T04H-B05-pre.md`
- Parallel guard post status: YELLOW
- Parallel guard post report: `build/reports/parallel-implementation-guard/IOS26-T04H-B05-post.md`
- Canonical owner extended: bounded `proof_receipt_replay`, bounded `persistence_external_surfaces`
- New implementation owners: no
- Canonical owner map changed: no
- Supersession ledger updated: no
- Best-code rescue checked: yes
- Runtime wiring gate: `SourceRecord` / `Receipt` / `ReplayTrace` / `What Ambitions knows`
- Yellow accepted reason: `proof_receipt_replay` remains accepted Yellow because adjacent Smart Attachment drift is still bounded; `persistence_external_surfaces` is accepted Yellow only for the scoped SwiftData mapping repair; Xcode proof remains blocked/unproven
- Red blockers: None

## Repo intelligence final fields

- Repo intelligence status: advisory only, not used as proof
- CodeGraph used: yes, Phase 01 advisory packet only
- Semble used: yes, Phase 01 advisory packet only
- Understand Anything used: no
- Advisory findings directly verified: prompt freeze, canonical owners, proof-shape checks, and batch boundary
- Accepted owner candidates: `private_life_runtime`, `goals_root`, bounded `proof_receipt_replay`, bounded `persistence_external_surfaces`
- Accepted proof/wiring findings: local proof/receipt/replay boundary remains explicit in source
- Advisory findings rejected: any broad replacement-claim framing
- Advisory-only findings used as proof: none
- Generated local tool artifacts staged: no

## Next batch

Proceed only after a clean single wrapper validation lane produces focused XCTest or build proof.
