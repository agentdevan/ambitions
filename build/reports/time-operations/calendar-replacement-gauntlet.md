# Calendar Replacement Gauntlet

Batch: `IOS26-T04F-B06`
Date: `2026-05-25`

## Status

RED

## Files changed

- `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`
- `build/reports/time-operations/calendar-replacement-gauntlet.md`
- `build/reports/time-operations/IOS26-T04F-B06.md`

## End-user job

Replace the Calendar P0 proof job with a local-first Calendar replacement gauntlet that stays inside the Time / LifeShape owner.

## Replacement app floor

Time / LifeShape calendar replacement remains the canonical floor under `time_root`. The current batch widens the contract harness to 300 deterministic source-level scenarios without introducing a parallel owner or a calendar-clone UI.

## P0 contract status

Source-present and widened in tests, but not execution-proven in this batch because Xcode validation is operator-skipped. Phase 04 cannot close Yellow/Green because the current worktree contains out-of-bound Reminder implementation files that make the required champion and parallel-guard validation Red.

## Implementation behavior

- Extended `Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift` with a deterministic 300-scenario calendar gauntlet matrix.
- Phase 03 review repaired the gauntlet's permission assertions so they match the live `CalendarPermissionState` and `CalendarRemindersAuthorizationState` source shapes.
- Phase 04 did not make further source changes. The existing repair still matches the live permission source shapes, including `.readWrite`, `.writeOnly`, and `.unavailable` on `CalendarPermissionState`.
- Tightened the broad-claim fixture with calendar-specific forbidden claim language.
- Kept the work inside the existing Time / CalendarReminders seam.
- `Native/Ambitions/Services/EventKitCalendarService.swift` is not present in this checkout; the live EventKit seam is `Native/Ambitions/Integrations/CalendarReminders/EventKitIntegrationService.swift`.

## Tests run

- `git diff --check -- Native/AmbitionsTests/Domain/IOS26CalendarP0ContractHarnessTests.swift`
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04F-B06`
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04F-B06`
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04F-B06`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B06 --prompt prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md --changed-from 837d70aff7856deb891835232976b1fab9f6b2f2 --allow-yellow`
- Phase 03 reran the same non-Xcode validation set after the permission repair.
- Phase 04 reran non-Xcode validation. Preflight and shape check stayed Green, but champion coverage and the post parallel guard are Red because out-of-bound untracked Reminder files are present in the worktree.

## Validation not run

- Focused Xcode validation remains skipped by operator instruction (`AMBITIONS_SKIP_XCODE_TESTING=1`).
- Build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, App Store, and release proof were not run.

## Proof artifacts

- `build/reports/time-operations/calendar-replacement-gauntlet.md`
- `build/reports/time-operations/IOS26-T04F-B06.md`
- Existing pre-boundary guard artifact: `build/reports/parallel-implementation-guard/IOS26-T04F-B06-pre.md`
- Phase 04 post guard artifact: `build/reports/parallel-implementation-guard/IOS26-T04F-B06-post.md` (RED due out-of-bound dirty work)

## Accessibility status

Not verified in this batch. No accessibility proof is claimed.

## Privacy/local-first status

Local-first only. No cloud LLM, hosted personal-data backend, or analytics dependency was introduced. No privacy approval is claimed.

## Performance status

Not measured in this batch. No performance validation is claimed.

## Claims allowed

- The Calendar P0 contract harness source now contains a 300-scenario deterministic gauntlet matrix.
- The batch remains inside the local-first Time / CalendarReminders seam.
- The broad replacement claim remains bounded by the explicit forbidden-claim fixture.

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

- Xcode validation is paused by operator instruction, so the gauntlet is source-present but not execution-proven.
- The 300-scenario matrix is encoded in source, not current execution logs.
- Phase 03 repair was reviewed with non-Xcode validation only; XCTest execution remains unproven.

## Red items

- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04F-B06` is RED because `Native/Ambitions/Domain/ReminderModels.swift` is an unclassified untracked Swift file outside the B06 boundary.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04F-B06 --prompt prompts/batches/IOS26-T04F-B06-calendar-replacement-gauntlet.md --changed-from 837d70aff7856deb891835232976b1fab9f6b2f2 --allow-yellow` is RED because out-of-bound Reminder/Persistence files are included in the dirty worktree against the batch base and touch the locked `persistence_external_surfaces` concept.

## Next batch

Continue only after the operator-held Xcode pause is lifted or a permitted non-Xcode proof lane is available.

## Guard fields

- Champion coverage status: RED
- Champion coverage report: `build/reports/intelligence-consolidation/champion-coverage-check.md`
- Parallel guard pre status: YELLOW accepted boundary
- Parallel guard pre report: `build/reports/parallel-implementation-guard/IOS26-T04F-B06-pre.md`
- Parallel guard post status: RED
- Parallel guard post report: `build/reports/parallel-implementation-guard/IOS26-T04F-B06-post.md`
- Canonical owner extended: no change; `time_root` already owns the touched Time / CalendarReminders seam
- New implementation owners: none
- Canonical owner map changed: no
- Supersession ledger updated: no
- Best-code rescue checked: no
- Runtime wiring gate: source-present only; no runtime proof in this batch
- Yellow accepted reason: Xcode validation paused by operator instruction; B06 source remains not execution-proven
- Red blockers: out-of-bound untracked Reminder source/test work causes champion coverage and post guard Red; this Phase 04 repair did not modify those files because they are outside the frozen B06 boundary

## Repo intelligence fields

- Repo intelligence status: YELLOW advisory only
- CodeGraph used: no live tool in PATH
- Semble used: no
- Understand Anything used: no
- Advisory findings directly verified: `time_root` owner path, `proof_receipt_replay` locked-adjacent status, `Native/Ambitions/Integrations/CalendarReminders` live seam, `EventKitIntegrationService` name, missing `Native/Ambitions/Services/EventKitCalendarService.swift`
- Accepted owner candidates: `time_root`
- Accepted proof/wiring findings: Time / CalendarReminders live seam and local schedule helpers are source-present
- Advisory findings rejected: no parallel Calendar owner or UI clone was introduced
- Advisory-only findings used as proof: none
- Generated local tool artifacts staged: none
