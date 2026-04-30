# Ambitions 3.0 — Primitive Architecture

Status: Active Ambitions 3.0 product architecture canon  
Parent doc: [Ambitions 3.0 Front-End Redesign Index](./Ambitions_3_0_Front_End_Redesign_Index.md)  
Strategy brief: [Ambitions 3.0 Product Strategy Brief](./Ambitions_3_0_Product_Strategy_Brief.md)  
Last updated: 2026-04-30

---

## Purpose

This document consolidates the 230 Golden Launch Loop upgrades, Day Rail, Meridian, and 160 UI invention candidates into a smaller set of durable Ambitions primitives.

The idea banks remain source material. Implementation should be scoped through primitives, phases, state machines, and contracts.

---

## Architecture Rule

Ambitions 3.0 is primitive-led.

Do not build raw invention lists directly.

Build through these primitives:

1. Reality Rail
2. Action Closure Engine
3. Proof & Receipt Ledger
4. Capture → Placement Resolver
5. Step Execution System
6. Plan Life Suite
7. Trust & Memory Control Plane
8. Goal Mission Control
9. Recommendation Ledger
10. First Useful Object Onboarding
11. Review OS
12. Accessibility / ADHD Control Layer
13. Rail / Node Visual Grammar
14. Ambitions Operating Shell
15. External Surface Projection
16. Release / Market Proof System

---

# Primitive 1 — Reality Rail

Owner surface: Today  
Primary component: `AmbitionsDayRailView`  
Primary loop step: Do Today  
Priority: P0

Reality Rail is the product behavior layer of the Day Rail.

It shows:

- Start here
- one recommended step
- Now / Next / Later
- readiness
- closure needed
- proof saved
- protected/away context
- active step capsule
- end-of-day closure state

It absorbs:

- Day Rail
- Reality Rail
- Closure Diamond
- Proof Pulse
- Readiness Ring
- Day Pressure Band
- Protected Time Veil
- One-Decision Today
- Active Step Capsule

Must not become:

- task list
- calendar timeline
- dashboard
- focus timer
- productivity score

---

# Primitive 2 — Action Closure Engine

Owner system: Action Closure  
Primary surfaces: Today, Step Detail, Step Session, Goal Detail, Plan, Reviews  
Primary loop step: Close / Recover  
Priority: P0

Action Closure Engine resolves reality without shame.

Canonical outcomes:

- Completed
- Still Counts
- Rescheduled
- Not needed
- Blocked
- Waiting
- Needs Recovery
- Needs Review
- Review later

It absorbs:

- Still Counts Fast Path
- Closure Diamond
- Tomorrow Carryover Gate
- Day End Soft Closure
- Session Recovery Branch
- Goal Recovery
- Recovery Contract

Must not become:

- overdue system
- failure state
- streak repair
- nagging prompt

---

# Primitive 3 — Proof & Receipt Ledger

Owner system: Trust / Receipts / Proof  
Primary surfaces: Today, Goal Detail, Reviews, You  
Primary loop step: Save Proof  
Priority: P0

The ledger records what happened, what changed, why, who approved it, whether correction/undo is available, and what counted.

It absorbs:

- Golden Thread
- What Changed Trail
- Proof Pulse
- Proof Rail
- What Counted Today
- Weekly Life OS Receipt
- Trust Receipts
- Proof Highlights
- Still Counts Gallery

Distinctions:

- Receipt = what happened and what changed
- Proof = evidence that progress or reality-sync occurred
- Review = meaning extracted from proof and receipts

Must not become:

- gamification
- analytics dashboard
- disposable toast-only system

---

# Primitive 4 — Capture → Placement Resolver

Owner surfaces: Capture / Place flow  
Primary loop steps: Capture, Place  
Priority: P0

Capture is the safe intake surface. Placement Resolver decides where the captured thing belongs.

Destinations:

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

It absorbs:

- Quiet Command Sheet
- Capture Gravity
- Placement Preview
- Needs a Place Shelf
- Ready to Place
- Grow into Goal
- Capture as Proof
- Capture as Waiting
- Capture as Decision
- Capture Privacy Guard

Must not become:

- notes app
- chat assistant
- generic inbox
- task dump

---

# Primitive 5 — Step Execution System

Owner surfaces: Step Detail / Step Session  
Primary loop steps: Do Today, Close / Recover, Save Proof  
Priority: P0

The Step Execution System bridges recommendation and reality.

Step Detail explains:

- what this is
- why now
- what it supports
- readiness
- source facts
- done definition
- what counts

Step Session supports:

- step-first execution
- optional timer
- proof/notes capture
- pause
- adjust
- close the loop

It absorbs:

- Step Brief
- Done Definition
- Step Weight
- Step Shape
- Friction Notes
- Open Context
- Step Alternatives
- Proof Capture During Session
- Session Drift Detection
- Counts If Session Mode

Must not become:

- focus timer
- productivity mode
- generic task detail

---

# Primitive 6 — Plan Life Suite

Owner surface: Plan  
Primary loop step: Plan  
Priority: P0/P1

Plan is a full Life Planning Suite.

It helps users shape days, weeks, months, seasons, commitments, capacity, decisions, recovery, and goals into a believable life plan.

Sub-primitives:

- Day Shape
- Week Shape
- Life Shape
- Horizon
- Capacity Envelope
- Commitment Layer Stack
- Decision Deck
- Reflow Studio
- Recovery Planner
- Planning Defaults
- Vacation / Away Time

Must not become:

- calendar clone
- scheduling optimizer
- due-date list
- auto-planning black box

---

# Primitive 7 — Trust & Memory Control Plane

Owner surface: You  
Primary systems: What Ambitions Knows, Automation & Trust, Receipts & History  
Priority: P0/P1

Trust & Memory Control Plane makes personalization inspectable, correctable, and consent-based.

It absorbs:

- What Ambitions Knows
- Memory Source Card
- Automation Ladder
- Memory Review Ritual
- Privacy Preview
- Data Boundaries
- Correction Memory
- Trust Simulation
- Forget This Everywhere

Must not become:

- data console
- hidden profile
- AI settings page
- paywalled trust layer

---

# Primitive 8 — Goal Mission Control

Owner surfaces: Goals / Goal Detail  
Primary loop steps: Plan, Do Today, Save Proof  
Priority: P1

Goals Home is Ambition Portfolio. Goal Detail is Mission Control.

Required lanes:

- Overview
- Path
- Steps
- Proof
- Decisions
- Risks
- Assumptions
- Archive

It absorbs:

- Ambition Portfolio
- Goal Weather
- Next Visible Step Requirement
- Proof Rail
- Assumptions Lane
- Goal Risk Card
- Goal Decision Log
- Ambition Operating Record
- Goal Assumption Breaker
- Meaningful Minimum

Must not become:

- project board
- KPI dashboard
- task board
- motivational wall

---

# Primitive 9 — Recommendation Ledger

Owner system: Recommendation / Trust  
Primary surfaces: Today, Capture, Plan, Goals, You  
Priority: P0/P1

Recommendation Ledger keeps suggestions grounded and correctable.

It stores or projects:

- candidates considered
- chosen recommendation
- source facts
- assumptions
- not-chosen alternatives
- user response
- closure result
- correction
- future memory impact

It absorbs:

- Why This Everywhere
- Rail Why Not View
- Source Label System
- Recommendation Rejection Learning
- User Correction Over Model Guess
- Confidence Hidden, Evidence Visible
- Recommendation Cooling

Must not become:

- AI console
- confidence meter
- black box

---

# Primitive 10 — First Useful Object Onboarding

Owner surfaces: First Run / Capture / Placement  
Primary loop steps: Capture, Place, Trust  
Priority: P0

First Run proves value before setup.

Flow:

```text
Open → Capture one meaningful thing → Suggested place → Confirm or decide later → Receipt → See first useful next step
```

Must not become:

- account wall
- permission wall
- feature tour
- AI pitch
- paywall

---

# Primitive 11 — Review OS

Owner surfaces: You / Reviews / Goal Detail / Plan  
Primary loop steps: Save Proof, Plan  
Priority: P1/P2

Review OS turns history into what should happen next.

It absorbs:

- What Counted Today
- Weekly Life OS Receipt
- Review-to-Plan Bridge
- Proof Highlights
- Drift Detection
- Still Counts Gallery
- Decisions Made
- Review Memory Suggestions
- Reality Delta

Must not become:

- analytics dashboard
- scorecard
- retrospective guilt ritual

---

# Primitive 12 — Accessibility / ADHD Control Layer

Owner system: Accessibility / Cognitive Load  
Primary surfaces: all  
Priority: P0/P1

Cognitive accessibility is product architecture.

It absorbs:

- Cognitive Load Mode
- One Thing Mode
- Low Energy Day
- Time Blindness Support
- Too Much Escape Hatch
- No-Scroll First Value
- VoiceOver Rail Summary
- Motion Meaning Equivalence
- Touch Target Discipline

Must not become:

- hidden setting only
- post-launch polish
- reduced feature mode

---

# Primitive 13 — Rail / Node Visual Grammar

Owner system: Design System  
Primary surfaces: Today, Meridian, Goals, Plan, Reviews  
Priority: P1

Visual grammar:

- circle = step
- diamond = closure/decision
- document mark = proof/receipt
- muted node = waiting/protected
- aperture = capture

Must not become decorative rail usage everywhere.

---

# Primitive 14 — Ambitions Operating Shell

Owner system: App Shell  
Primary implementation: Ambition Meridian Shell  
Priority: P1/P2

Ambitions does not need to present as a generic five-tab app.

It preserves five canonical destinations while using a unique operating shell.

Canonical destinations:

- Today
- Goals
- Capture
- Plan
- You

Must preserve:

- one-tap destination access
- plain accessibility labels
- selected state
- routing stability
- deep-link safety
- fallback native routing during rollout

---

# Primitive 15 — External Surface Projection

Owner systems: Widgets, Live Activities, App Intents, Notifications  
Priority: P2/P3

External surfaces project Ambitions safely outside the app.

They must obey privacy projection, sensitive detail hiding, and protected-time notification rules.

Must not become:

- nag system
- lock-screen data leak
- premature platform expansion

---

# Primitive 16 — Release / Market Proof System

Owner systems: Product Marketing, QA, Screenshot Readiness  
Priority: P1/P2

Market proof shows the real Ambitions story through implemented or truthfully labeled surfaces.

It absorbs:

- Still Counts Screenshot
- Start Here Screenshot
- What Ambitions Knows Screenshot
- Life Shape Screenshot
- Investor Demo Story
- Release 3 songs by August 1 fixture

Must not show unimplemented capability as shipped.

---

## Implementation Rule

Every implementation batch must name the primitive it advances.

Every primitive must map to:

- Golden Launch Loop step
- owner surface
- state machine
- trust/privacy behavior
- accessibility behavior
- tests/previews
- implementation evidence

---

## Priority Rule

Build these first:

1. Reality Rail
2. Action Closure Engine
3. Proof & Receipt Ledger
4. Capture → Placement Resolver
5. Step Execution System
6. Plan Life Suite foundation
7. Trust & Memory Control Plane
8. Goal Mission Control foundation
