<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Decision Follow-Up Prompt

Batch ID: `UID-2026-05-16-start-here-product-kernel-VALIDATE-01`
Decision ID: `UID-2026-05-16-start-here-product-kernel`

## Objective

Validate and, if needed, repair the source-installed Start Here product-kernel lane.

The active intended state is:

- `StartHereProductKernel` defines required Start Here structure.
- `StartHereProductFact` defines proof facts.
- `StartHereProductKernelAudit` blocks generic recommendation/task-card language and non-canonical primary action copy.
- `StartHereProductProofStack` exists as the reusable product-kit proof-stack primitive.
- `StartHereProductKernelTests` covers required proof and anti-generic copy.
- `StartHereProductKernelProjection.swift` adapts `DayRailHeroStepState` into `StartHereProductKernel` with privacy-safe substitutions.
- Existing Today `StartHereSurface` keeps the active visual contract until a direct consumption pass is explicitly scoped.

## Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-16-start-here-product-kernel.yaml`
- `Sources/Components/StartHereProductPrimitives.swift`
- `Native/AmbitionsTests/DesignSystem/StartHereProductKernelTests.swift`
- `Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- `build/reports/ui-decisions/UID-2026-05-16-start-here-product-kernel/implementation-receipt.md`

## Allowed scope

- `Sources/Components/StartHereProductPrimitives.swift`
- `Native/AmbitionsTests/DesignSystem/StartHereProductKernelTests.swift`
- `Native/Ambitions/Features/Today/StartHereProductKernelProjection.swift`
- `Native/Ambitions/Features/Today/TodayDayRailPanels.swift`
- related UI-decision reports for this decision

## Forbidden scope

- root IA changes
- runtime scheduling logic
- persistence changes
- generic recommendation-card framing
- release readiness claims

## Validation

- `make ui-decision-all`
- `git diff --check`
- Xcode or Swift compile validation for touched source
- XCTest execution for `StartHereProductKernelTests`

## Boundary

Do not claim simulator, device, accessibility, hosted CI, release, or App Store readiness unless current evidence exists.
