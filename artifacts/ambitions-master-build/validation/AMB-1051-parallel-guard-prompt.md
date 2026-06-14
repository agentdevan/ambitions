# AMB-1051 Parallel Guard Prompt

Issue: `AMB-1051`
Train: `M01.T03`
Project: Ambitions Personal Life OS Runtime + Native iPhone App Master Build Program
Batch type: source-changing

## Scope

Extend the existing local-first persistence and privacy boundary with privacy classes, protected mode, secure-storage boundary review, redaction filters, validators, and focused tests. Use existing persistence, portable snapshot, storage package boundary, trust/privacy, receipt, and replay owners where they already exist. Do not create a second persistence runtime, second export system, separate privacy engine, custom backend, telemetry path, cloud LLM dependency, or write-capable external service.

## Canonical Owner Boundary

The change must extend canonical owners under `Native/Ambitions/Persistence`, existing domain/trust privacy boundaries, and focused tests under `Native/AmbitionsTests/Persistence` or the directly owned trust/privacy test surface. Any new helper must be local to those owners and must not become a parallel runtime intelligence path.

## Required Runtime Wiring

Every runtime-affecting path in this train must preserve:

- Privacy classes as inspectable local storage/export policy, not hosted profiling.
- Protected mode as a fail-closed local review state that blocks unsafe export/indexing paths.
- Secure-storage boundaries for user-owned local and optional user-owned iCloud data.
- Redaction filters for portable snapshot, support, receipt, and replay inspection surfaces.
- `SourceRecord` boundaries for any source-backed storage/export/replay evidence.
- `Receipt` as the durable trust artifact for meaningful storage, privacy, export, reset, or review changes.
- `ReplayTrace` continuity for privacy boundary inspection, recovery, and audit trails.
- `What Ambitions knows` inspection for user-owned review, correction, reset, and delete controls.
- Private user data must stay out of public/R2/source-pack paths.

## Implementation Targets

- Define or extend privacy classes for local-only, user-iCloud eligible, support-redacted, public-reference, receipt, replay, and source-backed storage categories.
- Add a protected-mode secure-storage boundary report or equivalent existing-owner adapter that identifies blockers before export, support bundle, indexing, or source cache paths can touch private user data.
- Add deterministic redaction filters for sensitive receipt/replay/source fields while preserving enough inspection context for trust review.
- Add validators that fail closed when private storage categories are export-safe, support-visible without redaction, R2/public eligible, or missing `SourceRecord`, `Receipt`, `ReplayTrace`, or `What Ambitions knows` inspection paths.
- Add focused tests for local-first protected mode, redaction, export/indexing policies, and validator failure cases.
- Preserve existing reset/delete controls and do not silently mutate user data.

## Non-Claims

This issue does not claim release readiness, App Store readiness, TestFlight readiness, physical-device proof, accessibility certification, performance certification, privacy/legal approval, external security audit approval, or full program completion.
