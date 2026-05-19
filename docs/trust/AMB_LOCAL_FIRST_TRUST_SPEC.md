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
- export controls
- delete / reset flow with receipts

## Red flags

- Any claim of cloud-first operation without receipt is prohibited.
