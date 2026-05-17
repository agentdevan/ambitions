# Ambitions 3.0 — Information Architecture And Routing Model

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Shell doc: [Ambitions 3.0 Operating Shell](./Ambitions_3_0_Ambitions_Operating_Shell.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines Ambitions 3.0 information architecture and routing behavior.

The app should feel unique, but navigation must remain stable, understandable, and testable.

---

## Core Rule

Ambitions has five canonical destinations inside the Ambitions Operating Shell:

- Today
- Goals
- Capture
- Plan
- You

These destinations are not optional. They are the routing backbone.

The visible shell may be custom and Ambitions-native.

---

## Destination Jobs

| Destination | Job |
|---|---|
| Today | Execute what matters now. |
| Goals | Understand direction, path, proof, risk, and next visible step. |
| Capture | Put raw intent somewhere safe. |
| Plan | Shape life into something believable. |
| You | Control setup, trust, memory, reviews, privacy, and support. |

---

## Routing Ownership

### Today owns

- Reality Rail
- Step Detail entry from rail rows
- Step Session entry from Start now
- Action Closure prompts
- Proof/receipt peeks tied to current day

### Goals owns

- Ambition Portfolio
- Goal Detail / Mission Control
- Goal Path
- Goal Proof Rail
- Goal Decisions / Risks / Assumptions
- Goal Archive

### Capture owns

- Capture Composer
- Placement Resolver entry
- Needs a Place
- Ready to Place
- Grow into Goal
- Capture receipts

### Plan owns

- Day Shape
- Week Shape
- Life Shape
- Horizon
- Capacity
- Commitments
- Decisions
- Reflow
- Recovery
- Planning Defaults usage

### You owns

- Planning Setup settings
- Schedule & Availability
- Planning Defaults ownership
- Away Time setup
- Automation & Trust
- What Ambitions Knows
- Receipts & History
- Reviews
- Privacy / Export / Support

---

## Modal / Sheet / Full-Screen Rules

### Use sheets for

- Why this?
- Close the loop
- Place it
- Change this
- Receipt peek
- Memory confirmation
- Reflow preview when compact

### Use full screens for

- Step Session
- Goal Detail
- Plan room
- What Ambitions Knows
- Receipts & History
- Reviews
- Automation & Trust deep controls

### Use peeks for

- short explanations
- source facts
- proof saved
- receipt previews
- privacy summaries

---

## Deep Link Rules

Deep links should route to the owning destination first, then the object.

Examples:

- step -> Today or Goal Detail depending context
- goal -> Goals / Goal Detail
- receipt -> You / Receipts & History, or object-specific trail
- memory -> You / What Ambitions Knows
- plan decision -> Plan / Decisions

---

## Shell Rules

The shell may look unique, but it must preserve:

- one-tap access to canonical destinations
- stable order
- selected state
- accessibility labels
- routing testability
- native fallback during rollout

---

## Back Behavior

Back should move from detail to owner surface.

Examples:

- Step Session -> Step Detail or Today
- Goal Detail -> Goals
- Plan room -> Plan
- What Ambitions Knows detail -> You
- Receipt detail -> Receipts & History or object trail

---

## Avoid

- adding new top-level destinations
- routing through generic dashboards
- hiding essential navigation behind gestures
- making Capture a floating-only action with no destination identity
- making Meridian own content routes
- making Today own full planning depth

---

## Acceptance Criteria

IA is mature when:

- every object has an owning destination
- deep links restore orientation
- shell state does not obscure destination identity
- sheets/full screens/peeks have clear ownership
- Codex can test routing paths
- no new top-level destination is needed to add depth
