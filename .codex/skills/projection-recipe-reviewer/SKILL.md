---
name: projection-recipe-reviewer
description: Review Source Atlas ProjectionRecipe, source overlay, proof map, alternative path, and generated-step boundary behavior.
---

# Projection Recipe Reviewer

## Purpose

Make projection recipes explain how reusable graph pieces become user-specific
path instances without storing universal schedules.

## Review Steps

1. Inspect ProjectionRecipe, StepCandidateSeed, RequirementOverlay, ProofMap,
   and receipt changes.
2. Confirm source/freshness/risk states are carried through recipes.
3. Confirm final scheduled steps remain owned by AOS/LDI/Plan.

## Pass Criteria

- Recipes compose reusable graph pieces.
- Recipes produce candidate seeds, not final schedules.
- Receipts explain source and uncertainty boundaries.

## Yellow Criteria

- Recipe contract exists but no runtime compiler is implemented.

## Hard Red Criteria

- Packs hardcode final schedules for all users.
- Recipes omit source/freshness state for source-sensitive claims.

## Validation

- `scripts/sa-generated-step-boundary-scan.sh || true`
- `scripts/sa-composition-projection-scan.sh || true`
