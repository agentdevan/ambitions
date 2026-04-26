# Ambitions 2.0 RC Maturity Plan

Adoption date: 2026-04-26

## Purpose

This canon file keeps Ambitions 2.0 from stopping at v1 foundations.

Ambitions 2.0 remains:

> A personal operating system for protecting meaningful progress under real-life conditions.

By the Ambitions 2.0 release candidate, every major roadmap invention must be mature enough for release-candidate use: coherent, tested, performant, accessible, correctable, trustworthy, useful across its required surfaces, clear in degraded states, and bounded by safe automation rules where relevant.

Mature does not mean unlimited or perfect. It means no hidden v1 caveats, no fake claims, no unverified external-surface promises, and no intelligence that makes the user's next decision harder.

## RC Boundary

Ambitions 2.0 RC is local-first and Apple-first:

- no required backend
- no required cloud AI
- no required external provider integration
- no HealthKit unless later canon explicitly changes scope
- no household/shared collaboration unless later canon explicitly changes scope
- export/import remains a trust fallback
- Apple-first sync and conflict policy must be truthful before RC
- manual-first workflows are valid for finance, people, resources, proof, calendar-denied planning, path packs, personal capacity, commitments, life friction, and external references

Trust is more important than automation.

## Maturity Gate Model

Every future batch must state which maturity gate it advances for each major invention it touches.

### Gate 1 - Foundation

- contracts, models, local services, source-of-truth boundaries, tests
- additive, migration-safe persistence when needed
- no broad UI claims

### Gate 2 - First Useful Surface

- at least one user-facing surface consumes the invention
- the user can see the value
- copy stays plain and calm

### Gate 3 - Cross-Surface Integration

- the invention works across the surfaces that need it
- no duplicated logic
- routing, receipts, corrections, memory, review handoffs, and trust states are coherent

### Gate 4 - Trust / Correction / Degraded State

- the user can understand, correct, undo where safe, or recover from failure
- safe degraded behavior exists for denied permissions, stale state, unavailable platform features, missing proof, weak confidence, and unsupported commands

### Gate 5 - Performance / Accessibility

- fast enough for real use
- rich UI does not degrade scrolling, launch, widgets, Live Activities, or navigation
- VoiceOver, Dynamic Type, Reduce Motion, contrast, and tap targets are verified

### Gate 6 - RC Verification

- representative scenarios are tested
- release-candidate ready
- no fake claims
- no hidden v1 caveats

## Required Future Batch Template

New or reworked future batches must include:

- Purpose
- User-facing promise
- Maturity gate advanced
- Smallest useful v1 or mature target
- Source(s) of truth consumed
- Receipt/explanation produced
- Correction path
- Undo/safety boundary where relevant
- Failure/degraded state
- Performance budget
- Accessibility requirement
- No-fake-precision boundary
- Indispensability scenario improved
- Likely files/areas affected
- Dependencies
- Out-of-scope items
- Validation requirements
- Concrete acceptance criteria
- Ready-to-paste Codex prompt

If a batch cannot be explained as one user-facing promise plus one implementation theme, split it.

## Batch Size Ceiling

- If a future batch contains more than three major product systems, split it.
- If a batch touches more than two primary surfaces plus shared infrastructure, split it.
- If a batch requires both new data model work and broad UI transformation, split it unless the UI is minimal.
- If a batch cannot produce inspectable, testable, or scenario-reviewable acceptance criteria, split or defer it.

## Product Milestones

### Milestone A - Ambitions 2.0 Alpha

Goal: prove the daily operating loop.

Includes Today Daily Operating Contract, Global Chrome, Activation Contract, Life Graph foundation, Proof / Resource foundation, Commitment / Waiting foundation, Action Closure v1, Safe Automation Boundary v1, Goals / Goal Detail proof loop v1, Plan Believability and Reality Reflow v1, Daily Loop Alpha QA, and performance baseline.

Target batch range: 73-89.

### Milestone B - Ambitions 2.0 Beta

Goal: prove cross-surface continuity and trust.

Includes You Trust Center, Personal Operating Constitution, Reviews and Life OS Receipt, export/import proof, Apple-first sync/conflict policy, App Intent receipts, widgets and Live Activity ambient continuity, external surface platform verification, representative scenario validation, and first dedicated external-surface performance pass.

Target batch range: 90-94.

### Milestone C - Ambitions 2.0 RC1

Goal: mature the strategic system.

Includes Path Intelligence foundation, Domain Path Packs, Path Fork Simulator, Path Builder v1, learning and correction loop, Memory Confidence, Narrative Memory Map, mature Reality Reflow, mature Goal Portfolio / Ambition Portfolio Manager, strategy/learning integration QA, and performance pass.

Target batch range: 95-100.

### Milestone D - Ambitions 2.0 RC2

Goal: mature all inventions and harden for release.

Includes mature Life Graph, Action Closure, Proof / Progress, Plan / Reality / Recovery, Trust / Sync / Export, Reviews / Memory, Path / Future Self, Onboarding / Re-entry, Accessibility Nutrition Facts after verification, performance/reliability hardening, Indispensability QA, RC audit, and release-candidate lock.

Target batch range: 101-120.

## Future Batch Stretch

Completed Batches 61-72 remain complete and unchanged for planning history.
Batch 73 remains queued until implemented and validated.
No batch after 72 is marked complete by this maturity plan.

| Batch | Name | Primary maturity gate |
| --- | --- | --- |
| 73 | Today 2.0 / Daily Operating Contract v1 | Gate 2 |
| 74 | Global Shell Chrome and Visual Alignment | Gate 2 |
| 75 | Activation Contract and First-Run Promise Spec | Gate 1 |
| 76 | Daily Loop Alpha QA and Performance Baseline | Gate 5 |
| 77 | Life Graph v1 Minimal Object Relationships | Gate 1 |
| 78 | Proof and Resource Graph v1 | Gate 1 |
| 79 | Commitment, Waiting Room, and Promise Ledger v1 | Gate 1 |
| 80 | Action Closure and Receipt System v1 | Gate 1 |
| 81 | Safe Automation Boundary and Undo Rules | Gate 1 |
| 82 | Foundation Performance and Persistence Budget Pass | Gate 5 |
| 83 | Goals 2.0 / Portfolio, Health, and Proof v1 | Gate 2 |
| 84 | Goal Detail 2.0 / Mission Control, Assumptions, Proof Rail | Gate 2 |
| 85 | Plan 2.0 / Believability Kernel and Plan Treaty | Gate 2 |
| 86 | Reality Reflow v1 and Recovery Gradient | Gate 2 |
| 87 | You 2.0 / Trust Center, Constitution, Memory Controls | Gate 2 |
| 88 | Reviews v1 / Recovery Review and Life OS Receipt | Gate 2 |
| 89 | Core Surface Integration QA and Performance Pass | Gates 3 and 5 |
| 90 | Export / Import Proof and Disaster Drill | Gate 4 |
| 91 | Apple-First Sync and Conflict Policy | Gate 4 |
| 92 | App Intents and Shared Container Receipts | Gate 3 |
| 93 | Widgets and Live Activity Ambient Continuity | Gate 3 |
| 94 | External Surface Platform Verification and Performance Pass | Gates 5 and 6 |
| 95 | Path Intelligence Foundation / Life Path Simulation | Gate 1 |
| 96 | Domain Path Packs and Path Fork Simulator | Gate 1 |
| 97 | Path Builder UI / Long-Range Roadmap v1 | Gate 2 |
| 98 | Learning and Anticipation v1 | Gate 1 |
| 99 | Memory Confidence, Correction Cards, and Narrative Memory Map | Gates 2 and 4 |
| 100 | Strategy / Learning Integration QA and Performance Pass | Gates 3 and 5 |
| 101 | Life Graph Mature Relationship Audit | Gate 6 |
| 102 | Action Closure Mature Receipt / Undo / Trust Audit | Gate 6 |
| 103 | Proof-Weighted Progress and Momentum Integrity Maturity | Gate 6 |
| 104 | Commitments, Waiting, Promise Ledger, and Social Load Maturity | Gate 6 |
| 105 | Believability Kernel, Constraint Gravity, and Plan Treaty Maturity | Gate 6 |
| 106 | Reality Reflow, Recovery Gradient, and Save the Day Maturity | Gate 6 |
| 107 | Ambition Portfolio Manager, Goal Weather, and Goal Scope Maturity | Gate 6 |
| 108 | Personal Operating Constitution and Calm Intervention Maturity | Gate 6 |
| 109 | Reviews, Life OS Receipt, and Narrative Memory Maturity | Gate 6 |
| 110 | Path Forks, Future Self Simulation, and Domain Pack Maturity | Gate 6 |
| 111 | Cross-Surface Continuity and Mode Lens Maturity | Gate 6 |
| 112 | Mature Invention Performance Pass | Gate 5 |
| 113 | Onboarding, Empty States, and Returning User Continuity | Gate 4 |
| 114 | Representative Scenario Fixtures and Indispensability QA v1 | Gate 6 |
| 115 | Accessibility Verification and User-Facing Nutrition Facts | Gates 5 and 6 |
| 116 | Visual Polish, Appearance Studio, and Shell Regression | Gate 6 |
| 117 | Offline, Data Safety, Migration, and Reliability Hardening | Gates 4 and 6 |
| 118 | Final Performance, Memory, and Responsiveness Pass | Gate 5 |
| 119 | Ambitions 2.0 RC Audit | Gate 6 |
| 120 | Ambitions 2.0 Release Candidate Lock | Gate 6 |

## Dependency Map

| Dependency | Establishing batches | Consuming batches | RC maturity / proof batches |
| --- | --- | --- | --- |
| Global Chrome | 74 | 83-94, 111, 116 | 111, 116, 119 |
| Life Graph | 77 | 78-80, 83-88, 95-100 | 101, 111, 119 |
| Proof / Resource Graph | 78 | 83-84, 88, 95-100 | 103, 110, 119 |
| Commitments / Waiting | 79 | 83, 85-88, 93, 95-100 | 104, 114, 119 |
| Action Closure | 80 | 83-94, 99, 111 | 102, 117, 119 |
| Safe Automation Boundary | 81 | 85-94, 98-100, 102, 108 | 117, 119 |
| Trust Ledger | 80-81, 87 | 90-94, 99, 102, 108 | 117, 119 |
| Sync / Export | 90-91 | 92-94, 113, 117 | 117, 119 |
| Path Intelligence | 95-97 | 98-100, 110, 114 | 110, 119 |
| Performance passes | 76, 82, 89, 94, 100, 112, 118 | all future feature batches | 112, 118, 119 |
| Accessibility verification | 64 foundation, 115 verification | all UI/external batches | 115, 119 |

This order is safe because broad surfaces consume shared objects only after foundations exist, external surfaces consume snapshots and receipts only after trust boundaries exist, and mature audits occur after cross-surface use has exposed real integration risk.

## No Duplicate Engine Rule

Future implementation must clarify source of truth rather than create parallel systems:

- Believability Kernel owns believable / not-believable state.
- Constraint Gravity owns dominant constraint detection.
- Reality Reflow owns mutation suggestions.
- Action Closure owns receipts and undo/correction presentation.
- Trust Ledger owns user-facing trust-impacting history.
- Event Ledger remains raw event history.
- Proof Rail Engine owns proof organization and presentation.
- Memory Confidence Engine owns confidence state of learned memories.
- Safe Automation Boundary owns what Ambitions may suggest, prepare, confirm, execute, or never automate.
- Ambition Portfolio Manager owns portfolio-level goal pressure.
- Goal Scope Governor owns scope expansion, shrink, park, and protect logic.

## Naming Rule

Engine names may appear in canon, architecture, and implementation docs.
User-facing UI copy should stay human and calm.

Avoid exposing technical names such as Believability Kernel, Constraint Gravity Engine, Memory Confidence Engine, Safe Automation Boundary, or Decision Debt Engine unless a later design decision explicitly approves it.

Preferred user-facing phrasing:

- "This week is tight."
- "This is waiting on Alex."
- "This changed because your afternoon filled up."
- "This is not for today."
- "You can undo this."
- "This suggestion breaks one of your rules."

## Intelligence Levels

Future features should label their intelligence level when useful:

- Level 0: deterministic rules
- Level 1: local pattern summaries
- Level 2: user-confirmed learning
- Level 3: optional AI-assisted drafting/explanation
- Level 4: external knowledge/provider-backed suggestions
- Level 5: automation with explicit confirmation only

No black-box claims are allowed.
User-confirmed learning is preferred.
External/cloud intelligence is not required for Ambitions 2.0 RC.

## No-Fake-Precision Rule

Use qualitative states unless there is strong evidence.

This applies to Believability Kernel, Goal Weather, Momentum Integrity, Path Simulation, Future Self Simulator, Proof-Weighted Progress, Daily Contract state, Ambient Status Orb, goal health, Plan believability, progress, path readiness, and memory confidence.

Prefer states such as clear, steady, tight, fragile, blocked, waiting, protected, recovered, not for today, needs proof, or needs review over precise numeric claims that the system cannot defend.

## Performance Strategy

Performance is a recurring requirement and a dedicated roadmap concern.

Every feature batch must include a performance budget. Dedicated performance/hardening passes occur after:

- daily loop / chrome wave: Batch 76
- foundation wave: Batch 82
- core surface wave: Batch 89
- external surface wave: Batch 94
- strategy / learning wave: Batch 100
- mature invention wave: Batch 112
- final RC hardening: Batch 118

Roadmap-level guidance, not measured claims:

- top-level screen first meaningful content should remain fast on supported devices
- scrolling should remain smooth on content-heavy screens
- widgets and Live Activities should use precomputed lightweight snapshots
- rich panel effects should degrade gracefully under Reduce Motion or lower performance conditions
- large Life Graph, Event Ledger, Proof, and Trust Ledger queries should avoid full graph recomputation on every render
- background refresh and external snapshots should be bounded and privacy-safe
- no expensive animations on every scroll
- no excessive blur stacking
- no repeated duplicate calculations when shared projections exist
- shared engines should be deterministic and cacheable where appropriate
- external surfaces should consume snapshots, not heavy live computation

Do not claim measured performance until an implementation batch validates it.

## Reliability Requirements

Future batches must avoid crashes, broken navigation, lost data, stale recommendations without indication, confusing empty states, fake sync claims, calendar permission surprises, inaccessible custom controls, unreviewed generated assumptions, and unsafe destructive operations.

Future batches must provide safe degraded states, clear correction paths, deterministic local behavior where expected, manual fallback when permissions are denied, migration-safe and backward-compatible persistence changes, portable export/import effects when data changes, and sync/conflict effects when relevant.

## Visual Scope Rule

Maturing inventions must not violate top-level calmness.

Advanced density belongs in drill-downs, sheets, reviews, object detail screens, Path Builder, Trust Center, Goal Detail, and Plan detail.

Top-level screens remain one hero, one or two support panels above the fold, clear hierarchy, few visible buttons, short copy, and no dashboard clutter.

## Mode Lens Maturity Rule

Mode Lens changes emphasis, priority, and presentation.

It does not change object ownership, create hidden tabs, hide required actions, create separate state, duplicate navigation, or change the source of truth.

Suggested modes: Focus, Triage, Plan, Recover, Review.

v1 may start with Focus, Triage, and Recover. By RC, Mode Lens must be coherent across Today, Capture, Plan, Reviews, and You without becoming hidden navigation.

## Review Hierarchy

Reviews must not become an analytics room.

- Recovery Review: immediate, 30-90 seconds, no shame.
- Daily Receipt: passive, generated after meaningful action or day.
- Weekly Life OS Receipt: main recurring review.
- Goal Review: object-specific.
- Memory Review: trust/correction surface under You.
- Correction Review: wrong assumption, never-suggest, and memory correction audit.

By RC, Reviews consume receipts, proof, and memory confidence; produce narrative memory; support correction; feed future recommendations; and remain calm and non-punitive.

## Safe Undo Categories

Likely safe to undo:

- capture route change
- archive / unarchive
- attach / detach from goal
- mark waiting
- local plan movement
- local priority change
- local recommendation correction
- local review / correction note edits

Potentially unsafe or confirmation-required:

- calendar writes
- exports
- sync conflict resolutions
- deletion
- external App Intent actions
- memory forgetting
- broad plan reflows
- external surface commands
- destructive trust actions

Safe undo boundaries belong to Action Closure and Safe Automation Boundary. External or irreversible effects must never be hidden behind casual undo copy.

## External Surface Proof Gates

App Intents, widgets, Live Activities, and shared containers are not production-ready until verified against these gates:

- renders correctly on target platform
- handles stale state
- handles denied permission
- deep-links correctly
- command result receipt appears
- does not duplicate app logic
- does not leak private data
- works after app restart
- clear failed-safe state
- snapshot payloads remain lightweight
- platform limitations are documented

External surfaces consume snapshots and shared commands; they do not run heavy live graph calculations or create parallel command logic.

## Appearance Studio Guardrails

Appearance Studio may control accent color, light / dark / system appearance, contrast preference, motion preference, panel density if supported later, active tab treatment through tokens, and header / chrome treatment through tokens.

Appearance Studio must not break accessibility, contrast minimums, tab IA, semantic state clarity, product identity, reduced motion, core shell readability, or trust / safety states.

## Representative Scenario Fixtures

These are canon validation scenarios for future acceptance criteria. They are docs fixtures now, not code fixtures until an implementation batch creates them.

- move apartments in 45 days
- transition into Product in 12 months
- finish an EP in 90 days
- plan around a new baby
- pay off debt while preserving rent
- study for certification while working full-time
- recover after missing a week
- handle five competing active goals
- calendar denied but planning still useful
- new phone / export restore
- wrong recommendation corrected
- waiting on another person
- urgent deadline after missed plan
- low-energy day with too many tasks

Every mature invention should be validated against at least one representative scenario before RC.

## Major Invention RC Coverage

The following inventions must reach Gate 6 before the release-candidate lock or be explicitly escalated to Devan for a deferral decision:

- Global Chrome
- Mode Lens
- Continuity Ribbon
- Action Closure Tray
- Ambient Status Orb
- Life Graph Breadcrumb
- Mission Control Lanes
- Proof Rail
- Trust Badge / Trust Status
- Daily Operating Contract
- One Move Doctrine
- Save the Day Mode
- Anti-Plan / Not Today
- Attention Shield
- Life Graph
- Resource Graph
- Proof of Progress
- Proof-Weighted Progress
- Momentum Integrity Engine
- Commitments and Waiting Room
- Promise Ledger
- Social Load Meter as a lightweight qualitative signal under Commitments / Waiting / Promise Ledger only; manual-first, local-first, private, non-punitive, not a standalone dashboard, not social scoring, not a high-weight engine, not top-level, and not inferred emotional/social judgment
- Action Closure Layer
- Undo where safely supported
- Safe Automation Boundary
- Trust Ledger
- Believability Kernel
- Constraint Gravity Engine
- Decision Debt Engine
- Opportunity Window Engine
- Plan Treaty
- Reality Reflow Engine
- Recovery Gradient
- Personal Capacity Envelope
- Ambition Portfolio Manager
- Goal Scope Governor
- Goal Weather
- Assumption Watchtower
- Personal Operating Constitution
- Constitution Violation behavior
- Calm Intervention Engine
- Reviews hierarchy
- Review Constellation
- Life OS Receipt
- Narrative Memory Map
- Re-entry Engine
- Clarity Debt Engine
- Memory Confidence Engine
- Correction Cards
- Path Intelligence / Life Path Simulation
- Path Fork Simulator
- Domain Path Packs
- Future Self Simulator
- External Continuity Contract
- App Intent receipts
- Widget / Live Activity ambient continuity
- Export/import proof
- Apple-first sync/conflict policy
- Appearance Studio preservation
- Accessibility Nutrition verification
- performance/reliability hardening

## Core Operating Loop Priority

Not every invention receives equal implementation weight. Preserve all major inventions, but prioritize depth for inventions that directly improve the core operating loop:

1. Daily Operating Contract
2. Life Graph
3. Action Closure
4. Reality Reflow
5. Proof of Progress
6. Commitments / Waiting
7. Reviews / Memory
8. Trust / Sync / Export
9. Performance / Accessibility

Secondary inventions may mature as supporting systems when that is more executable.

## Concrete Acceptance Criteria Rule

Avoid vague acceptance criteria such as "improves trust," "enhances recovery," "supports intelligence," or "makes the app better."

Each batch must include acceptance criteria that can be inspected in changed files, tested by unit/persistence/UI/platform checks, manually reviewed in a scenario, compared against a degraded-state expectation, or traced to a receipt, explanation, correction, undo boundary, or trust state.

## Life Graph Maturity Path

Life Graph must not stop at v1.

Required path:

1. Life Graph v1 minimal object relationships.
2. Surface consumption in Goals, Plan, Today, You, Reviews, and Path.
3. Resource / Proof / Promise relationship expansion.
4. Relationship integrity and correction flows.
5. Graph query and performance pass.
6. RC maturity audit.

Life Graph v1 may start minimal with goal, action, capture, commitment, waiting item, proof/evidence, resource/link/file, decision, correction, and receipt.

By RC it must support Life Graph Breadcrumb, Mission Control Lanes, Proof Rail, Commitments / Waiting, Path Forks, Reviews, Memory, Trust Receipts, Action Closure, and Life OS Receipt.

## Action Closure Maturity Path

Action Closure must not stop at v1.

Required path:

1. Action Closure v1 receipts.
2. Safe undo / confirmation rules.
3. Surface consumption in Today, Goals, Plan, Capture, and You.
4. External action receipts for App Intents, widgets, and Live Activities where applicable.
5. Calendar / export / sync receipt integration.
6. Trust Ledger integration.
7. Mature receipt / undo / trust audit before RC.

## Deferred Scope Escalation Rule

If a future batch finds that a major invention cannot mature by Ambitions 2.0 RC without violating local-first trust, top-level calmness, accessibility, performance, or dependency order, the batch must stop and report:

1. the conflict
2. why it matters
3. safest default assumption
4. what decision Devan needs to make

Do not silently defer major inventions.
