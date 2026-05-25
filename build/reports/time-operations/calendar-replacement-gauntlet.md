# Calendar Replacement Gauntlet

Batch: `IOS26-T04F-B06`
Date: `2026-05-25`

## Status

YELLOW

## Files changed

- `Native/Ambitions/Persistence/SwiftDataRepositories.swift`
- `prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md`
- `docs/codex/ios26/IOS26_PROMPT_FREEZE_HASHES.json`
- `build/reports/parallel-implementation-guard/IOS26-T04F-B06-post.json`
- `build/reports/parallel-implementation-guard/IOS26-T04F-B06-post.md`
- `build/reports/time-operations/calendar-replacement-gauntlet.md`
- `build/reports/time-operations/IOS26-T04F-B06.md`

## End-user job

Replace the Calendar P0 proof job with the sealed local-first Calendar replacement gauntlet while staying inside the Time / LifeShape owner.

## Replacement app floor

Time / LifeShape remains the canonical replacement floor under `time_root`. The 300-scenario deterministic Calendar gauntlet already exists in source; this batch only repaired a persistence compile drift needed to keep the floor buildable.

## P0 contract status

Source-level contract remains intact, but execution proof is not complete in this batch. Focused Xcode validation was blocked after the source fix by Xcode package/container resolution time inside `build-for-testing`, so no XCTest proof is claimed here.

## Implementation behavior

- Corrected the `ReminderTrigger` reconstruction call in `Native/Ambitions/Persistence/SwiftDataRepositories.swift` so the argument labels match the live initializer contract.
- Regenerated the local Xcode project so the `ReminderModels.swift` source membership drift is resolved for the build.
- Repaired the sealed B06 prompt so the post guard carries the accepted Yellow `persistence_external_surfaces` no-claim boundary required by the existing Persistence / export-delete-reset / external surfaces lock.
- Did not add new owners, UI, or runtime behavior.
- Did not create a parallel proof/receipt/replay owner; the accepted Yellow adjacency boundary remains unchanged.

## Tests run

- `python3 scripts/ios26-prompt-freeze-check.py --check --batch IOS26-T04F-B06 --prompt prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md` -> GREEN
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B06` -> GREEN
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B06` -> GREEN
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04F-B06` -> GREEN
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B06 --prompt prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md --changed-from b901f8f0e7e4b90297cbf493fbd9104c7aa2fce8 --batch-type source-changing --allow-yellow` -> YELLOW accepted boundary
- `scripts/ambitions-xcode-benchmark.sh --status` -> installed; timing evidence only, not build/test/release proof
- `git diff --check` -> failed on unrelated T04G prompt trailing whitespace outside this batch boundary
- `make xcode-build-for-testing BATCH=IOS26-T04F-B06` -> failed after prolonged Xcode resolution/build time; the initial source compile error was cleared, but the wrapper did not complete cleanly

## Validation not run

- Focused XCTest did not run to completion because the build-for-testing lane did not complete cleanly.
- Simulator test execution, device proof, accessibility proof, performance proof, CI proof, TestFlight proof, and App Store proof were not run.
- Global diff whitespace proof is not clean because of unrelated T04G dirty material outside this batch boundary.

## Proof artifacts

- `build/reports/time-operations/calendar-replacement-gauntlet.md`
- `build/reports/time-operations/IOS26-T04F-B06.md`
- `build/reports/parallel-implementation-guard/IOS26-T04F-B06-pre.md`
- `build/reports/parallel-implementation-guard/IOS26-T04F-B06-post.md`

## Accessibility status

Not verified in this batch. No accessibility claim is made.

## Privacy/local-first status

Local-first posture preserved. No cloud LLM, hosted personal-data backend, or external analytics dependency was introduced.

## Performance status

Not measured in this batch. No performance claim is made.

## Claims allowed

- The Calendar P0 gauntlet remains source-present and deterministic.
- `time_root` remains the owning seam for Time / LifeShape calendar replacement work.
- The batch applied a narrow persistence compile fix without widening scope.

## Claims forbidden

- Release readiness
- TestFlight readiness
- App Store readiness
- CI proof
- Device proof
- Accessibility verification
- Performance validation
- Privacy/legal approval
- Calendar replacement complete

## Yellow items

- Xcode build/test validation is blocked by the current `build-for-testing` environment path, so the batch is source-fixed but not execution-proven.
- The 300-scenario gauntlet is encoded in source, not current XCTest logs.
- `persistence_external_surfaces` is accepted Yellow for this batch; no broad persistence/export or external-surface object graph claim is made.
- Global `git diff --check` is blocked by unrelated T04G prompt whitespace outside this batch boundary.

## Red items

- None introduced by this batch.
- Unrelated dirty work from other threads remains outside this batch boundary and was left untouched.

## Next batch

Resume focused XCTest validation once the build-for-testing/Xcode package-resolution path is stable, then convert the source-level gauntlet into execution proof.

## Guard fields

- Champion coverage status: GREEN
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: YELLOW accepted boundary
- Parallel guard pre report: `build/reports/parallel-implementation-guard/IOS26-T04F-B06-pre.md`
- Parallel guard post status: YELLOW accepted boundary
- Parallel guard post report: `build/reports/parallel-implementation-guard/IOS26-T04F-B06-post.md`
- Canonical owner extended: no change; `time_root` already owns the touched Time / CalendarReminders seam
- New implementation owners: none
- Canonical owner map changed: no
- Supersession ledger updated: no
- Best-code rescue checked: yes
- Runtime wiring gate: source-level only; no runtime proof in this batch
- Yellow accepted reason: build/test validation did not complete cleanly after the source fix; `persistence_external_surfaces` remains an accepted Yellow no-claim boundary
- Red blockers: none for B06 after Phase 04 repair

## Repo intelligence fields

- Repo intelligence status: not used in this phase
- CodeGraph used: no
- Semble used: no
- Understand Anything used: no
- Advisory findings directly verified: `time_root` owns the Time / CalendarReminders seam; `ReminderModels.swift` is the live reminder-domain source file; `EventKitIntegrationService` is the live EventKit seam
- Accepted owner candidates: `time_root`
- Accepted proof/wiring findings: the reminder-domain source belongs in the app target and the Calendar replacement seam stays local-first
- Advisory findings rejected: no parallel Calendar owner or UI clone was introduced
- Advisory-only findings used as proof: none
- Generated local tool artifacts staged: none
