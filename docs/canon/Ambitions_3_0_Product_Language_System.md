# Ambitions 3.0 — Product Language System

Status: Historical supporting canon; subordinate to `docs/truth/*`
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Last updated: 2026-04-30

---

## Purpose

This is the master language system for Ambitions 3.0.

Ambitions is the app name. Everything else may be upgraded.

The language system applies to:

- user-facing UI
- accessibility labels
- previews and fixtures
- App Intents where user-visible
- screenshots
- App Store copy
- repo docs
- new code identifiers where practical
- tests that assert visible strings

---

## Voice

Ambitions sounds:

- calm
- plain
- adult
- direct
- specific
- trustworthy
- lightly supportive
- human

Ambitions does not sound:

- robotic
- cute
- hype-driven
- hustle-coded
- therapy-coded
- corporate
- gamified
- AI-theatrical
- productivity-bro

---

## Core Language Thesis

Ambitions should center on these questions:

```text
What matters now?
Where does this belong?
Does this hold together?
Why this?
What changed?
What counted?
What can I do next?
```

---

## Master Phrases Ambitions Can Own

Use heavily and consistently:

- Start here
- What needs a place?
- Does this hold together?
- Close the loop
- Still Counts
- What changed?
- What counted?
- Proof saved
- You are in control

---

## Destination Names

Canonical destinations:

- Today
- Goals
- Capture
- Plan
- You

Do not call them `tabs` in user-facing UI. In implementation and docs, prefer:

- canonical destinations
- main destinations
- primary destinations

---

## Shell Language

Use:

- Ambitions shell
- Meridian
- main destinations
- Capture aperture
- active step
- closure needed
- proof saved

Avoid:

- five-tab shell
- profile tab
- insights tab
- habits tab
- bottom dock
- AI button
- command button

---

## Today Language

Use:

- Start here
- Recommended step
- Now
- Next
- Later
- Close the loop
- Still Counts
- What counted
- Proof saved
- Why this?
- Make smaller
- Adjust plan
- Review later

Avoid:

- best next move
- next best move
- Start Focus
- Focus Session
- task list
- overdue
- missed
- failed
- behind
- productivity
- score
- streak

Example:

```text
Start here
Record a rough chorus take
25 min · Creative · Ready
```

---

## Goals Language

Use:

- Goals
- Ambitions
- Path
- Milestone
- Step
- Proof
- Decisions
- Risks
- Waiting
- Parked
- Archive
- Why it matters
- Next visible step

Avoid:

- project
- task board
- KPI
- health score
- progress score
- objective dashboard

Examples:

```text
Next visible step
```

```text
Parked
Not active right now.
```

---

## Capture Language

Use:

- What needs a place?
- Place it
- Change
- Decide later
- Needs a Place
- Ready to Place
- Grow into Goal
- Save as proof
- Save as waiting
- Save as decision

Avoid:

- inbox
- backlog
- triage
- classify
- process
- unprocessed
- capture queue
- note
- chat
- assistant

Example:

```text
Saved to Needs a Place
You can decide later.
```

---

## Plan Language

Use:

- Plan
- Day Shape
- Week Shape
- Life Shape
- Horizon
- Capacity
- Commitments
- Decisions
- Reflow
- Recovery
- Planning Defaults
- Away Time
- Protected Time
- Open Time
- What holds
- What changed
- What can move
- What needs a decision

Avoid:

- calendar clone
- schedule optimizer
- auto-plan
- AI scheduler
- perfect plan
- productivity forecast
- workload score
- time management dashboard

Examples:

```text
Does this hold together?
```

```text
Week Shape
2 heavy days · 1 protected evening · 1 decision needed
```

```text
Reflow
Review what changes before Ambitions moves it.
```

---

## You Language

Use:

- You
- You are in control
- Planning Setup
- Schedule & Availability
- Planning Defaults
- Away Time
- Automation & Trust
- What Ambitions Knows
- Receipts & History
- Reviews
- Privacy
- Export
- Support

Avoid:

- profile
- account center
- settings dump
- analytics
- AI settings
- data console
- memory graph

Examples:

```text
You are in control
Guided suggestions are on.
```

```text
What Ambitions Knows
Review what shapes your recommendations.
```

---

## Closure Language

Use:

- Close the loop
- Completed
- Still Counts
- Rescheduled
- Not needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review
- Review later

Avoid:

- failed
- missed
- incomplete
- overdue
- behind
- broken streak

---

## Proof / Receipt Language

Use:

- Proof saved
- Saved as proof
- What counted
- What changed
- Receipt
- Receipts & History
- Changed by you
- Suggested by Ambitions
- You approved this
- Undo available
- Correction available

Avoid:

- achievement
- reward
- trophy
- streak
- log event
- audit entry in normal UI

Receipt pattern:

```text
[Result] · [Object] · [Destination or consequence]
```

Examples:

```text
Still Counts · Saved as proof
Rescheduled · Friday
Plan adjusted · You approved this
```

---

## Recommendation Language

Use:

- Recommended because
- Based on
- Why this?
- Not chosen
- You can change this
- Looks like this fits
- Suggested
- Needs your decision

Avoid:

- AI confidence
- model reasoning
- optimization score
- algorithm decided
- productivity score
- best possible step

---

## Sensitive Copy

Use:

- Private item
- Hidden details
- Saved privately
- Details hidden here
- Open to review

Avoid harsh or alarming privacy wording.

---

## Code Identifier Migration Guidance

Prefer new identifiers:

- `recommendedStep` instead of `bestNextMove`
- `stepSession` instead of `focusSession`
- `youNavigation` instead of `profileNavigation`
- `reviewPath` instead of `insightsPath` where semantically correct
- `needsAPlace` instead of `inbox`
- `proofReceipt` / `actionReceipt` instead of generic history where appropriate

Swift concurrency `Task {}` remains valid.

---

## Copy Acceptance Criteria

A feature passes copy review when:

- user-facing text is plain and human
- deprecated terms are absent from visible UI
- accessibility labels do not preserve legacy terms
- receipts follow the receipt grammar
- recommendations use source facts, not confidence
- errors state what remains safe
- empty states offer a useful next action
- sensitive states are calm and privacy-safe
