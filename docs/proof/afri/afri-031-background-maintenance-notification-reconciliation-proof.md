# AFRI-031 Background Maintenance And Notification Reconciliation Proof

Issue: AMB-383 / AFRI-031

## Scope

- Added notification maintenance reconciliation that registers categories and refreshes the local notification schedule on app launch and active lifecycle reentry.
- Kept stale or unavailable external-surface leases from scheduling an old next-step notification.
- Routed notification `complete` actions to Today recovery/closure posture instead of mutating or opening stale goal detail directly.
- Preserved notification side-effect ledger receipts for scheduled, cleared, blocked, and failed-safe refresh outcomes.

## Safety Boundaries

- Notification reconciliation remains local-only.
- Stale notification actions do not silently complete, defer, split, move, or mutate user data.
- Today recovery entry keeps closure review visible before any behavior change.
- SourceRecord, Receipt, ReplayTrace, and You / What Ambitions Knows inspection boundaries remain proof-bounded and local-first.
- No entitlement, signing, background mode, remote push, network, tracking SDK, hosted inference, backend, dependency, persistence schema, or release setting changed.

## Validation

- Pre guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-383 --prompt /tmp/AMB-383-AFRI-031-guard-prompt.md` passed Green.
- Focused tests initially failed because `testNotificationTranslatorRoutesGoalPayloadToGoalDetail` still expected notification completion to open Goal Detail. Repaired the stale expectation to Today recovery.
- Focused tests rerun: `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -configuration Debug -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsTests/LocalNotificationFoundationTests -only-testing:AmbitionsTests/ExternalRoutingTests -only-testing:AmbitionsTests/ExternalActionCommandServiceTests` passed with 63 tests, 0 failures.
- Post guard: `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-383 --prompt /tmp/AMB-383-AFRI-031-guard-prompt.md --changed-from HEAD ...` passed Green after concept-lock repair for `proof_receipt_replay` and `persistence_external_surfaces`.
- Diff whitespace: `git diff --check` passed.
- Forbidden provider/tracking scan over touched source/proof passed with no matches.

## Proof Boundary

This is simulator unit-test and source evidence only. It does not claim physical-device background execution, push delivery reliability, lifecycle UI proof, App Store/TestFlight readiness, public accessibility proof, privacy/legal approval, or release readiness.

## Rollback

Revert the AMB-383 commit to remove active lifecycle reconciliation, stale lease notification clearing, notification-complete Today recovery routing, tests, and this proof packet.
