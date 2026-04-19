# Batch 03 — Canon Batch 1 / Domain Foundation

## Status

Completed

## Goal

Build the minimum strong domain foundation that future capture evolution, planning, recovery, orchestration, sync, and life-graph work can reuse without inventing parallel seams.

## In Scope

- audit and normalize shared domain models where needed
- establish or refine stable IDs, timestamps, and explicit state/status enums for reusable domain entities
- introduce or formalize a version-safe domain event/history model where the current repo lacks one
- introduce or formalize Goal Memory event schema scaffolding only where it fits the current architecture cleanly
- add or formalize:
  - `ExecutionModes`
  - `NarrativeMomentum`
  - `CauseOfDrift`
  - confidence/recommendation-confidence shared types
- formalize the canonical command/action protocol only where the current app still relies on surface-specific action contracts
- formalize service boundaries for capture, planning, recovery, orchestration, and sync
- refine the canonical deep-link / external route model only if later shared action infrastructure needs a stronger common seam
- add or update focused tests for shared domain primitives and contracts

## Out Of Scope

- heavy UI changes
- new screens beyond minimal compilation plumbing
- planning-engine behavior beyond shared types/contracts
- recovery-engine behavior changes beyond shared contracts
- time orchestration implementation
- App Intents
- widgets / Live Activities
- sync backend implementation
- life graph / career maps / household logic
- device/runtime-separation work
- opportunistic refactors unrelated to domain foundations

## Current Repo Notes

- Existing foundation already covers part of this batch and should be strengthened instead of duplicated:
  - `Goal`, `GoalPlan`, `Step`, `ProgressEvidence`, and `GoalFeedbackEvent` already provide baseline schema and history seams.
  - `AppExternalRoute` and `AppExternalRouteTranslator` already provide a canonical deep-link/external routing seam.
  - `CaptureServicing` plus repository-backed app services already establish part of the service-boundary shape.
  - `RescheduleEngine` and orchestration contracts already exist, so this batch should formalize shared reusable types beneath them rather than rebuild their behavior.
- Because repo control files already use `00`-`02` for pre-canon cleanup work, this file keeps the next operational slot as `03` while naming the active implementation scope explicitly as Canon Batch 1.

## Exit Criteria

- shared domain identifiers, timestamps, and state enums are explicit and reusable
- event/history seams are version-safe where later batches need them
- service boundaries for capture, planning, recovery, orchestration, and sync are clear enough for later extension and sync work
- no new feature-specific logic islands are introduced for shared domain concepts
- focused tests cover the new or tightened contracts

## Completion Note

- Batch 03 landed as a bounded domain-foundation pass without persistence migrations or route/snapshot churn.
- Validation completed for diff hygiene, project generation, native simulator build, and focused unit tests covering the touched domain and service seams.
