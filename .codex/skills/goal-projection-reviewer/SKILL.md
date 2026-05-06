---
name: goal-projection-reviewer
description: Review Source Atlas goal projection work for GoalProjection, ProjectionProfile, ProjectionRecipe, PersonalPathInstance, StepCandidateSeed, and projection receipts.
---

# Goal Projection Reviewer

## Purpose

Ensure user goals produce personalized projections instead of static paths.

## Review Steps

1. Read `docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md`.
2. Inspect projection objects, fixtures, tests, and report claims.
3. Confirm outputs can vary by starting position, proof, time, constraints,
   privacy, source freshness, and user context.

## Pass Criteria

- GoalProjection and ProjectionProfile are explicit.
- PersonalPathInstance is user-context-shaped.
- Projection receipts explain sources used, sources excluded, uncertainty, and
  fit.
- Source-needed fallback exists when current/official source proof is missing.

## Yellow Criteria

- Docs-only projection contract without runtime.
- Fixture family still owned by SAP04/SA10C.

## Hard Red Criteria

- Same static path for every user with the same goal.
- Requirement or eligibility certainty without source proof.
- Hidden path mutation without review and receipt.

## Validation

- `scripts/sa-projection-fixture-coverage-scan.sh || true`
- `scripts/sa-composition-projection-scan.sh || true`
