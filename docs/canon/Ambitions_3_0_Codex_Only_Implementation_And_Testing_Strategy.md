# Ambitions 3.0 — Codex-Only Implementation And Testing Strategy

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Implementation plan: [Ambitions 3.0 Front-End Implementation Batch Plan](./Ambitions_3_0_Front_End_Implementation_Batch_Plan.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines how Ambitions 3.0 implementation can proceed with Codex-only testing and evidence.

Human review is not a required gate in this strategy. Codex must compensate with stricter automated checks, explicit evidence logs, and clear planned-vs-shipped status.

---

## Core Rule

Codex may implement only scoped primitives, phases, or batches.

Codex must not implement raw idea banks wholesale.

---

## Required Batch Output

Every Codex implementation batch must include:

- canon docs read
- primitive affected
- Golden Launch Loop step affected
- files changed
- what changed
- what did not change
- tests run
- tests added
- previews added or updated
- accessibility evidence
- content/copy guard evidence
- privacy/trust evidence where relevant
- known deferred work
- implementation status

---

## Test Hierarchy

Codex should use this hierarchy where applicable:

1. compile/build
2. unit tests
3. domain state-machine tests
4. view model tests
5. projection tests
6. routing tests
7. copy guard scans
8. privacy projection tests
9. accessibility label tests
10. preview fixture coverage
11. no-regression grep scans
12. implementation summary evidence

---

## Required Test Families

### Product loop tests

- capture creates safe destination
- placement produces receipt
- recommended step passes eligibility
- Step Detail opens from rail row
- Step Session opens only from Start now
- closure creates correct outcome
- proof saved projects to ledger

### State-machine tests

- Step state transitions
- Capture lifecycle
- Placement lifecycle
- Reflow lifecycle
- Closure lifecycle
- Proof lifecycle
- Memory lifecycle
- Recommendation lifecycle

### Trust/privacy tests

- sensitive item projects privately
- external surface redaction
- memory requires consent where needed
- deletion/pause stops memory use
- no silent meaningful plan change

### Copy tests

- banned terms absent from visible strings
- accessibility labels updated
- receipt grammar enforced
- no AI confidence/productivity score language

### Accessibility tests

- VoiceOver labels exist for key controls
- Dynamic Type does not hide primary actions in previews where possible
- non-color state exists
- touch targets are not tiny-node dependent
- Reduce Motion equivalent where motion is meaningful

---

## Evidence Log Format

Codex completion should include:

```text
Build: pass/fail + command
Tests: pass/fail + command
Copy guard: pass/fail + command
Preview coverage: files/scenarios
Accessibility: labels/states verified
Privacy: projection rules verified
Deferred: exact items
Status: implemented / previewed / tested / not device-verified / not release-ready
```

---

## Forbidden Codex Behavior

Codex must not:

- add new top-level destinations
- build all inventions at once
- replace the Day Rail with a generic timeline
- make Meridian own tab content
- turn Plan into a calendar clone
- turn Reviews into analytics dashboard
- turn Capture into chat/inbox/notes
- expose AI confidence or productivity scores
- show shame/failure language
- claim device or release readiness without evidence
- silently remove compatibility without migration note

---

## Definition Of Done

A batch is done only when:

- implementation matches scoped canon
- tests pass or failures are documented
- copy guard ran or was impossible with explanation
- previews cover primary states
- accessibility labels exist for key interactions
- sensitive/private behavior is safe where relevant
- batch summary states what remains unimplemented

---

## Release Readiness Boundary

Codex-only testing can make a feature:

- implemented
- previewed
- tested

Codex-only testing does not by itself prove:

- real-device quality
- App Store readiness
- human usability
- legal/privacy compliance
- full accessibility conformance

If human review is intentionally ignored, docs must state that release evidence is automated-only.
