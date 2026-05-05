# Ambitions Codex Quality System
<!-- markdownlint-disable MD013 -->

Status: Active Codex OS quality layer for remaining global batches
Date: 2026-05-05

## Purpose

The Codex Quality System, or CQS, makes every later Ambitions batch run through
senior-engineer review behavior before code, docs, scripts, or claims reach the
repo. CQS is not a product feature train. It is an operating-system layer for
scope control, review quality, repair cycles, evidence packets, and hard-Red
stops.

## Non-Negotiables

- Work on `main` unless the user explicitly says otherwise.
- Preserve `Today / Goals / Capture / Plan / You`.
- Do not widen Ambitions into a dashboard, habit tracker, calendar clone, notes
  app, chatbot wrapper, KPI surface, or generic productivity app.
- Do not hide validation failure, weaken gates, delete tests to pass, or turn
  future canon into claimed implementation.
- Do not make legal, privacy, release, App Store, TestFlight, device, public
  accessibility, sync, AI runtime, or LDI claims without matching evidence.
- Do not edit production app code during CQS source-truth batches unless a
  later CQS implementation batch explicitly allows it.

## Review Board

Every remaining batch must behave as if reviewed by:

- Staff iOS Architect.
- Senior SwiftUI Engineer.
- Apple Design Award-level Product Designer.
- Accessibility Lead.
- Privacy Counsel Reviewer.
- App Store Review Specialist.
- Performance Engineer.
- Security Engineer.
- QA Lead.
- Release Engineer.
- FAANG Handoff Auditor.

## Required Batch Cycle

1. Execute only the current batch scope.
2. Validate with the strongest repo-supported commands for the changed area.
3. Classify as Green, Accepted Yellow, Recoverable Red, or Hard Red.
4. Repair Recoverable Red in scope.
5. Split a narrow repair batch only when the repair is safer as its own unit.
6. Commit only Green or Accepted Yellow, one batch at a time.
7. Continue only when global order and train rules allow.

## Accepted Yellow Requirements

Accepted Yellow must name:

- why the risk is safe to carry;
- the owner for the risk;
- the future repair path;
- evidence that the batch did not introduce a Hard Red;
- what is explicitly not claimed.

## Recoverable Red

Recoverable Red includes doc QA failure, stale registry/context/run-state, a
missing audit report, lint/format issues, copy drift, missing accessibility
labels, missing Reduce Motion equivalents, missing preview fixtures, focused
test failures with clear local cause, generic UI drift that can be repaired
without weakening canon, file-size issues repairable by extraction, or global
order mismatches repairable by stricter gates.

## Hard Red

Hard Red stops immediately when continuing could break the app, corrupt data,
weaken canon, hide security/privacy risk, require unsupported legal/privacy/
release/App Store claims, require human legal/device/signing/credential proof,
delete tests to pass, weaken gates, or require a user product decision that
cannot be inferred from source truth.

## Quality Bar

No remaining batch should look prompt-built. CQS rejects vague helpers, generic
cards, duplicated models, fake intelligence, TODO residue, hidden mutation,
over-named components, broad abstractions without need, or UI that merely
renames existing generic surfaces.

## Evidence Packet

Every batch report must include what changed, why, alternatives considered,
files touched, validation run, screenshots/previews when relevant,
accessibility impact, privacy impact, performance impact, rollback path,
Yellow/Red classification, and next eligible batch.

## Final CQS Gate

Before late handoff gates such as FCP28, PFC39, FCP29, PFC40, and AOS27, CQS
requires no unresolved prompt-built smell, clean architecture evidence,
build/test evidence, bounded privacy/legal claims, app bundle and repo handoff
cleanliness, no AI-slop UI, and no unsupported release claims.
