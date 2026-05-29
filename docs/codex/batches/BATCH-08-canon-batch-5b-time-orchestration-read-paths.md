# Batch 08 — Canon Batch 5B / Time Orchestration Intelligence (Read Paths)

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

Add the read-path time-orchestration layer so Ambitions can reason about availability, conflict detection, and schedule pressure using real calendar context, without yet moving into App Intents, widgets, or broader ambient-surface work.

## In Scope

- audit the current deferred EventKit read and conflict seams
- restore or formalize calendar-read access where justified
- implement conflict detection through the existing EventKit integration seam
- formalize nearby available-window reasoning through the current EventKit helper seam
- add or refine compact day-pressure derivation only where the output is immediately consumed
- update Today and Goals service consumption only as much as needed to surface truthful read-path-aware results
- add focused tests for calendar-read authorization states, conflict detection, nearby room reasoning, and read-path-aware service behavior
- keep all new logic protocol-backed and testable

## Out Of Scope

- App Intents
- widgets / Live Activities
- sync
- life graph / household / device work
- broad UI redesign
- speculative scheduling intelligence beyond current calendar-aware truth
- fully autonomous rescheduling based on calendar reads
- ambient-surface work

## Current Repo Notes

- Batch 5A intentionally quarantined conflict detection and left the read-path seam in place through `CalendarRemindersServicing`, `EventKitIntegrationService`, `EventKitStoreClient.fetchEvents`, and `CalendarConflictReport`.
- Today and Goal Detail already expose calendar-event creation actions and can consume compact read-aware result copy without new UI structures.
- The repo already requests full calendar access on iOS 17+ for event work, so Batch 5B should restore read intelligence on that existing permission path rather than creating a second authorization flow.

## Exit Criteria

- conflict detection is restored on the existing EventKit seam
- nearby room awareness is available when derivable from fetched calendar events
- compact schedule pressure is surfaced only where immediately consumed
- Today and Goal Detail use read-aware outputs without growing service-local calendar logic
- generation, build, targeted tests, and full `AmbitionsTests` validation pass before this batch is marked completed

## Completion Notes

- `xcodegen generate` passed
- simulator build passed
- targeted EventKit and calendar action-flow tests passed
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
