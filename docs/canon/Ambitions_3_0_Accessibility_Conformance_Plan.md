# Ambitions 3.0 — Accessibility Conformance Plan

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

Accessibility in Ambitions 3.0 is product architecture, not a final polish pass.

Ambitions must be usable when the user is overloaded, distracted, low-energy, using assistive technology, or reading at large text sizes.

---

## Accessibility Pillars

1. VoiceOver clarity
2. Dynamic Type resilience
3. Reduce Motion meaning equivalence
4. Non-color state
5. Touch target safety
6. Cognitive load reduction
7. Plain language
8. Privacy-safe external surfaces

---

## Cognitive Accessibility Rules

Top-level first viewport should ask for no more than one meaningful decision.

Every overloaded state should offer:

```text
Make this lighter
```

Every surface should answer quickly:

- what is this?
- what matters here?
- what can I do next?

---

## Touch Target Rules

Rail nodes are visual indicators. Rows and cards are the tappable targets.

Do not rely on tiny nodes for primary actions.

Primary actions should be easy to hit one-handed.

---

## VoiceOver Rules

Every rail-based component must provide a non-visual summary.

Example Today summary:

```text
Today has one recommended step, one closure needed, and one protected block.
```

Every destination in the shell must expose:

- destination name
- selected state
- accessible activation

---

## Dynamic Type Rules

Primary actions must remain visible at large text sizes.

If a visual rail cannot fit, collapse to readable rows rather than truncating meaning.

---

## Reduce Motion Rules

Every meaningful motion must have a text/state equivalent.

Examples:

- Proof saved
- Plan adjusted
- Moved to Saturday
- Closed as Still Counts

---

## Non-Color State Rules

State must not rely on color alone.

Use text, icon, shape, or hierarchy.

Examples:

- diamond node = closure/decision
- document mark = proof/receipt
- muted label = waiting/protected
- explicit text = Private item

---

## Surface Requirements

### Today / Reality Rail

- VoiceOver summary
- tappable rows
- non-color readiness states
- closure prompts clear without visual rail
- proof saved text equivalent

### Capture

- input field clear label
- placement preview readable
- save failure preserves text
- sensitive capture state announced calmly

### Plan

- scope labels readable
- pressure states not color-only
- reflow preview accessible
- decisions reachable without gestures

### Goals

- goal state labels plain
- next visible step or reason readable
- proof rail accessible as list

### You

- grouped rows readable
- memory cards explain source and effect
- pause/delete/change actions accessible

### Shell

- destinations plain
- selected state obvious
- Capture accessible
- no gesture-only navigation

---

## Codex-Only Accessibility Evidence

Codex should provide:

- accessibility label changes
- preview coverage for large text where possible
- reduced motion state notes where motion is added
- touch target reasoning for rail/node systems
- no-color-only state explanation

---

## Acceptance Criteria

A batch passes accessibility conformance planning when:

- VoiceOver labels exist for primary controls
- primary action remains discoverable
- state is not color-only
- motion has text/state equivalent
- top-level density is controlled
- no tiny node is the only target
- copy is plain and non-shaming
