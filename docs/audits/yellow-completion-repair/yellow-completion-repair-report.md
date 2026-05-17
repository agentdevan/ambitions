# Yellow Completion Repair Report

Date: 2026-05-17

## Scope

Reviewed current Yellow completion evidence after FCP27 compile-debt repair, with emphasis on Yellow closeouts that were blocked by missing Mac proof, stale Plan-to-Time test expectations, test-target compile debt, or UI-lane validation debt.

## Yellow Reviewed

- FCP27 app-target compile debt: repaired before this report; local app build is Green.
- FCP28-FCP30 visual/control-plane closeouts: prior Yellow posture was partly caused by missing local Mac proof. The app now builds and launches on the local iPhone 17 simulator, but the UI validation lane is not clean and remains non-Green.
- PFC31-PFC40 proof reports: prior Yellow posture included Windows/WSL or unavailable-local-Mac caveats. Local Mac build proof now exists, and prompt/runner checks pass, but full test proof is not Green.
- RHC02 large-source debt: still Yellow. Broad source modularization remains out of scope for this repair.
- Source Atlas and runtime proof Yellows: still Yellow where unit assertions fail on source/freshness/offline fallback semantics.

## Repaired

- App-target compile debt is repaired and warning-clean in `output/logs/build-local-20260517-093215.log`.
- Test-target compile debt was repaired across stale Time/You compatibility seams:
  - Capture route and command tests now compile against `.timeSeed`, `.time`, and Time route targets where production has already migrated.
  - SwiftUI test classes that instantiate main-actor views are marked `@MainActor`.
  - Legacy profile-service and plan-route expectations that no longer match current source APIs were updated where the current API was unambiguous.
- Runtime launch proof was added:
  - `docs/audits/yellow-completion-repair/fcp28-runtime-screenshot-20260517.png`
- UI-lane warning repair was started:
  - Deprecated `onChange` calls in shared UI primitives were updated.
  - A stale unused Canvas path warning was removed.
  - Trust receipt action closures were made Sendable/MainActor-safe.
  - Shell continuity receipt dismissal is now exposed as an accessibility child instead of being hidden by a combined container.
  - Time smoke tests now launch with an explicit standard content-size category so simulator Dynamic Type state does not silently change the smoke lane.

## Validation

Verified:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./scripts/build-local.sh`
  - Result: Green
  - Log: `output/logs/build-local-20260517-093215.log`
- `make prompt-audit`
  - Result: Green with expected Yellow classification for prompt-like support/eval/template files
- `make batch-self-check`
  - Result: Green
- iPhone 17 simulator install/launch/screenshot
  - Result: app launched to Today and rendered the canonical bottom tabs

Not Green:

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./scripts/test-local.sh`
  - Latest log: `output/logs/test-local-20260517-095827.log`
  - Result: unit targets compile, but the unit suite still reports assertion failures and must not be called Green.
- Focused UI Time lane:
  - Latest log: `output/logs/ui-focused-time-fresh-20260517-123319.log`
  - Result: interrupted after repeated unresolved lookup for `time.timeline-strip` during `testDemoPlanPressureScrubberUpdatesSelectedDayAndReflowDecision`.
  - Status: non-Green. This is not accepted as known-noisy debt, not allowlisted, and not suppressed.

## Remaining Yellow To Fix

These should remain Yellow until repaired with source-truth review and focused tests:

- Screen-contract snapshots still contain stale Plan top-level tab expectations in several feature tests.
- You/Profile compatibility assertions are stale in multiple You and external-routing tests.
- Source Atlas tests still disagree with current source/freshness/offline fallback behavior.
- Ambition graph projection tests disagree on privacy classes, proof inclusion, and deterministic ordering.
- Today/Time tests still have stale copy and route expectations such as `Adjust plan` versus `Adjust time`.
- UI smoke tests still fail on current simulator navigation/scroll lookup and must not be used to claim accessibility or rendered-surface Green.
- Full FCP28/FCP29 visual/accessibility proof remains incomplete; the screenshot is launch/render evidence only.

## Claim Boundary

This repair makes local app-target compile debt Green and removes test-target compile blockers discovered during Yellow review. It does not make the full test suite, UI smoke suite, accessibility proof, visual QA proof, physical-device proof, TestFlight proof, App Store proof, or release posture Green. The UI lane remains explicitly non-Green until every UI warning/failure is fixed or narrowly justified in a dated validator allowlist.
