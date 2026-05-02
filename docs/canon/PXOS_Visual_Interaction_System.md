# Visual Interaction System

Status: PXOS future canon; not current app implementation truth
Date: 2026-05-02

## Purpose

Visual identity: dark-mode-first, warm graphite, charcoal, soft black, subtle glass/material surfaces, premium rounded panels, quiet luxury, native iOS restraint, crisp hierarchy, minimal but not empty, deep not wide, visually stunning without decorative noise, restrained celestial/dark-sky signature only where appropriate.

Use compact safe-area-aware contextual headers, premium grouped panels, connected rails, subtle receipts, tappable rows, progressive disclosure, tactile but not gamified interactions, motion as orientation, reduced-motion equivalents, clear spatial hierarchy, calm affordances, restrained accent color, and visually obvious primary action.

Avoid giant redundant headers by default, cluttered dashboards, loud gradients everywhere, cartoon visuals, excessive color, generic cards everywhere, fake AI glow, unnecessary SaaS charts, top-level visual noise, dense control panels, and desktop dashboard patterns.

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
