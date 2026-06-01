# AFEP-009 Replay Browser Screenshot Plan

Batch: `AFEP-009`

## Status

No screenshot was captured in this phase.

## Planned Capture

If the replay browser gets surfaced in UI wiring later, capture the trust-history proof row that renders the read-only execution ledger item and verify:

- the title reads `Execution ledger`
- the review label reads `Read-only replay browser`
- the privacy label reads `Local-only and inspectable`
- the summary includes:
  - source record IDs
  - receipt IDs
  - replay trace IDs
  - runtime snapshot checksum and provenance hash
  - privacy and export posture
  - proof and closure immutability
  - replay validation state

## Notes

- This batch kept the browser path value-only.
- The existing UI route was not widened.
- Any future screenshot proof should be treated as visual evidence only, not release proof.
