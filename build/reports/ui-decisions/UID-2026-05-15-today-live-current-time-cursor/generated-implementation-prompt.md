<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Decision Implementation Prompt

Batch ID: `UID-2026-05-15-today-live-current-time-cursor-IMPLEMENTATION-01`
Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

## Objective

Implement the Today Reality Meridian rule that scheduled step nodes and the live current-time cursor are separate visual objects.

## Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/recipes/today/today_reality_meridian_flagship_surface.md`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-today-live-current-time-cursor.yaml`
- `build/reports/ui-decisions/UID-2026-05-15-today-live-current-time-cursor/design-system-gap-report.md`

## Allowed scope

- `Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
- `Native/Ambitions/Features/Today/*`

## Validation

- `python3 scripts/ambitions-ui-decision-check.py`
- `python3 scripts/ambitions-ui-decision-recipe-link-check.py`
- `git diff --check`

## Boundary

Do not change root IA, unrelated surfaces, runtime behavior, persistence, or release claims.
