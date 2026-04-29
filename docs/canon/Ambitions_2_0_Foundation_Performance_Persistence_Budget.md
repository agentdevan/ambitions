# Ambitions 2.0 Foundation Performance and Persistence Budget

Batch 82 keeps the Phase B foundations ready for surface consumption without adding new product behavior. This document is an operational budget for Life Graph v1, Proof and Resource Graph v1, Commitment / Waiting / Promise Ledger v1, Action Closure / Receipt System v1, and Safe Automation Boundary / Undo Rules v1.

## Scope Boundary

- This budget covers deterministic projections, bounded query posture, schema preservation, export/import implications, and future sync/conflict constraints for the shared foundations added in Batches 77-81.
- It does not implement export, import, sync, calendar writes, automation execution, undo execution, Trust Ledger, Correction Center, widgets, App Intents, Live Activities, or broad UI consumption.
- It does not add persistence stores for the Phase B foundation projections. Repo truth at Batch 82 is that these foundations remain value-semantic domain models and projections.

## Projection Budgets

### Life Graph

- Relationship projections must reject malformed endpoints and self-relationships before UI consumption.
- Duplicate relationships must be deduped by deterministic relationship ID.
- Query helpers must return deterministic ordering for incoming, outgoing, related-object, source-object, lane, and breadcrumb projections.
- Breadcrumb traversal must stay bounded by an explicit depth and must stop on cycles.
- Future surfaces must query by object, lane, type, or a bounded depth instead of walking the entire graph in render paths.

### Proof and Resource Graph

- Proof and resource projections must reject malformed attached or source objects.
- Duplicate proof and resource references must dedupe by stable reference keys before relationship projection.
- File, photo, calendar, external, and person resources are manual/reference-only until an owning provider batch exists.
- Projection code must not touch network, file, contact, calendar, or photo providers.
- Proof remains qualitative and structural; do not add proof scores, confidence percentages, or fake progress.

### Commitments, Waiting, and Promise Ledger

- Commitment, waiting, and person references must be validated, deduped, and ordered deterministically before projecting relationships or social-load signals.
- People are manual local references. The foundation must not read Contacts, Calendar, notifications, or external provider data.
- Social-load signals remain qualitative labels derived from explicit records only.
- Future repository queries must be bounded by person, attached object, state, due/follow-up window, or explicit limit.

### Action Closure and Receipts

- Receipt projections must reject malformed receipts and duplicate receipt IDs before producing display summaries or Life Graph relationships.
- Safe failure receipts must preserve unchanged facts and must not claim that undo, calendar, export, sync, or external work occurred.
- Display summary APIs must accept explicit limits for future surfaces.
- Receipts are value-semantic domain projections in Batch 82. No receipt store, Trust Ledger, or undo executor exists in this budget.

### Safe Automation and Undo Rules

- Policy decisions must have deterministic IDs based on action kind, source domain, and stable target references.
- Confirmation-gated, never-automate, unsupported, and safe-local categories must stay explicit.
- Undo policy must continue to bridge to `ActionReceiptUndoAvailability` without running undo.
- External, destructive, sync, export, calendar-writing, memory-forgetting, and broad-reflow actions must remain confirmation-gated, blocked, unsupported, or never-automate.

## Persistence and Migration Budget

- No new persistence was added for the Phase B foundations in Batches 77-81.
- Future persistence must be additive and preserve each model's `schemaVersion`.
- Destructive migrations are not allowed without a later explicit canon decision and test plan.
- Relationship, proof/resource, promise/waiting, receipt, and safe automation records must preserve object IDs, source/target endpoints, placeholder-only boundaries, timestamps where present, and schema versions.
- Future repository APIs should be bounded by object, kind, state, time/window, or explicit limit. Unbounded fetches must not be introduced into SwiftUI body work.
- UI-only identifiers are not valid sync identities.

## Export / Import and Sync Implications

- Export/import must preserve object IDs, schema versions, relationship endpoints, attachment targets, receipt unchanged facts, policy decision inputs, and placeholder-only external reference boundaries.
- M03 proves this at the portable snapshot service level for legacy pre-manifest packages, malformed package decode failures, partial reference warnings, and no-lost-data merge preservation across goals, proof, receipts, captures, and memory/teaching signals.
- External references remain manual/reference-only unless a later owning batch implements a provider.
- Future sync/conflict work must treat Life Graph relationships, proof/resources, promise/waiting records, receipts, and safe automation decisions as explicit local records with stable IDs. It must not infer conflict truth from display ordering or transient UI state.
- This budget does not claim sync exists and does not apply conflict resolutions.

## Surface Consumption Rules

- Build projections once per service/view-state boundary when practical, then pass value results to UI.
- Do not recompute full graph, receipt, promise, proof/resource, or safe automation projections in SwiftUI body code.
- Prefer object-scoped, lane-scoped, type-scoped, time-windowed, or explicitly limited helpers.
- Do not add timing thresholds, fake measured claims, scores, confidence percentages, or readiness percentages to satisfy this budget.
