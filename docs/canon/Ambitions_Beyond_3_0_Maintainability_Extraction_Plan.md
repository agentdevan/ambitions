# Ambitions Beyond 3.0 Maintainability Extraction Plan

Status: Future planning plus ME01 audit baseline; no refactor performed

## Candidates

- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayFeatureService.swift`
- `Native/Ambitions/Features/Today/TodayPanels.swift`
- `Native/Ambitions/Features/Plan/PlanFeatureService.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`

## ME01 Baseline

ME01 completed the audit-only ownership map on 2026-05-02. It did not edit Swift
or perform extraction.

| Owner file | ME owner batch | ME01 line count | Baseline gate |
| --- | --- | ---: | --- |
| `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` | ME02 | 5,024 | `EXTRACTION_REQUIRED` |
| `Native/Ambitions/Features/Today/TodayFeatureService.swift` | ME03 | 2,718 | `EXTRACTION_REQUIRED` |
| `Native/Ambitions/Features/Today/TodayPanels.swift` | ME04 | 2,423 | `EXTRACTION_REQUIRED` |
| `Native/Ambitions/Features/Plan/PlanFeatureService.swift` | ME05 | 2,394 | `EXTRACTION_REQUIRED` |
| `Native/Ambitions/Features/Profile/ProfileScreen.swift` | ME06 | 2,167 | `EXTRACTION_REQUIRED` |
| `Native/Ambitions/Features/Plan/PlanScreen.swift` | ME07 | 1,978 | `EXTRACTION_REQUIRED` |

ME08 owns shared projector/state/helper standards before repeated extraction.
ME10 owns the recurring architecture scan gate before large SwiftUI or service
expansion.

## Rules

Extract projector/state/helper seams before adding behavior. Protect behavior with focused product-contract tests. Keep visible copy, route compatibility, accessibility identifiers, public behavior, and raw values stable. Avoid broad cleanup, visual redesign, product expansion, dependency changes, workflow changes, and unrelated naming cleanup.

## Evidence Required

Ownership map, behavior preservation tests, UI/product contract tests, copy and accessibility preservation, rollback plan, diff-size budget, architecture scan, build, focused tests, and honest release-claim boundary.
