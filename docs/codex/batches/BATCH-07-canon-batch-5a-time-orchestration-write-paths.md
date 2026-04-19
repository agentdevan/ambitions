# Batch 07 — Canon Batch 5A / Time Orchestration Foundation (Write Paths Only)

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
