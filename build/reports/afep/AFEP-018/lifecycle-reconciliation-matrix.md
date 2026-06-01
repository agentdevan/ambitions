# AFEP-018 Lifecycle Reconciliation Matrix

## Scope
- Canonical lifecycle reconciliation state now lives on `ExternalSurfaceContinuityState.lifecycle`.
- Supported contexts: app, extension, widget, Live Activity, background, relaunch.
- Source state labels: fresh, stale, unavailable.
- Background maintenance remains read-only with respect to user data.

## Verified
- `python3 scripts/ambitions-champion-coverage-check.py --batch AFEP-018`
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AFEP-018 --prompt prompts/batches/AFEP-018.md --batch-type source-changing`
- `xcodegen generate`
- `make xcode-build-for-testing BATCH=AFEP-018`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalSurfaceActionPayloadTests`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalRoutingTests`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalSurfaceSnapshotTests`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/LocalNotificationFoundationTests`

## Not Passed
- None.

## Not Verified
- Real device background execution behavior.
- OS-level relaunch behavior outside unit-test boundaries.
- Accessibility, privacy/legal, release, TestFlight, App Store, and CI claims.

## Blocked
- None.

## Human / Device Follow-Up
- If a later batch needs device proof, verify background refresh and relaunch on a physical device before making broader claims.

## Notes
- `ExternalSurfaceContinuityState` now carries an explicit lifecycle reconciliation object with no silent user-data mutation policy.
- `AppExternalRouteSource` also accepts `background` and `relaunch` for deterministic route-source recording.
