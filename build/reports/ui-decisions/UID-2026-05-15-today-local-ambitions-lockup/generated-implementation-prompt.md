<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# UI Decision Implementation Prompt

Batch ID: `UID-2026-05-15-today-local-ambitions-lockup-IMPLEMENTATION-01`

Decision ID: `UID-2026-05-15-today-local-ambitions-lockup`

## Objective

Implement the compact Today `Local · Ambitions` lockup through the design-system path, then wire it only into the declared Today/shell scope.

## Active source truth to inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `frontend/visual-encyclopedia/FRONTEND_AUTHORITY_INDEX.md`
- `frontend/visual-encyclopedia/ENCYCLOPEDIA_TO_FRONTEND_OS.md`
- `frontend/visual-encyclopedia/DESIGN_SYSTEM_TO_VISUAL_ENCYCLOPEDIA_BRIDGE.md`
- `frontend/visual-encyclopedia/decisions/active/UID-2026-05-15-today-local-ambitions-lockup.yaml`
- `build/reports/ui-decisions/UID-2026-05-15-today-local-ambitions-lockup/design-system-gap-report.md`

## Allowed scope

- `Sources/Components/ShellChromePrimitives.swift`
- `Native/Ambitions/Features/Today/*`
- `Native/Ambitions/App/AppMeridianShell.swift`

## Forbidden scope

- unrelated surfaces
- runtime or persistence behavior
- top-level IA changes
- release claims

## Validation expectations

- `python3 scripts/ambitions-ui-decision-check.py`
- `python3 scripts/ambitions-ui-decision-recipe-link-check.py`
- `python3 scripts/ambitions-ui-decision-sync.py --decision UID-2026-05-15-today-local-ambitions-lockup`
- `git diff --check`

## Visual expectations

Add or update a preview/fixture if a reusable primitive lands.

## Hard Red conditions

- Do not make a broad redesign.
- Do not change bottom navigation.
- Do not claim proof before code, preview, and receipt evidence exists.

## Rollback expectations

Revert only files touched by this implementation batch and regenerate the decision reports.
