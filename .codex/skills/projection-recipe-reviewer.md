# Projection Recipe Reviewer

Purpose: Ensure projection recipes compose Source Atlas graph pieces into goal-specific projections without duplicating packs or producing static plans.

## Inspect

- ProjectionRecipe models and examples
- GoalProjection fixtures
- required_packs / optional_packs fields
- must_include / must_not_claim rules
- context questions
- source/freshness filters
- AOS/LDI integration seams

## Pass

- Projection recipes identify required and optional pack pieces.
- Recipes include source limits, missing-context questions, must-not-claim restrictions, and fallback/source-needed behavior.
- Recipes produce GoalProjection/PersonalPathInstance inputs, not final scheduled plans.

## Yellow

- Recipes exist for core examples only; long-tail recipes rely on domain meta-packs with owner.

## Hard Red

- Recipes duplicate full source packs.
- Recipes omit source-needed fallback for official/current claims.
- Recipes generate final schedules without AOS/LDI/Plan context.

## Required report section

Include recipes touched, fallback status, must-not-claim coverage, context questions, and AOS/LDI handoff status.
