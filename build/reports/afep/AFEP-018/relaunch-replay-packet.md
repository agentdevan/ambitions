# AFEP-018 Relaunch / Replay Packet

## Scope
- Continuation and relaunch payloads remain rooted in canonical external objects.
- Replay-safe redaction stays preserved in continuation payloads and deep-link routing.

## Verified
- `ExternalSurfaceActionPayloadTests` confirms:
  - canonical command payloads preserve legacy keys
  - deep links stay stable
  - stale/unavailable continuity state is inspectable from the snapshot
- `ExternalRoutingTests` confirms:
  - routing from deep links, notifications, widgets, Spotlight, Handoff, share extension, and App Intents remains deterministic
  - background and relaunch route sources are recorded without changing the routed destination
- `ExternalSurfaceSnapshotTests` confirms:
  - lifecycle reconciliation state round-trips through encoded snapshots
  - stale / fresh / unavailable source states remain inspectable in canonical continuity
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalSurfaceActionPayloadTests`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalRoutingTests`
- `make xcode-focused-test BATCH=AFEP-018 TEST=AmbitionsTests/ExternalSurfaceSnapshotTests`

## Not Passed
- None.

## Not Verified
- Device relaunch after a real process kill.
- Live Activity or widget behavior after an OS-managed process restart.
- App Store/TestFlight provenance and release claims.

## Blocked
- None.

## Human / Device Follow-Up
- If the batch later needs end-to-end proof, rerun continuation and relaunch flows on a device and confirm the same canonical root/IDs/replay redaction in the live UI.

## Notes
- Continuation payloads still omit private identifiers when metadata is not eligible for exact reopen.
- Relaunch fallback remains conservative: stale or unavailable state can fall back to the canonical root without silently mutating user data.
