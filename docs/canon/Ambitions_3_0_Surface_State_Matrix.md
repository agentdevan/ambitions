# Ambitions 3.0 — Surface State Matrix

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Every top-level Ambitions surface and major drill-down must handle reality, not just ideal content.

This matrix prevents disconnected empty states, punitive recovery states, fake-success states, and one-off error handling.

---

## Required States

Every top-level surface and major drill-down must define these states where applicable:

1. First-use
2. Empty
3. Normal
4. High-density / many objects
5. Overloaded
6. Recovery
7. Away / protected
8. No schedule
9. No goals
10. Sensitive / private
11. Offline / local-only
12. Permission unavailable
13. Loading
14. Save failed
15. Action succeeded
16. Undo available
17. Undo unavailable
18. Needs confirmation
19. Needs review
20. Degraded but safe

A surface may mark a state as not applicable, but it must do so deliberately.

---

## Required State Copy Pattern

Every non-normal state must answer:

1. What happened?
2. What remains safe?
3. What can I do next?

Examples:

```text
This did not save. Your text is still here.
```

```text
Calendar access is unavailable. Plan still works manually.
```

```text
Nothing needs you right now. Capture something, choose from a goal, or leave today open.
```

---

## State Ownership By Surface

### Today

Required priority states:

- normal day
- active step
- recovery day
- overloaded day
- low-energy day
- away / protected day
- empty day
- no schedule
- end of day
- sensitive/private item

Today renders these through or directly attached to `AmbitionsDayRailView`.

### Capture

Required priority states:

- first-use
- typed input
- suggested place
- needs a decision
- needs a place
- save failed
- saved as step/goal/proof/waiting/decision
- sensitive/private capture
- duplicate possible

Capture must preserve raw input on failure.

### Place

Required priority states:

- recommended destination
- low confidence
- placement preview
- conflict with Today
- privacy check
- placement succeeded
- placement undo available
- placement failed safely

### Plan

Required priority states:

- day scope
- week scope
- month / life shape
- no schedule
- no calendar permission
- permission denied
- overloaded
- no longer holds
- protected / away
- reflow preview
- calendar write confirmation
- calendar write failed locally safe

### Goals

Required priority states:

- no goals
- active portfolio
- many goals
- goal needs review
- goal waiting
- goal blocked
- goal recovering
- proof available
- sensitive goal / private item

### Goal Detail

Required priority states:

- overview
- path missing
- next visible step missing
- proof empty
- risks active
- decisions available
- archive available
- goal parked
- goal ended
- goal completed

### Action Closure

Required priority states:

- one likely closure
- multiple closure options
- still counts
- blocked
- waiting
- needs recovery
- needs review
- undo available
- receipt created

### Proof / Receipts

Required priority states:

- proof saved
- receipt toast
- receipt peek
- receipt trail
- receipt search empty
- sensitive proof hidden
- correction available
- undo unavailable

### You

Required priority states:

- planning setup missing
- guided automation default
- memory learning active
- memory learning paused
- trust needs review
- export unavailable
- local-only
- platform status unavailable
- accessibility verification unknown

---

## Emotional Safety Rules

- Empty states should not imply failure.
- Overloaded states should offer a lighter path, not only a warning.
- Recovery states should make reality usable, not judge the user.
- Sensitive states should feel private, not alarming.
- Permission-unavailable states should preserve manual fallback.
- Failed actions should state what remains safe.

---

## Accessibility Rules

Every state must have:

- VoiceOver-readable status
- visible next action
- no color-only meaning
- Dynamic Type-safe layout
- Reduce Motion equivalent if state uses animation

---

## Acceptance Criteria

A front-end child spec is incomplete until it defines the applicable state matrix.

A surface implementation is incomplete until previews or fixtures cover the highest-risk states for that surface.
