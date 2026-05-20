<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Docs Visual Encyclopedia Status And Historical Pruning

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T15-DOCS-HISTORICAL-PRUNING

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T15-DOCS-HISTORICAL-PRUNING prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T15-DOCS-HISTORICAL-PRUNING.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Remove active stale surface ownership from docs/status/visual encyclopedia while preserving useful historical/supporting value.

## Active source truth to inspect
Truth files, Historical Policy, docs front doors, visual encyclopedia, status docs, product-canon, history, validation, Codex docs.

## Allowed scope
Line edits, caveat/supporting/historical headers, front-door link repair, visual recipe ID repair, archive/delete proposals when policy gates are not met.

## Forbidden scope
No deletion before Historical Policy gates, no active truth weakening, no release proof overclaim, no source behavior changes.

## Implementation requirements
Docs front doors must not present stale surface names as current IA. Old proofs must be dated/SHA-scoped. Historical files may mention stale names only with context.

## Visual proof expectations
Visual recipe IDs canonical; no visual redesign or screenshot claim unless run.

## Accessibility expectations
Docs must not claim accessibility verification without evidence.

## Privacy / trust expectations
No privacy/legal approval claims without reviewed artifacts.

## Continuity expectations
Preserve useful historical context through labels rather than deletion.

## Validation expectations
Run docs scans, visual recipe surface scans, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Historical deletion without policy, active stale docs IA remains, truth weakened, or proof overclaim.

## Rollback expectations
Restore touched docs/status/visual files from this train.

## Expected final report format
Docs repaired, historical/supporting classifications, deletion proposals, validation, Yellow.
