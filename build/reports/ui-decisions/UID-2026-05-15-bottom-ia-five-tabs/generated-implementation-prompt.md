<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Decision Implementation Prompt

Batch ID: `UID-2026-05-15-bottom-ia-five-tabs-IMPLEMENTATION-01`
Decision ID: `UID-2026-05-15-bottom-ia-five-tabs`

## Objective

Protect the root destination contract: `Today / Goals / Capture / Time / You`.

## Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-bottom-ia-five-tabs.yaml`
- `build/reports/ui-decisions/UID-2026-05-15-bottom-ia-five-tabs/design-system-gap-report.md`

## Allowed scope

- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`
- `Sources/Components/NavigationPrimitives.swift`

## Validation

- `python3 scripts/ambitions-ui-decision-check.py`
- `python3 scripts/ambitions-ui-decision-recipe-link-check.py`
- `git diff --check`

## Boundary

Do not add a sixth root destination. Do not alter unrelated features, runtime behavior, persistence, or release claims.
