# Ambitions 3.0 — Release Readiness And Evidence Gates

Status: Active Ambitions 3.0 release governance canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Testing strategy: [Codex-Only Implementation And Testing Strategy](./Ambitions_3_0_Codex_Only_Implementation_And_Testing_Strategy.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines what evidence is required before Ambitions 3.0 features can be called implemented, tested, device-verified, or release-ready.

---

## Status Ladder

Use these statuses exactly:

- canonized
- designed
- implementation-scoped
- implemented
- previewed
- tested
- device-verified
- release-ready

Do not collapse these statuses.

---

## Evidence Gates

### Gate 1 — Canon scoped

Required:

- active canon doc named
- primitive named
- Golden Launch Loop mapping
- non-goals identified

### Gate 2 — Implemented

Required:

- code changed
- build succeeds or failure documented
- implementation summary names files changed
- compatibility risks documented

### Gate 3 — Previewed

Required:

- deterministic preview or fixture
- normal state
- empty/first-use state where relevant
- failure/recovery/sensitive state where relevant

### Gate 4 — Tested

Required:

- unit or view model tests
- routing tests where navigation changes
- state-machine tests where state changes
- copy guard where visible language changes
- privacy projection tests where sensitive/external surfaces change

### Gate 5 — Accessibility checked by Codex

Required:

- labels/hints for primary controls
- non-color state
- touch target reasoning
- Dynamic Type note where relevant
- Reduce Motion equivalent where relevant

### Gate 6 — Device-verified

Required only when claimed:

- real-device run evidence
- screen-size check
- performance notes
- platform behavior notes

### Gate 7 — Release-ready

Required:

- all relevant gates above
- App Store screenshot truth check
- privacy copy check
- no known P0/P1 blockers
- release summary

---

## Release Claims Boundary

Codex-only testing may support:

- implemented
- previewed
- tested

Codex-only testing alone does not prove:

- real-world usability
- legal compliance
- App Store approval
- full accessibility conformance
- device quality

If human review is intentionally skipped, the release note must say evidence is automated/Codex-only.

---

## Required Release Evidence Summary

Every release candidate should include:

```text
Build:
Tests:
Copy guard:
Privacy guard:
Accessibility notes:
Preview fixtures:
Device status:
Release blockers:
Known deferred work:
Implementation status:
```

---

## P0 Blockers

Do not call Ambitions 3.0 release-ready if:

- Today cannot show Start here
- Capture can lose input
- closure uses shame/failure language
- meaningful plan changes can happen silently
- private details leak to external surfaces
- user cannot correct memory/recommendations where required
- copy guard fails on banned visible terms
- top-level navigation is unstable
- app cannot build

---

## Acceptance Criteria

Release readiness is mature when every major Ambitions 3.0 primitive has a status, evidence, test path, and known gap list.

## F17-F30 Handoff Completion Train Tracking

The active release-quality continuation is `docs/codex/batch-trains/F17_F30_FAANG_HANDOFF_COMPLETION_TRAIN.md`.

Release, App Store, TestFlight, physical-device, public accessibility, and FAANG handoff claims remain unavailable unless the relevant F17-F30 batch gate records matching evidence. F27 is the final FAANG handoff gate rerun; it may produce PASS only if the handoff gate passes with build, test, doc QA, traceability, privacy, accessibility, architecture, and release-claim evidence.
