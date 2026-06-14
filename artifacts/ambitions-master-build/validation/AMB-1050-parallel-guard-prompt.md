# AMB-1050 Parallel Guard Prompt

Issue: `AMB-1050`
Train: `M01.T02`
Project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program
Batch type: source-changing

## Scope

Extend the existing migration-safe local persistence foundation with versioned schema inspection, migration plan review, reset and recovery review flows, compaction hooks, adapters, and migration validation. Use the existing SwiftData persistence owner, storage schema ledger, migration scaffold, backup service, portable snapshot service, recovery coordinator, and focused persistence tests.

## Canonical Owner Boundary

The change must extend the current persistence and migration owners under `Native/Ambitions/Persistence` and focused tests under `Native/AmbitionsTests/Persistence`. Do not create a second persistence runtime, second migration engine, separate reset system, separate backup ledger, custom backend, telemetry path, cloud LLM dependency, or write-capable external service.

## Required Runtime Wiring

Every runtime-affecting path in this train must preserve:

- Versioned storage/schema state as an inspectable local artifact.
- `SourceRecord` boundaries for any source-backed migration, backup, restore, or recovery evidence.
- Migration plans as reviewable, receipt-backed, fail-closed objects.
- `ReplayTrace` continuity for any migration review, rollback assessment, or recovery inspection trail.
- Pre-migration backup and dry-run validation before any migration execution posture.
- Reset/recovery as explicitly reviewed and non-destructive unless separately authorized by existing user-owned controls.
- Compaction hooks as queued/reviewed local maintenance intent, not silent mutation.
- `What Ambitions knows` inspection for user-owned review and correction of migration/recovery evidence.

## Implementation Targets

- Add a migration foundation adapter or approved equivalent that composes schema ledger, migration plan scaffold, invariant checks, pre-migration backup, portable snapshot dry-run, compaction hook review, and recovery assessment.
- Validate no-change and mutation scenarios deterministically.
- Add focused tests for versioned migration review, backup/dry-run/recovery composition, compaction hook review, and fail-safe reset behavior.
- Preserve local-first storage and user-owned iCloud continuity boundaries.
- Keep private user data out of public/R2 paths.
- Preserve existing reset/delete controls and do not silently mutate user data.

## Non-Claims

This issue does not claim migration execution in production, release readiness, App Store readiness, TestFlight readiness, physical-device proof, accessibility certification, performance certification, privacy/legal approval, or full program completion.
