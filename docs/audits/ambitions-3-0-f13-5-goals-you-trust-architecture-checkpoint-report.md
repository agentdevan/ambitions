# Ambitions 3.0 F13.5 Goals / You / Trust Architecture Checkpoint

Date: 2026-05-01

Result: Green

## Trigger

F13 touched files that are already in extraction-required zones:

- `GoalDetailScreen.swift`
- `GoalsFeatureModels.swift`
- `GoalsFeatureService.swift`
- `PreviewGoalsScenarios.swift`

The checkpoint was required before F14 so the train did not silently carry Goals
state-contract or proof/trust ambiguity into You / Trust.

## Boundary Decision

Goals owns:

- Goal Mission Control state and rendering.
- Goal Detail path, lane, status, risk, decision, proof summary, and receipt
  preview contracts.
- Goal-local source labels such as `Based on this goal`.
- Goal-local path ownership labels such as `You own the path`.
- Display of proof attached to a goal when the current data source provides it.

You / Trust owns:

- `What Ambitions Knows`.
- Memory/source/freshness visibility.
- Personalization consent state.
- Memory correction, deletion, and review controls.
- Trust-wide receipt visibility outside a single goal.
- Sensitive-memory approval boundaries.

Evidence / Proof owns:

- Receipt/proof hierarchy and proof semantics.
- Proof is not a score and is not gamification.
- Proof may support Goal display, but Goal Mission Control does not create
  hidden memory or broad trust history.

## F13 Review

F13 added explicit source, proof-boundary, and path-ownership labels to the Goal
Detail mission-control state. It did not change persistence, memory, consent,
recommendation eligibility, or You/Trust behavior.

## F14 Readiness

F14 may proceed if it stays inside You/Profile trust-memory surfaces and uses
the existing Profile/You seam. F14 must not move Goal Mission Control ownership
into You, must not create hidden memory, must not add analytics/backend/sync
assumptions, and must keep memory source/freshness/control visible.

## Validation

- Build: F13 build already PASS on iPhone 17.
- Focused tests: F13 `GoalDetailStrategicPresentationTests` PASS,
  16 tests, 0 failures.
- Architecture scan: advisory only; checkpoint documents the touched-file
  warning and does not add code.
- Privacy/trust: boundary clarified; no new behavior added.

## Gate

F13.5 gate result: Green.

F14 may proceed.
