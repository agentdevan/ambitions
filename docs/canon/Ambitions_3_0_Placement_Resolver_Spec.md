# Ambitions 3.0 — Placement Resolver Spec

Status: Active Ambitions 3.0 front-end canon child doc  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Product Purpose

The Placement Resolver decides where a captured or loose object belongs without turning Capture into an inbox or Plan into a dumping ground.

Placement is the second step in the Golden Launch Loop:

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

---

## Surface Ownership

Primary owner: Capture / Place flow  
Supporting surfaces: Today, Plan, Goals, Goal Detail, You, Trust Center  
Primary component concept: `PlacementResolverView`

Placement is not a top-level tab.

---

## User Problem Solved

Users often know what they need to get out of their head, but not where it belongs.

Placement solves:

- capture ambiguity
- routing friction
- task-vs-goal confusion
- already-done proof capture
- waiting/blocker capture
- schedule-impact capture
- low-confidence save safety

---

## Canonical Placement Destinations

- Today
- Plan
- Existing Goal
- New Goal
- Grow into Goal
- Proof
- Waiting
- Decision
- Needs a Place
- Archive / Not Needed

---

## Placement Decision Tree

1. Is this already done? -> Proof
2. Is this a concrete standalone action? -> Task / One-Step Goal
3. Does this belong to an existing goal? -> Attach to Goal
4. Is this broader than one action? -> Grow into Goal
5. Is someone or something blocking it? -> Waiting
6. Does it require a choice? -> Decision
7. Does it affect schedule or capacity? -> Plan
8. Is Ambitions unsure? -> Needs a Place

---

## Placement Preview Anatomy

A placement preview must show:

- original capture text
- suggested destination
- object type that will be created
- where it will appear
- whether it affects Today
- privacy label if relevant
- primary action: `Place it`
- secondary action: `Change`
- safe action: `Decide later`

---

## Capture Post-Input States

After input, Capture enters one of four states:

1. Suggested Place — Ambitions recommends one destination.
2. Needs a Decision — Ambitions asks one compact question.
3. Needs a Place — Ambitions saves safely without forcing structure.
4. Saved as Proof / Step / Goal / Waiting / Decision — user confirmed route.

---

## Placement Confidence Behavior

High confidence:

- show recommended destination
- allow quick confirm
- create receipt
- allow Change

Medium confidence:

- show recommended destination
- show why it likely belongs there
- make Change prominent
- create receipt after confirm

Low confidence:

- ask one compact question, or
- save to Needs a Place

Low confidence must not block saving.

---

## Capture-To-Today Priority Check

If a user places a capture into Today and Today already has a recommended step, Ambitions should ask lightly:

```text
Add this to today, or keep your current Start here?
```

Options:

- Add to Today
- Keep Start here
- Decide later

---

## Placement Privacy Check

If a capture includes possible health, financial, relationship/family, location, calendar-derived, or sensitive Life Area details, Ambitions should:

- save it safely
- avoid external-surface display
- avoid creating memory automatically
- ask before using it as confirmed memory
- show a privacy-safe placement receipt

---

## Placement Receipt

Every placement creates a receipt with:

- original capture
- suggested route
- chosen route
- destination
- user override if any
- undo if safe
- correction route
- privacy state where relevant

Receipt examples:

```text
Saved as Step · Today
Saved to Needs a Place
Attached as Proof · Music Goal
Placed in Waiting · Alex reply
```

---

## Needs a Place Language

Allowed:

- `3 things need a place`
- `Ready to place`
- `Decide later`

Avoid:

- Inbox zero
- Unprocessed
- Overdue captures
- Capture backlog

---

## Non-Goals

Do not use Placement Resolver to:

- add a new top-level tab
- create a generic inbox
- create a general Notes object
- auto-promote tasks into goals without confirmation
- silently affect Today priority
- silently create sensitive memory
- make Capture feel like a triage dashboard before input

---

## Accessibility Requirements

- Route choices must be reachable without gestures.
- Suggested destination must be VoiceOver-readable.
- Privacy labels must not rely on color alone.
- Save failure must preserve input and be announced.
- Change route must be accessible from the receipt.

---

## Acceptance Criteria

Placement is acceptable when:

- every capture gets a clear route or safe temporary state
- the user can confirm or change the suggested place
- placement consequences are visible before or immediately after confirmation
- placement produces a receipt
- wrong routes are correctable
- sensitive/high-impact placement follows trust rules
- Today priority is not silently displaced
