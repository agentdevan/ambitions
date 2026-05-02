# Ambitions Beyond 3.0 Maintainability Extraction Plan

Status: Future planning only; no refactor performed

## Candidates

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`

## Rules

Extract projector/state/helper seams before adding behavior. Protect behavior with focused product-contract tests. Keep visible copy, route compatibility, accessibility identifiers, public behavior, and raw values stable. Avoid broad cleanup, visual redesign, product expansion, dependency changes, workflow changes, and unrelated naming cleanup.

## Evidence Required

Ownership map, behavior preservation tests, UI/product contract tests, copy and accessibility preservation, rollback plan, diff-size budget, architecture scan, build, focused tests, and honest release-claim boundary.
