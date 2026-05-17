# Ambitions Batch Status Normalization Rules

## Purpose

Defines the only allowed operational states for Ambitions execution governance.

These rules supersede append-only registry interpretation.

---

# Single-State Rule

Every train or batch must resolve into exactly one primary operational state.

Forbidden:
- simultaneous queued + complete
- complete + blocked
- historical + active
- superseded + next eligible

---

# Allowed States

## COMPLETE_GREEN

Requirements:
- implementation exists
- implementation committed
- proof exists
- tests/evidence exist where applicable
- no unresolved Red gates
- not superseded
- no conflicting registry state

---

## COMPLETE_ACCEPTED_YELLOW

Requirements:
- implementation exists
- implementation committed
- bounded unresolved advisories exist
- no unresolved Red gates
- advisories explicitly documented

Typical advisories:
- missing device proof
- missing screenshot proof
- missing manual accessibility proof
- deferred compatibility cleanup

---

## PARTIAL

Requirements:
- implementation started
- implementation incomplete
- proof incomplete
- successor work required

---

## ACTIVE

Requirements:
- currently executing
- authoritative active train
- unresolved work in progress

---

## QUEUED

Requirements:
- valid future work
- not blocked
- not superseded
- not already implemented

---

## BLOCKED

Requirements:
- dependency unresolved
- governance restriction
- missing prerequisite proof
- explicit execution stop condition

---

## SUPERSEDED

Requirements:
- replaced by newer authority
- no longer operational truth
- retained only for historical evidence

---

## HISTORICAL

Requirements:
- preserved evidence only
- not active execution truth
- not valid next-step authority

---

## INVALIDATED

Requirements:
- proof failure
- implementation contradiction
- broken assumptions
- incorrect completion claim

---

## NEEDS_RECONCILIATION

Requirements:
- contradictory operational state
- insufficient implementation proof
- unresolved governance ambiguity

---

# Completion Proof Requirements

A batch may not be marked complete unless:

- implementation exists
- implementation is committed
- implementation scope is identifiable
- proof path exists
- evidence exists
- no unresolved Red
- not superseded by newer canon

Prompt existence alone is insufficient.

Audit existence alone is insufficient.

Narrative declaration alone is insufficient.

---

# Queue Integrity Rules

The following are forbidden:

- duplicate next-batch declarations
- orphan queue entries
- stale active declarations
- superseded queued work
- implementation without tracking
- tracked completion without implementation proof

---

# Registry Structural Rules

The registry must:

- separate canon from execution
- separate historical from active
- separate proof from roadmap
- separate queued from complete
- separate blocked from superseded

The registry must not behave as:

- append-only narrative history
- mixed roadmap/canon/evidence document
- speculative implementation tracker

---

# Release Claim Safety

No operational state implies:

- App Store readiness
- TestFlight readiness
- legal compliance
- accessibility certification
- platform completion
- production readiness
- AI/runtime completion
- sync completion

unless explicit proof exists.
