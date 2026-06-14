# AMB-1049 Parallel Guard Prompt

Issue: `AMB-1049`
Train: `M01.T01`
Project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program
Batch type: source-changing

## Scope

Extend the existing data lifecycle and replay foundation for deterministic receipts, command execution records, and runtime snapshots. Use the already wired repositories, typed models, fixtures, and focused validation paths. Do not create a separate proof ledger, receipt store, replay store, command log, or runtime snapshot system.

## Canonical Owner Boundary

The change must extend the existing canonical proof / receipt / replay owner and existing persistence repositories. Any new helper must be local to those owners or tests and must not become a parallel runtime intelligence path.

## Required Runtime Wiring

Every runtime-affecting path in this train must preserve:

- `SourceRecord` as the source boundary.
- `Receipt` as the durable trust artifact.
- `ReplayTrace` as the replay/inspection boundary.
- `What Ambitions knows` inspection for user-owned review and correction.

## Implementation Targets

- Persist receipts, command execution records, and runtime snapshots through existing wired repositories.
- Add bounded queries and typed replay inspection over persisted lifecycle records.
- Add fixtures or focused tests for persistence, replay inspection, and bounded query behavior.
- Preserve local-first storage and user-owned iCloud continuity boundaries.
- Keep private user data out of public/R2 paths.
- Preserve reset/delete controls where relevant.

## Non-Claims

This issue does not claim release readiness, App Store readiness, TestFlight readiness, device proof, accessibility certification, performance certification, privacy/legal approval, or full program completion.
