<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Goals Object Extraction

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T09-GOALS-EXTRACTION.md`

## Objective
Make Goals ownership clean around Constellation Atlas and remove dashboard/board/ranking drift as active product structure.

## Active source truth to inspect
Truth files, source-refactor map, Goals source/tests/previews, visual recipes/docs for Goals.

## Allowed scope
Scoped Goals source organization under `ConstellationAtlas`, imports, tests/previews, docs/recipe naming.

## Forbidden scope
No KPI dashboard, ranked life score, generic board as top-level product model, broad visual rewrite, or behavior deletion.

## Implementation requirements
Goals is Constellation Atlas. Preserve domain behavior while improving object ownership and stale-language cleanup.

## Visual proof expectations
Run preview/screenshot checks if available or record Yellow.

## Accessibility expectations
Preserve semantic grouping and labels.

## Privacy / trust expectations
No new data/network behavior.

## Continuity expectations
Keep Goal Detail/Mission Control compatibility where source requires it; do not overclaim completion.

## Validation expectations
Run `xcodegen generate` if paths changed, focused Goals tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Build failure due refactor, stale active surface remains, dashboard drift introduced, or tests deleted.

## Rollback expectations
Restore moved/renamed Goals files and imports from this train.

## Expected final report format
Goals object map, changed files, validation, residual Yellow, non-claims.
