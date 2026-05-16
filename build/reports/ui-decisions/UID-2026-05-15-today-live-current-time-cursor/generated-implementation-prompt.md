<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Decision Follow-Up Prompt

Batch ID: `UID-2026-05-15-today-live-current-time-cursor-VALIDATE-01`
Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Objective

Validate and, if needed, repair the source-installed Reality Meridian current-time cursor lane.

The active intended state is:

- `RealityMeridianTemporalWindow` owns proportional time-position math.
- `RealityMeridianCurrentTimeCursor` renders the exact current-time cursor.
- `DayTimelineRail.fusedCurrentTimeCursor()` owns the rail-layer fusion.
- `TodayScreen` renders `DayTimelineRail(...).fusedCurrentTimeCursor()`.
- `TodayRealityMeridianFusedRail.swift` must not be restored.

## Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-today-live-current-time-cursor.yaml`
- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift`
- `build/reports/ui-decisions/UID-2026-05-15-today-live-current-time-cursor/implementation-receipt.md`

## Allowed scope

- `Sources/Components/RealityMeridianTemporalPrimitives.swift`
- `Sources/Previews/RealityMeridianTemporalPreviews.swift`
- `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/AmbitionsTests/DesignSystem/RealityMeridianTemporalWindowTests.swift`
- related UI-decision reports for this decision

## Forbidden scope

- root IA changes
- unrelated Today behavior
- runtime scheduling logic
- persistence changes
- release readiness claims
- restoring `Native/Ambitions/Features/Today/TodayRealityMeridianFusedRail.swift`

## Validation

- `make ui-decision-all`
- `git diff --check`
- Xcode or Swift compile validation for the touched source
- XCTest execution for `RealityMeridianTemporalWindowTests`

## Boundary

Do not claim simulator, device, accessibility, hosted CI, release, or App Store readiness unless current evidence exists.
