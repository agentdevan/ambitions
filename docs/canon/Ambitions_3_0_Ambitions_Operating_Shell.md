# Ambitions 3.0 — Ambitions Operating Shell

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Related doc: [Ambitions 3.0 Ambition Meridian Shell SwiftUI Build Spec](./Ambitions_3_0_Ambition_Meridian_Shell_SwiftUI_Build_Spec.md)  
Last updated: 2026-04-30

---

## Purpose

This document defines the endgame for Ambitions navigation and shell behavior.

Ambitions should not feel like a generic five-tab utility app. It should feel like a premium life operating system with stable destinations inside a distinctive operating shell.

---

## Core Rule

Replace this concept:

```text
five-tab shell
```

with this concept:

```text
five canonical destinations inside the Ambitions Operating Shell
```

---

## Canonical Destinations

The five canonical destinations remain:

- Today
- Goals
- Capture
- Plan
- You

These are stable for:

- routing
- accessibility
- deep links
- user orientation
- state restoration
- App Intents
- testing

They do not have to be presented as a standard visible tab bar.

---

## Shell Thesis

The Ambitions Operating Shell is the app-wide orientation layer.

It gives access to Today, Goals, Capture, Plan, and You without making the app feel like a generic tabbed productivity app.

---

## First Implementation

The first custom shell implementation is:

```text
Ambition Meridian Shell
```

The Meridian is a bottom connected-node navigation instrument.

---

## Future Shell States

Allowed shell states:

- Meridian Shell: global navigation spine
- Capture Aperture: global capture emphasis
- Active Step Capsule: when Step Session is active
- Plan Lens Accessory: when user is deep in planning
- Receipt / Proof Caption: when a meaningful receipt or proof event just happened
- Recovery Context: when the app is in recovery posture

---

## Shell Must Preserve

The shell must always preserve:

- one-tap access to each canonical destination
- clear selected destination
- plain accessibility labels
- predictable back behavior
- deep-link safety
- state restoration
- non-gesture-only navigation
- native routing fallback during rollout

---

## Shell Must Not Become

The shell must not become:

- a task control strip
- a second Day Rail
- a persistent Close button
- a dashboard caption stack
- an AI command bar
- a hidden navigation puzzle
- a replacement for content hierarchy
- a reason to add more destinations

---

## Destination Copy

User-facing labels remain:

- Today
- Goals
- Capture
- Plan
- You

Avoid visible labels:

- Profile
- Insights
- Habits
- Tasks
- Calendar
- AI

---

## Shell Captions

Allowed captions:

- Today
- Plan
- Today · Step · 18m
- Today · 1 closure
- Saved · Still Counts
- Away protected
- Capture saved
- Guided

Not allowed:

- multi-line status stacks
- motivational copy
- plan recommendations
- task controls
- persistent urgency
- red-badge debt

---

## Implementation Strategy

1. Preserve native routing infrastructure where useful.
2. Implement custom shell visually behind a feature flag or fallback.
3. Keep destination semantics stable.
4. Add routing tests before visual rollout.
5. Add accessibility label tests before default rollout.
6. Do not implement shell and major tab content rewrites in the same batch unless explicitly scoped as prototype.

---

## Accessibility Rules

Each destination must expose:

- plain name
- selected/unselected state
- one-tap activation
- stable order
- no visual-only state

The shell must work with:

- VoiceOver
- Dynamic Type
- Reduce Motion
- one-handed use
- external keyboard/switch behavior where applicable

---

## Acceptance Criteria

The shell is mature when:

- the app no longer feels like a generic tab bar product
- five canonical destinations remain obvious
- routing is stable
- accessibility is plain
- Capture is prominent but not a generic plus button
- active-step and receipt states can appear without turning the shell into a dashboard
- fallback native routing remains possible during implementation
