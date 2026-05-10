> T05b classification: Historical / supporting product-design context.
> This file is not current product, implementation, release, or Codex process authority.
> Current authority begins in `docs/truth/`; if any wording below says “Active,” read it as preserved Ambitions 3.0 context unless re-approved by `docs/truth/*`.

# Ambitions 3.0 Front-End Redesign Index

Status: Active Ambitions 3.0 parent canon  
Source override: [Ambitions 3.0 Source Of Truth Override](./Ambitions_3_0_Source_Of_Truth_Override.md)  
Rebuild model: [Ambitions 3.0 Rebuild Operating Model](./Ambitions_3_0_Rebuild_Operating_Model.md)  
Last updated: 2026-04-30

---

## Purpose

This document is the parent index for Ambitions 3.0.

Ambitions 3.0 is the primitive-led rebuild of Ambitions into a premium iPhone-native life execution system.

It is not a raw idea bank, visual refresh, generic productivity redesign, or new product category.

Ambitions 3.0 is governed by:

1. product strategy
2. product language
3. primitive architecture
4. state machines
5. Life Planning Suite
6. Ambitions Operating Shell
7. trust/privacy/memory controls
8. accessibility and cognitive-load constraints
9. Codex-only implementation and testing gates
10. release evidence truth

---

## Core Product Definition

Ambitions is a life execution system.

It helps raw intent become placed structure, placed structure become believable plans, believable plans become one clear step, real life become closure, and progress become proof.

```text
Capture → Place → Plan → Do Today → Close / Recover → Save Proof
```

---

## Ambitions 3.0 Supersession

Ambitions 3.0 supersedes older conflicting front-end, visual, interaction, navigation, wording, shell, Today, Capture, Plan, Goals, You, closure, proof, receipt, recommendation, and rebuild-process guidance wherever the 3.0 parent or linked 3.0 docs are more recent and explicit.

Canon status is not implementation status.

A concept can be:

- canonized
- designed
- implementation-scoped
- implemented
- previewed
- tested
- device-verified
- release-ready

Do not collapse these statuses.

---

## Canonical Destinations

Ambitions has five canonical destinations inside the Ambitions Operating Shell:

1. Today
2. Goals
3. Capture
4. Plan
5. You

These are stable for routing, accessibility, deep links, App Intents, tests, and user orientation.

They do not need to be presented as a generic five-tab visual shell.

The visible shell should become Ambitions-native through the Ambitions Operating Shell and Meridian direction once routing, accessibility, and fallback behavior are safe.

---

## Non-Negotiable Product Constraints

Ambitions 3.0 must not become:

- a generic task app
- a habit tracker
- a calendar clone
- a project-management board
- a fake AI dashboard
- a SaaS dashboard
- a productivity guilt machine
- a gamified streak app
- a chatbot
- a focus timer
- a notes app
- a wide app with too many exposed top-level features

No Ambitions 3.0 child spec should add new top-level destinations unless this parent canon is explicitly revised.

---

## Product Language Lock

Ambitions is the app name.

Everything else follows [Ambitions 3.0 Product Language System](./Ambitions_3_0_Product_Language_System.md).

Core phrases Ambitions should own:

- Start here
- What needs a place?
- Does this hold together?
- Close the loop
- Still Counts
- What changed?
- What counted?
- Proof saved
- You are in control

Avoid legacy or competitor-shaped language such as Start Focus, Focus Session, best next move, AI confidence, productivity score, overdue, failed, missed, profile tab, insights tab, habits tab, inbox, and generic dashboard language.

---

## Primitive-Led Architecture

Ambitions 3.0 implementation should be scoped through the 16 primitives in [Ambitions 3.0 Primitive Architecture](./Ambitions_3_0_Primitive_Architecture.md):

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

The 230 Golden Launch Loop upgrades and 160 UI invention bank remain active source material, but implementation should be scoped through primitives and phases, not raw idea count.

---

## Today / Reality Rail Rule

The Today signature object is `AmbitionsDayRailView`.

Reality Rail is the product behavior primitive of the Day Rail.

Today must preserve:

- Start here as one recommended step
- Now / Next / Later orientation
- row tap opens Step Detail
- Start now opens Step Session
- closure appears as a calm loop, not task debt
- proof appears as evidence, not gamification
- protected/away/low-control states are respected

Do not render a separate Hero Step Panel above the rail by default.

Compatibility mapping:

- v2 `HeroStepPanel` -> 3.0 `DayRailHeroStepCard`
- v2 `DayTimelineRail` -> 3.0 `AmbitionsDayRailView`
- v2 `ClosureCheckInPanel` -> 3.0 `DayRailCloseLoopCard`
- v2 `ReceiptTrail` / proof peek -> 3.0 `DayRailProofSavedCard`

---

## Plan Life Suite Rule

Plan is a full Life Planning Suite, not a small believability panel.

Plan owns:

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
- Vacation / Away Time
- Plan-to-Today handoff
- Today-to-Plan return

Plan asks:

```text
Does this hold together?
```

Plan must not become a raw calendar clone or AI scheduler.

---

## Ambitions Operating Shell Rule

The Ambitions Operating Shell owns app-wide orientation.

It preserves five canonical destinations while allowing the visible shell to become unique and premium through the Meridian and related shell states.

The shell must preserve:

- one-tap destination access
- selected state
- plain accessibility labels
- routing stability
- deep-link safety
- fallback native routing during rollout

The shell must not become a task control strip, second Day Rail, AI command bar, or hidden navigation puzzle.

---

## Top-Level Density Rule

Every top-level destination should show:

```text
1 signature object
1 primary action
1 contextual state strip
1 optional proof/trust/recovery prompt
Everything else drill-down
```

Top-level surfaces must not become equal-weight card stacks.

---

## Required Rebuild Docs

The active rebuild documentation system is indexed in:

- [Ambitions 3.0 Documentation System Index](./Ambitions_3_0_Documentation_System_Index.md)
- [Ambitions 3.0 FAANG Rebuild Documentation Completeness Matrix](./Ambitions_3_0_FAANG_Rebuild_Documentation_Completeness_Matrix.md)

Core required docs include:

- Product Strategy Brief
- North Star And Product Metrics
- Competitive Positioning And Language Research
- Rebuild Operating Model
- Primitive Architecture
- Product Language System
- Plan Life Suite Endgame
- Ambitions Operating Shell
- Information Architecture And Routing Model
- State Machines And Domain Flows
- Recommendation Eligibility Engine
- Evidence Hierarchy
- Personalization Consent Model
- Codex-Only Implementation And Testing Strategy
- Migration And Deprecation Plan
- Privacy Threat Model
- Accessibility Conformance Plan
- Release Readiness And Evidence Gates

---

## Child Doc Admission Test

A proposed Ambitions 3.0 child doc is allowed only if it:

1. owns a specific surface, component, model, primitive, or cross-system contract
2. does not duplicate an existing child doc
3. defines non-goals
4. names affected surfaces
5. names canonical components
6. defines state models or state behavior
7. defines actions and navigation
8. defines trust/receipt behavior
9. defines accessibility behavior
10. defines tests and previews
11. maps to the Golden Launch Loop
12. states whether it is implementation permission or documentation only

---

## Codex Usage Instructions

When using this parent doc with Codex:

1. Open the source override.
2. Open this parent index.
3. Open the rebuild operating model.
4. Open the primitive architecture.
5. Open the product language system.
6. Open the target primitive/surface docs.
7. Keep implementation scoped.
8. Add tests/previews with every build batch.
9. Run copy guard where visible language changes.
10. Do not claim release readiness without evidence.

---

## Current Implementation Priority

1. Complete exact implementation gap audit.
2. Build Reality Rail / Day Rail foundation.
3. Build Step Detail, Step Session, Action Closure, and Receipt Peek.
4. Build Capture and Placement Resolver.
5. Build Plan Life Suite foundation.
6. Build Goals / Goal Detail / You / Trust foundations.
7. Build Ambitions Operating Shell / Meridian behind fallback-safe rollout.
8. Build accessibility, screenshot, and release evidence layers.

---

## Quality Bar

An Ambitions 3.0 rebuild item is not complete until it is:

- product-coherent
- primitive-scoped
- visually premium
- SwiftUI-buildable where implementation-scoped
- accessibility-aware
- trust-aware
- privacy-aware
- language-compliant
- testable
- previewed where user-visible
- connected to the Golden Launch Loop
- honest about planned versus shipped state
