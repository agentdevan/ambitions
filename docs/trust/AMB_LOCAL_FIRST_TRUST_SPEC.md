# AMB_LOCAL_FIRST_TRUST_SPEC

## Trust posture

- Core loop is local-first and offline capable.
- No required custom server dependency.
- No required Ambitions account for core loop.
- No required cloud AI dependency for core loop.
- No analytics SDK dependency required for core loop.

## Required proofs

- Offline-core-loop evidence.
- data export proof.
- delete/reset proof.
- local memory control proof.
- privacy redaction proof.
- network dependency scan.
- third-party dependency ledger.
- privacy manifest alignment when available.
- receipt for every memory-control change.

## Trust states

- local_only
- network_unavailable
- sync_unavailable
- source_stale
- runtime_degraded
- privacy_redacted
- memory_disabled
- memory_reset_pending
- export_ready
- delete_reset_pending

## Local memory controls

- opt-out controls for memory persistence
- disable-learning controls
- export controls
- delete / reset flow with receipts
- redaction controls for stored personal context
- reset-pending state when a delete/reset request has not yet completed

## Memory control states

- memory_enabled
- memory_disabled
- memory_redacted
- memory_reset_pending
- export_ready
- delete_reset_pending

Memory control state changes must be accompanied by a receipt that records the source action, affected data classes, and resulting trust state.

## Red flags

- Any claim of cloud-first operation without receipt is prohibited.
