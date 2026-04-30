# Ambitions 3.0 — Migration And Deprecation Plan

Status: Active Ambitions 3.0 migration canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Language system: [Ambitions 3.0 Product Language System](./Ambitions_3_0_Product_Language_System.md)  
Last updated: 2026-04-30

---

## Purpose

This plan removes legacy Ambitions wording, routes, docs, and code identifiers without breaking routing or tests unexpectedly.

3.0 supersedes older conflicting front-end and language canon.

---

## Migration Principle

User-facing language moves first.

Internal identifiers may migrate gradually only when routing, tests, and compatibility are preserved.

---

## Required Renames

| Legacy | 3.0 replacement |
|---|---|
| Profile | You |
| profile tab | You destination |
| Insights | Reviews / Plan / You depending context |
| insights tab | Reviews route or Plan/You destination context |
| Habits | Goals / Steps / Reviews depending context |
| habits tab | no top-level destination |
| Focus Session | Step Session |
| Start Focus | Start now |
| bestNextMove | recommendedStep |
| next best move | Recommended step |
| Inbox | Needs a Place |
| Task | Step except Swift concurrency or external imported tasks |
| Project | Goal / Path / Ambition |
| AI confidence | Why this / Based on |
| Productivity score | qualitative state |
| Overdue | Needs closure |
| Failed | Needs recovery / Not completed as planned |
| Missed | Needs a quick check |

---

## Route Compatibility

Legacy routes may exist temporarily only when:

- deep links require them
- tests still cover compatibility
- migration docs mark them compatibility-only
- user-facing labels use 3.0 language

Compatibility routes must not reintroduce old visible language.

---

## Migration Phases

### Phase 1 — Visible copy

- update UI strings
- update accessibility labels
- update App Intent phrases where user-visible
- update previews and screenshot fixtures

### Phase 2 — Tests and fixtures

- update test names where practical
- update asserted visible strings
- mark compatibility tests explicitly

### Phase 3 — Docs

- replace old language in active canon
- keep migration references only in this doc and copy guard docs

### Phase 4 — Code identifiers

- rename high-risk identifiers like `bestNextMove`, `startFocus`, `focusSession`
- keep adapter aliases where needed
- remove aliases after compatibility tests pass

### Phase 5 — Cleanup

- run copy guard
- run routing tests
- update batch registry
- record remaining compatibility debt

---

## High-Risk Migration Areas

- root navigation
- AppTab enum or equivalent route definitions
- App Intents
- UI tests
- preview fixtures
- Today action enum
- Today view state
- Step Session routing
- You/Profile routes
- Insights/Reviews routes
- Habits/Goals compatibility routes

---

## Acceptance Criteria

Migration is mature when:

- no legacy wording appears in user-facing UI
- accessibility labels use 3.0 terms
- docs use 3.0 terms except migration references
- compatibility routes are marked compatibility-only
- tests pass
- copy guard passes
- implementation summary names remaining debt
