# Ambitions 2.0 Roadmap

## Program 1 - Truth, Shell, And Visual Foundation

- Goal: Verify repo truth, lock the Today / Goals / Capture / Plan / You shell, and establish the rich panel design system.
- Why it comes here: Surface transformation cannot start from stale capability assumptions or a disputed IA.
- Systems affected: Accessibility Nutrition Layer, Visual System, Capability Matrix, shell routing.
- User-facing outcome: The app has a clear 2.0 structure and visual language.
- Technical foundation created: capability evidence, IA decisions, panel primitives, accessibility checklist.
- Risks: false status claims, shell churn, visual components outrunning data.
- Dependencies: Batch 60 planning completion and Batch 61 verification.
- Not included yet: feature behavior changes beyond active batch scope, widgets, sync, calendar implementation beyond verified planning.

## Program 2 - Shared Intelligence Foundations

- Goal: Build Memory / Event Ledger, Recommendation Explanation Model, Canonical Now State, and Command Pipeline foundations.
- Why it comes here: Surfaces, widgets, intents, and reviews need one source of truth.
- Systems affected: Memory / Event Ledger, Explanation, Now State, Command Pipeline.
- User-facing outcome: Recommendations and actions become consistent and explainable.
- Technical foundation created: local events, reusable explanation, stable current-state projection, safe command path.
- Risks: duplicate histories, command paths outside the pipeline, explanation copy not backed by evidence.
- Dependencies: Program 1 truth and design foundations.
- Not included yet: external surfaces, sync merge, full path UI.

## Program 3 - Core Execution Systems

- Goal: Rebuild Capture, Reality Model/calendar read-write, goal health, and Execution Resilience.
- Why it comes here: Daily execution must rest on real capacity, permission-safe calendar context, and shared recovery.
- Systems affected: Reality Model, Execution Resilience, Command Pipeline, Event Ledger.
- User-facing outcome: Capture routes cleanly, Plan can become calendar-aware, Today can recover when life changes.
- Technical foundation created: local-first calendar-derived insights, recovery actions, believability model.
- Risks: permission overreach, calendar write ambiguity, habit logic duplication.
- Dependencies: Program 2 command and memory foundations.
- Not included yet: widgets, Live Activities, Apple-first sync, full long-range path UI.

## Program 4 - Primary Surface Transformation

- Goal: Transform Today into a Daily Operating Contract, align global chrome, then transform Goals, Plan, You, contextual insights, reviews, and absorbed habits using shared loop systems.
- Why it comes here: Core systems must exist before surfaces present them.
- Systems affected: Now State, Reality Model, Explanation, Reviews, Visual System, Global Chrome, Action Closure, Life Graph, Proof Rail, Trust Ledger.
- User-facing outcome: The primary app feels like one coherent personal operating system rather than separate tabs.
- Technical foundation created: surface consumers of shared systems instead of duplicated logic; permanent shell/header/tab visual alignment; Action Closure and Life Graph foundations for later surfaces.
- Risks: top-level density creep, rebuilding Insights as a tab, treating Habits as standalone, turning global chrome into feature content, or building surface-specific receipt/proof/navigation systems.
- Dependencies: Programs 1-3.
- Not included yet: widgets/Live Activities before Now State and Command Pipeline are stable, non-phone hardware.

Primary-surface sequencing is loop-first:

- Batch 73 makes Today the Daily Operating Contract.
- Batch 74 aligns global shell/chrome before the remaining major surface redesigns consume it.
- Batch 75 establishes Life Graph v1 and object relationships before Goals, Plan, You, Reviews, and Path Intelligence depend on them.
- Batch 76 establishes Action Closure and receipts before later surfaces, sync/export, App Intents, widgets, and Live Activities need trusted results.
- Batches 77-80 transform Goals, Plan, You, and Reviews around proof, recovery, correction, trust, memory, and continuity.

## Program 5 - Apple Platform Completion

- Goal: Ship Apple-first sync/export-import trust, App Intents, shared container readiness, Widgets, and Live Activity v1 as continuity surfaces with receipts and stale-state truth.
- Why it comes here: External surfaces need stable Now State, Command Pipeline, data boundaries, and trust language.
- Systems affected: Sync/Export Trust Layer, Command Pipeline, Now State, Event Ledger, Action Closure, Trust Ledger, External Continuity Contract.
- User-facing outcome: Ambitions works cleanly across Apple-native entry points with trustworthy fallback.
- Technical foundation created: shared external payloads, sync/export policy, simple external surface consumers.
- Risks: sync before model verification, external command duplication, overbuilding widgets, stale external state without visible trust status, or external actions without receipts.
- Dependencies: stable Now State, Command Pipeline, verified data model.
- Not included yet: non-phone hardware prototype, HealthKit, household/shared life.

## Program 6 - Full Path Intelligence

- Goal: Build Life Path Simulation for broad coherent path families.
- Why it comes here: The app needs stable execution and explanation foundations before long-range UI expands.
- Systems affected: Path Intelligence, Reality Model, Explanation, Goals, Plan.
- User-facing outcome: Users can see believable long-range paths, forks, prerequisites, proof requirements, risks, fallback paths, and daily next actions.
- Technical foundation created: path families, path forks, Domain Path Pack contracts, Future Self Simulator, pause/limited-time simulations, builder, long-range path UI, learning/anticipation v1.
- Risks: template sprawl, unsupported domains, ungrounded advice, fake certainty, or full path UI before Life Graph/proof/action-closure foundations exist.
- Dependencies: Memory, Explanation, Reality Model, surface transformation.
- Not included yet: HealthKit, food/calorie sync, household/shared life.

## Program 7 - Learning, Onboarding, And Release Hardening

- Goal: Complete learning, onboarding, empty states, returning-user continuity, verified accessibility nutrition, indispensability QA, and release hardening.
- Why it comes here: Claims and polish must follow real system behavior.
- Systems affected: Accessibility Nutrition, Reviews, Memory, onboarding, Global Chrome, Appearance Studio, release docs.
- User-facing outcome: The product feels trustworthy from first launch through release candidate.
- Technical foundation created: verification records, accessibility summary, scenario scripts, global chrome QA, rich-panel visual consistency QA, Appearance Studio regression QA, release readiness.
- Risks: unverified accessibility claims, stale screenshots/docs, performance regressions, shell inconsistency, rich-panel drift, or beautiful surfaces that do not feel indispensable.
- Dependencies: Programs 1-6.
- Not included yet: deferred 2.0 scope.
