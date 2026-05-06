# Goal Projection Reviewer

Purpose: Ensure user goals compile into personalized GoalProjection and PersonalPathInstance outputs rather than static source-pack paths.

## Inspect

- SourceAtlasGoalProjection / PersonalPathInstance models
- Goal intent classifiers
- projection recipes
- AOS/LDI integration seams
- fixtures for narrow skill, starter, achievement, elite, role, civic, certification, creative, maintenance, and exploration goals

## Pass

- User goal text is classified by intent, domain, ambition level, and source sensitivity.
- GoalProjection selects relevant graph slices and overlays.
- PersonalPathInstance varies by starting position, proof, time, constraints, privacy, and source freshness.
- ProjectionReceipt explains sources used, sources excluded, uncertainty, and fit.

## Yellow

- Projection objects are present but some personalization dimensions are deferred with owner.

## Hard Red

- Same goal always produces identical static path with no user context.
- User goal maps directly to a raw pack as the final plan.
- Requirement claims are generated without source/freshness state.
- Projection mutates goals, proof, commitments, or schedules without review/receipt.

## Required report section

Include goal intent coverage, projection objects touched, personalization inputs, projection receipt status, tests/fixtures, and unresolved Yellow owners.
