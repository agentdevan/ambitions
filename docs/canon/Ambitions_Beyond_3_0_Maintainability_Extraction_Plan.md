# Ambitions Beyond 3.0 Maintainability Extraction Plan
<!-- markdownlint-disable MD013 -->

Status: Future planning plus ME01 audit baseline and ME08 standards; no refactor performed

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

ME08 completed shared projector/state/helper standards on 2026-05-02 before
repeated extraction. ME10 owns the recurring architecture scan gate before large
SwiftUI or service expansion.

## ME08 Shared Standards

- State files own serializable/display state only. They do not fetch, mutate,
  route, or format broad copy.
- Projector files are deterministic and side-effect free. Large projectors split
  by projection family before new behavior lands.
- Helper files are named by responsibility, not vague utility buckets.
- View files receive already-shaped state and invoke callbacks. Logic-heavy
  additions to view files are Yellow or Red depending on size and risk.
- Screen contract snapshots live beside the owned feature and protect visible
  product language plus accessibility anchors.
- Accessibility identifiers, routes, raw values, persistence, and external
  payloads are compatibility-sensitive and require CS proof before changes.
- Existing shared UI primitives are reused before local panel/list abstractions
  are invented.
- Each extraction batch names behavior-preservation tests before moving code.
- Current Plan seams are `PlanLifeSuiteState.swift`,
  `PlanReflowDecisionState.swift`, and `PlanScreenContractSnapshot.swift`.
  Future extraction batches must not assume `PlanLifeSuiteProjector.swift`
  exists or create it without an explicit owner/gate.

## Rules

Extract projector/state/helper seams before adding behavior. Protect behavior with focused product-contract tests. Keep visible copy, route compatibility, accessibility identifiers, public behavior, and raw values stable. Avoid broad cleanup, visual redesign, product expansion, dependency changes, workflow changes, and unrelated naming cleanup.

## Evidence Required

Ownership map, behavior preservation tests, UI/product contract tests, copy and accessibility preservation, rollback plan, diff-size budget, architecture scan, build, focused tests, and honest release-claim boundary.
