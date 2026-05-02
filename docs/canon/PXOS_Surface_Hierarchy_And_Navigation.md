# Surface Hierarchy And Navigation
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; not current app implementation truth
Date: 2026-05-02

## Purpose

The top-level surfaces remain Today, Goals, Capture, Plan, and You. PXOS deepens these surfaces through sheets, panels, drill-downs, receipts/history, setup flows, trust review, proof detail, and source detail.

Surface ownership:

- Today: what matters now and one calm execution path.
- Goals: strategic direction and Mission Control.
- Capture: fast private intake and placement.
- Plan: time, capacity, pressure, and Life Shape.
- You: Personal System Center, preferences, trust, data, setup, and controls.

PX01 locks these drill-down families as the approved depth model:

- Today: Step Detail, Step Session, recovery, closure, proof peek, source detail.
- Goals: Goal Detail, Mission Control lanes, proof/history, alternate paths.
- Capture: routing review, placement correction, grow-into-goal, source detail.
- Plan: day/week shape, reflow decisions, pressure review, Life Shape detail.
- You: grouped navigation, trust review, memory/data controls, setup defaults.

Future PXOS batches may refine the exact expression, but they must preserve the
owner and keep secondary detail behind deliberate drill-downs.

No new top-level tab, no chat-first surface, no generic dashboard, no separate inbox, no generic analytics tab, no standalone habit mode.

## Top-Level Surface Composition Rule

Top-level tabs are visual orientation surfaces. They are not detail containers,
not proof/history archives, and not vertical piles of generic cards.

Every top-level tab must prioritize:

- visual state
- spatial hierarchy
- shape
- priority
- rhythm
- progress
- pressure
- context
- primary action
- drill-down entry points

Every top-level tab must minimize:

- long text blocks
- repeated same-size cards
- dense lists
- duplicate panels
- exposed diagnostics
- proof/history/detail overload
- dashboard-like card grids
- settings clutter outside You

Future concepts must pass:

- Glance test: a user understands the main state in 3 seconds without reading
  every label.
- One-primary-object test: the dominant visual object or decision is clear.
- Drill-down discipline test: anything not needed for immediate orientation or
  the next action moves behind a tap.

Reject future UI concepts that use vertical stacks of generic cards as the
primary structure.

Details belong in Step Detail, Step Session, Goal Detail, Mission Control
lanes, Plan detail views, Life Shape drill-downs, Capture routing review, You
grouped navigation, receipts/history, proof detail, setup flows, and
trust/review surfaces.

## Required Source Stack

- `README.md`
- `AGENTS.md`
- `docs/canon/Ambitions_3_0_Source_Of_Truth_Override.md`
- `docs/canon/Ambitions_3_0_Front_End_Redesign_Index.md`
- `docs/canon/Ambitions_3_0_Primitive_Architecture.md`
- `docs/canon/Ambitions_Beyond_3_0_Roadmap.md`
- `docs/canon/Ambitions_Beyond_3_0_Continuity_Rules.md`
- `docs/canon/Ambitions_Product_Experience_OS_Index.md`
- `docs/canon/AmbitionsOS_Index.md`
- `docs/codex/PXOS_TRAIN_CONTROL_SYSTEM.md`
- `docs/codex/PXOS_PRODUCT_DECISION_LEDGER.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Gates

- Product Decision Lock Gate: major choices must be locked by source truth or recorded as open/deferred.
- Surface Ownership Gate: every future UI change names Today, Goals, Capture, Plan, You, or a drill-down owner.
- Deep-Not-Wide Gate: deepen existing surfaces before creating new surface area.
- Accessibility / Cognitive Load Gate: future UI must specify Dynamic Type, VoiceOver, Reduce Motion, no color-only meaning, and cognitive-load expectations.
- Release Claim Gate: no release/platform/AI/personalization claim without evidence.
- ME Gate: no large UI expansion in known large-file zones without extraction review.
- CS Gate: no route/raw-value/external-surface/persistence breakage.

## Implementation Boundary

This is future canon and process guidance only. It does not implement app behavior, change production Swift, start PXOS, start AOS/ME/CS/REC02, retire compatibility seams, add dependencies, change workflows, add backend/sync/cloud/model runtime, or create release/platform readiness claims.
