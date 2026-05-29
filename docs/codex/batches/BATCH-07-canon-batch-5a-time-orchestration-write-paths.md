# Batch 07 — Canon Batch 5A / Time Orchestration Foundation (Write Paths Only)

<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_surface_multiple_active_batches, stale_or_unknown_active_status
> Prior recommended actions: Expedite
> Candidate references: AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-stale_or_unknown_active_status-57796227

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->

<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap, merge-overlap-before-proof, status-expedite
> Dispositions: clarify-status-before-use, merge-before-proof, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->

## Status

Completed

## Goal

Create the first time-orchestration foundation through write-only calendar and reminder actions so Ambitions can turn selected work into real calendar events or reminders without yet reading calendars, doing conflict analysis, or building availability logic.

## In Scope

- audit the current native time, calendar, and reminders seams
- formalize EventKit-facing service boundaries for write-path actions only
- implement or refine add-to-calendar action flow for selected steps and goals
- implement or refine add-to-reminders action flow for selected steps and goals
- add authorization and request plumbing only at the write-path level needed by this batch
- add or refine minimal domain and service models for time-action requests and results if needed
- wire existing services and screens only as much as needed to invoke the write-path actions
- add focused tests for service boundaries, write-path behavior, and denied or unavailable permission handling
- keep required usage-description and config truth aligned if the native app requires it

## Out Of Scope

- calendar read access
- availability search
- conflict detection
- day-pressure or week-pressure logic
- EventKit-based recovery logic
- App Intents
- widgets / Live Activities
- sync
- life graph / household / device work
- broad UI redesign
- speculative scheduling intelligence

## Current Repo Notes

- The native app already has `CalendarRemindersServicing`, `EventKitIntegrationService`, container wiring, Info.plist usage descriptions, and Today / Goal Detail write actions.
- The repo also already contains some conflict-detection and event-fetch scaffolding that should be treated as deferred read-path work, not as supported Batch 5A behavior.
- Batch 5A should tighten the existing seam rather than redesign time orchestration.

## Exit Criteria

- calendar and reminder creation flows remain protocol-backed and testable
- Today and Goal Detail invoke write-path actions without implying schedule awareness
- read or conflict behavior is removed from the supported Batch 5A flow or clearly quarantined for later work
- generation, build, targeted tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Completion Notes

- `xcodegen generate` passed
- simulator build passed
- targeted EventKit and calendar/reminder action-flow tests passed
- full `AmbitionsTests` validation passed

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
