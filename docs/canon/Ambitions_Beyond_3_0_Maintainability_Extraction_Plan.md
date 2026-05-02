# Ambitions Beyond 3.0 Maintainability Extraction Plan
<!-- markdownlint-disable MD013 -->

Status: Future planning plus ME01 audit baseline, ME08 standards, ME10 gate, and ME02 extraction evidence

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
repeated extraction. ME10 completed the recurring architecture scan gate on
2026-05-02 before large SwiftUI or service expansion.

ME02 completed the first Goals service extraction on 2026-05-02. It moved the
DEBUG-only `StubGoalsService` preview/test service from
`GoalsFeatureService.swift` to `StubGoalsService.swift`, reduced
`GoalsFeatureService.swift` from 5,024 to 4,883 lines, created a 144-line
support file, and preserved live repository-backed behavior.

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

## ME10 Architecture Gate

- Rerun `scripts/swiftui-architecture-scan.sh || true` before ME extraction
  batches and before broad UI/service growth.
- Files reported as `EXTRACTION_REQUIRED` cannot receive new behavior unless
  the current batch owns extraction or records a safe, validated exception.
- Files reported as `EXTRACTION_RECOMMENDED` require responsibility review
  before broad additions.
- Files reported as `RESPONSIBILITY_REVIEW` require named ownership before
  growing the file.
- New or materially larger Swift files must record before/after line counts,
  owner, responsibility, test lane, and rollback path in the batch report.
- ME02-ME07 remain the owners for the six Lane 2 extraction files.

## ME02 Extraction Evidence

- Owner: `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`.
- Extracted support file:
  `Native/Ambitions/Features/Goals/StubGoalsService.swift`.
- Responsibility moved: DEBUG-only preview/test service conformance used by
  preview containers and focused tests.
- Before/after size: owner file 5,024 to 4,883 lines; extracted support file
  144 lines; combined touched Goals service/support footprint 5,027 lines.
- Red repair: moving the stub exposed a private-file visibility boundary for
  `GoalsFeatureError`; ME02 repaired it by making the error type internal to
  the app module while keeping it unexported outside the module.
- Behavior proof: native simulator build passed on `iPhone 17`; focused Goals
  behavior tests passed with 52 tests and 0 failures.
- Non-claims: no behavior expansion, copy change, accessibility identifier
  change, route/raw-value change, persistence/schema change, dependency change,
  workflow change, visual redesign, release/platform claim, Product Depth
  implementation, PXOS implementation, or AmbitionsOS implementation.

## Evidence Required

Ownership map, behavior preservation tests, UI/product contract tests, copy and accessibility preservation, rollback plan, diff-size budget, architecture scan, build, focused tests, and honest release-claim boundary.
