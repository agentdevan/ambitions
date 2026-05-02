# Visual Interaction System
<!-- markdownlint-disable MD013 -->

Status: PXOS future canon; PX10 complete; not current app implementation truth
Date: 2026-05-02

## Purpose

PXOS visual interaction makes Ambitions feel calm, premium, native, spatial,
and deeply organized without becoming decorative, generic, or dashboard-like.

Visual identity: dark-mode-first, warm graphite, charcoal, soft black, subtle
glass/material surfaces, premium rounded panels, quiet luxury, native iOS
restraint, crisp hierarchy, minimal but not empty, deep not wide, visually
stunning without decorative noise, restrained celestial/dark-sky signature only
where appropriate.

Use compact safe-area-aware contextual headers, premium grouped panels,
connected rails, subtle receipts, tappable rows, progressive disclosure,
tactile but not gamified interactions, motion as orientation, reduced-motion
equivalents, clear spatial hierarchy, calm affordances, restrained accent
color, and visually obvious primary action.

Avoid giant redundant headers by default, cluttered dashboards, loud gradients
everywhere, cartoon visuals, excessive color, generic cards everywhere, fake AI
glow, unnecessary SaaS charts, top-level visual noise, dense control panels,
and desktop dashboard patterns.

## Composition Bar

The repeated "stacked cards all the way down" pattern is not a PXOS visual
system. Cards may be used for object summaries, receipts, rows, and drill-down
entries, but a top-level surface must not become a same-size vertical card
stack.

Top-level visual structure should be composed from hierarchy and shape:

- a dominant primary object or decision
- connected rails, lanes, timelines, or maps where they clarify state
- compact contextual headers
- grouped controls only where the surface needs them
- progressive disclosure for proof, diagnostics, history, and secondary detail

Use cards sparingly and with varied purpose. Reject top-level concepts where
the screen is understandable only by reading a long sequence of equal-weight
panels.

## Top-Level Orientation Patterns

Each main destination needs a primary visual object:

- Today: Reality Rail / Ambitions Day Rail with one clear lead state, Now/Next/Later rhythm, and a visible `Start here` decision.
- Goals: Ambition Portfolio / Mission Control map showing vitality, direction, path progress, and drill-down lanes without KPI dashboard posture.
- Capture: private intake composer with placement state, consequence preview, and restrained dark-sky signature only where it supports focus.
- Plan: Life Shape map with capacity, pressure, protected/free time, and reflow entry points without becoming a calendar clone.
- You: Personal System Center with grouped control/navigation structure, trust posture, setup state, and privacy/data controls without settings clutter.

## Rhythm, Materials, And Shape

- hierarchy first: one dominant object, secondary lanes, then detail routes;
- materials support focus, not novelty;
- rounded panels remain premium and purposeful, not a carpet of identical cards;
- spacing should create calm scanning paths and preserve Dynamic Type;
- accent color should signal action/state sparingly and never be the only cue;
- receipts and proof should feel subtle, local, and inspectable.

## Motion, Haptics, And Reduce Motion

Motion clarifies state transitions:

- rail movement shows today-state progression;
- map or lane transitions show drill-down context;
- proof/receipt pulses confirm meaningful local changes;
- recovery/reflow transitions show what changed and what stayed stable.

Every meaningful motion needs a Reduce Motion equivalent: instant state change,
static emphasis, text/status update, or non-motion highlight. Haptics should
reinforce user-initiated confirmation only and must not become gamified reward.

## Per-Surface Composition Criteria

- Today passes when the main day state is legible in three seconds without
  reading every row.
- Goals passes when the user sees direction, pressure, and next drill-down
  without a generic chart wall.
- Capture passes when input, placement state, and consequence are obvious
  without inbox/task-list drift.
- Plan passes when capacity and pressure are visible without calendar-clone
  dominance.
- You passes when control, trust, setup, and data ownership are visible without
  hiding everything in generic settings.

## Visual Proof Boundary

PX10 does not provide screenshot, preview, simulator, device, or app behavior
proof. Future implementation batches must produce visual evidence appropriate
to their scope before claiming visual acceptance.

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
