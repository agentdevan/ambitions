# Batch 08 — Canon Batch 5B / Time Orchestration Intelligence (Read Paths)

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
