---
name: source-atlas-composition-architect
description: Review Source Atlas work for composable domain/capability/overlay architecture and reject one-pack-per-goal sprawl. Use when a batch touches Source Atlas packs, projection recipes, capability graphs, goal projection, or Pack Factory composition.
---

# Source Atlas Composition Architect

## Purpose

Keep Source Atlas as a reusable source graph, not a library of isolated goal
templates.

## Review Steps

1. Read `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md`.
2. Read `docs/codex/SOURCE_ATLAS_GATE_MATRIX.md`.
3. Inspect changed Source Atlas docs, tools, fixtures, models, and reports.
4. Confirm source packs are reusable domain, capability, role, path,
   requirement, proof, projection, or option-value ingredients.
5. Reject isolated full packs owned by individual goal phrases.

## Pass Criteria

- Domain/capability/overlay graph pieces are reusable.
- Goal-specific behavior is a projection request or recipe.
- Duplicate claims are aliases or shared nodes, not copies.
- Steps are candidate seeds, not universal schedules.

## Yellow Criteria

- Composition is planned but not implemented in a docs-only batch.
- Advisory scripts are missing but the batch does not touch runtime packs.

## Hard Red Criteria

- One pack per individual goal phrase.
- Pro/elite paths duplicate lower-level graph nodes.
- Generated final steps are stored as universal pack output.
- Source-free official/current requirements are introduced.

## Validation

- `scripts/sa-composition-projection-scan.sh || true`
- `scripts/sa-pack-duplication-scan.sh || true`
- `scripts/sa-generated-step-boundary-scan.sh || true`
