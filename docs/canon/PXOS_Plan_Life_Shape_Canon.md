# Plan Life Shape Canon

Status: PXOS future canon; not current app implementation truth
Date: 2026-05-02

## Purpose

Plan is the time, capacity, and Life Shape surface. It should feel like the shape of the user's life and a believable planning system, not a calendar clone, dense planner, task dump, or scheduling spreadsheet.

Plan owns Day / Week / Month scope chip, contextual default view, active-day Day view, planning/review Week view, Month/Life Shape for long-range planning, scheduled items, free time, protected time, work, school, vacation/away, commute/buffers, pressure, capacity, evidence labels, planning setup prompts, schedule/availability links, planning defaults links, Life Shape month view, pressure weeks, milestones, protected blocks, reflow suggestions, commitment load, recovery space, availability confidence, and missing schedule state.

Vacation/away is not free time unless explicitly marked available. Month is not a generic grid; it emphasizes life areas, pressure weeks, protected time, milestones, capacity, recovery space, and commitments.

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
