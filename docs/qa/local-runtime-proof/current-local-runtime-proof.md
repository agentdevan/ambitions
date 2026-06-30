# LocalRuntimeProof Gate

Generated: `2026-06-30T23:01:26+00:00`
Status: `green`
Runtime law: `Command -> Event -> Projection -> Receipt -> Replay`

This artifact is a runtime-proof gate. It is not Visual Green, Release Green, privacy/legal approval, TestFlight readiness, or App Store readiness.

## Summary

- Checks: `6`
- Passed: `6`
- Warnings: `0`
- Blockers: `0`

## Checks

### architecture_inventory

- Status: `pass`
- Summary: Final architecture tree source parity is green.

### owner_directories

- Status: `pass`
- Summary: All 19 LocalRuntimeOS owners are source-present.

### integration_markers

- Status: `pass`
- Summary: Core command, event, projection, replay, search, and outbox integration markers are present.

### live_event_store_authority

- Status: `pass`
- Summary: Production runtime event authority is SQLite; JSONL authority is not selected by AppContainerFactory.

### mutation_bypass_scan

- Status: `pass`
- Summary: No high-risk mutation or external-write bypass candidates were found.

### truth_file_no_claim_gaps

- Status: `pass`
- Summary: Truth files no longer contain LocalRuntimeOS no-claim blockers.

## Allowed Claims

- LocalRuntimeOS source-present owner inventory can be reported when architecture_inventory passes.
- LocalRuntimeProof Green can be claimed only when this gate is green and current focused runtime tests also pass.

## Blocked Claims

- all meaningful Ambitions state changes route only through Command -> Event -> Projection -> Receipt -> Replay
- LocalRuntimeOS is complete
- app-wide command-only mutation is proven
- app-wide event replay and projection consumption are proven
- full side-effect outbox enforcement is proven
- privacy/legal, Visual Green, Release Green, TestFlight, or App Store readiness
