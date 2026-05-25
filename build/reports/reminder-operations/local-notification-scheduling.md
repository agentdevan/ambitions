# Local Notification Scheduling

## Summary
This batch installs the local reminder notification scheduling abstraction for TRAIN_04G.

The source now routes local reminder delivery through `LocalNotificationFoundation`, which:
- checks notification authorization before refreshing the schedule
- builds a single next-step local notification request from the external surface snapshot
- registers notification categories with local actions
- records local-only side effects for scheduled, cleared, blocked, and refresh-failed outcomes
- observes pending, delivered, and cancelled lifecycle states where the platform supports them

## What Ambitions knows
- Notification authorization is modeled as `notDetermined`, `denied`, `authorized`, `provisional`, and `ephemeral`.
- The abstraction treats `denied` and `notDetermined` as blocked for schedule refresh.
- The request lifecycle is not invented as a second system; it is observed through the same local notification client and tracked locally.
- The broader `proof_receipt_replay` closeout is still pending and must not be claimed complete here.

## Proof boundary
This is source-level proof only.

No Xcode build, XCTest, simulator, device, accessibility, performance, CI, TestFlight, or App Store proof is claimed in this batch because the operator paused the Xcode lane.

## Evidence
Implemented source:
- `Native/Ambitions/Notifications/LocalNotificationFoundation.swift`
- `Native/AmbitionsTests/App/LocalNotificationFoundationTests.swift`
- `docs/codex/canonical-owner-map.yml`

Proof artifacts:
- `build/reports/reminder-operations/IOS26-T04G-B02.md`

Validation posture:
- `python3 scripts/ambitions-champion-coverage-check.py --batch IOS26-T04G-B02` -> Green
- `python3 scripts/ios26-flagship-preflight.py --batch IOS26-T04G-B02` -> Green
- `python3 scripts/ios26-core-replacement-proof-shape-check.py --batch IOS26-T04G-B02` -> Green
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch IOS26-T04G-B02 --prompt prompts/batches/IOS26-T04G-B02-local-notification-scheduling-abstraction.md --changed-from b27a15ffc5aa712cbef54c9e9b70ea1031f55e31 --batch-type source-changing --allow-yellow` -> Yellow
- `git diff --check` -> Green

Owner repair:
- `docs/codex/canonical-owner-map.yml` now classifies `Native/Ambitions/Notifications` under `proof_receipt_replay` so the new lifecycle type is not treated as a parallel owner.

## Claim boundary
Allowed:
- local scheduling abstraction exists
- authorization-gated schedule refresh exists
- lifecycle tracking exists where supported

Forbidden:
- release or device readiness
- accessibility verification
- performance validation
- complete proof_receipt_replay closeout

## Yellow
The Xcode lane remains skipped by operator instruction, so the batch closes Yellow even though the source and proof shape are installed.
