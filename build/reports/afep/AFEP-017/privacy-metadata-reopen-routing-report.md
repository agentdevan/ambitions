# AFEP-017 Privacy Metadata and Reopen Routing Report

## Verified
- Phase 04 repair-pass revalidation completed on 2026-06-01 with no additional source repair required.
- Continuation tokens now gate exact IDs behind `metadataClass == .exactReopen`.
- Fallback-root continuations now collapse to canonical roots before exact IDs are exposed.
- `ExternalObjectReopeningProjector` handoff metadata now carries `kind`, `id`, `root`, `metadataClass`, and `redaction`.
- Sensitive handoff candidates no longer export goal or step IDs in `userInfo`.
- `AppExternalRouteTranslator.route(fromContinuation:)` now returns the canonical root tab for fallback-root continuations.
- Focused tests cover exact reopen routes and canonical fallback routes for goal, step, receipt, and capture continuations.
- `AmbitionsTests/ExternalSurfaceActionPayloadTests` passed after executing 12 tests.
- `AmbitionsTests/ExternalRoutingTests` passed after executing 40 tests.

## Failed And Repaired
- Slash-prefixed wrapper filters reported success while executing 0 tests; those runs are excluded from proof.
- Fully qualified focused-test filters first exposed stale fallback-root expectations, including receipt ID leakage through route payloads and memory-lens URLs. Test expectations were repaired to prove canonical-root fallback unless `metadataClass == .exactReopen`.

## Not Passed
- No on-device lock-screen/widget/Handoff rendering was executed.
- No device privacy capture was executed.

## Not Verified
- Real widget text rendering on a device.
- Real Live Activity lock-screen rendering on a device.
- Real Handoff metadata transfer on a device.

## Blocked
- None.

## Human/Device Follow-Up
- If device proof is required later, validate the same routes and metadata labels on simulator or hardware.
