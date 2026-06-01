# AFEP-018 Background Maintenance Boundary Report

## Scope
- Background maintenance may refresh safe external projections.
- Background maintenance must not silently mutate user data.

## Verified
- `LocalNotificationFoundationTests` confirms:
  - authorized refresh schedules or clears only the local notification request
  - stale continuity clears the reminder instead of scheduling an old step
  - failed refreshes fail safely
  - background maintenance remains recorded as local-only side effects
- `ExternalSurfaceSnapshotTests` confirms lifecycle reconciliation state labels stale / fresh / unavailable source states without requiring user-data mutation.
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/LocalNotificationFoundationTests`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalSurfaceSnapshotTests`

## Not Passed
- None.

## Not Verified
- Device-level background fetch / refresh execution.
- User-visible background task scheduling outside the unit-test boundary.
- Any claim that background work runs while the app is suspended on a physical device.

## Blocked
- None.

## Human / Device Follow-Up
- Validate actual background refresh behavior on device before claiming production background execution.

## Notes
- `ExternalSurfaceLifecycleReconciliationState.backgroundMaintenanceMayMutateUserData` is `false`.
- The background path is safe only as an external-state refresh boundary, not as a user-data mutation boundary.
