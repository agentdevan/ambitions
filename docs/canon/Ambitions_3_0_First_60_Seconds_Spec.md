# Ambitions 3.0 — First 60 Seconds Spec

Status: Active Ambitions 3.0 first-use canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

The first 60 seconds must prove Ambitions is useful before the app asks the user to configure a life system.

First Run is not account setup. It is the first proof that Ambitions can organize something meaningful.

---

## Core Thesis

A new user should experience this within the first minute:

```text
I entered something meaningful. Ambitions put it somewhere. I can see what happens next.
```

---

## First 60 Seconds Loop

```text
Open → Capture one meaningful thing → Suggested place → Confirm or decide later → Receipt → See first useful next step
```

---

## Non-Goals

First 60 seconds must not become:

- account creation wall
- calendar permission flow
- notification permission flow
- questionnaire
- display-density setup
- AI personalization pitch
- generic onboarding carousel
- feature tour
- paywall
- dashboard tutorial

---

## Required Sequence

1. Premium static preview.
2. Prompt: `What do you want to organize?`
3. User enters one meaningful thing.
4. Ambitions suggests a place.
5. User confirms, changes, or decides later.
6. Receipt appears.
7. User lands in the destination or Today.
8. Optional: Schedule & Availability prompt only after value is shown.

---

## First Useful Object

The first successful session should create one of:

- Capture
- Goal
- Task / One-Step Goal
- Plan seed
- Proof
- Waiting item
- Decision
- Needs a Place item

A skipped onboarding should still land safely in Today with an empty state and Capture action.

---

## First Prompt

Primary prompt:

```text
What do you want to organize?
```

Supporting examples should be concrete and life-like:

- Release 3 songs by August 1
- Get finances ready for move-in
- Plan a lighter week
- Save feedback from a mentor
- Prepare for a job transition

Avoid:

- generic placeholder text
- productivity slogans
- AI assistant framing
- overly personal examples without context

---

## Route Receipt

The first route receipt must show:

- object type
- destination
- next useful action
- correction route

Examples:

```text
Saved as Goal · Creative
Saved as Step · Today
Saved to Needs a Place
Attached as Proof · Music Goal
```

---

## Skip State

If the user skips first-run setup, Today should show:

```text
Nothing needs you yet.
```

Primary action:

```text
Capture something
```

Secondary actions:

```text
Create a goal
Set schedule
```

Do not imply the user failed setup.

---

## Permission Timing

Do not request during first 60 seconds:

- calendar permission
- notification permission
- location permission
- account creation
- contacts permission
- cloud sync

Allowed after value is shown:

- Schedule & Availability prompt
- Planning Defaults prompt
- optional reminder value prompt

---

## Starfield Rule

A restrained dark-sky/starfield visual signature is allowed for First Run.

It must remain:

- quiet
- premium
- background-level
- non-gamified
- readable

Do not use starfield as a decorative overlay on Today, Plan, Goals, or You unless future canon explicitly changes this.

---

## Accessibility Requirements

- Static preview has an equivalent VoiceOver description.
- Capture input has a clear label.
- Suggested place is VoiceOver-readable.
- Receipt correction is accessible.
- Skip path is visible and non-punitive.
- Dynamic Type does not hide the primary input or confirmation action.

---

## Acceptance Criteria

First 60 seconds is acceptable when:

- user can create or save one useful object without setup friction
- no permissions are requested before value
- no account is required
- the object has a destination or safe temporary state
- receipt appears
- correction route exists
- the user can reach Today safely
- the experience proves the Golden Launch Loop instead of explaining it
