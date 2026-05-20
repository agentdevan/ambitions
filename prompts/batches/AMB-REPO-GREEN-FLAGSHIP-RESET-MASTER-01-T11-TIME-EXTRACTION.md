<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Time Object Extraction

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T11-TIME-EXTRACTION.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Make Time ownership clean around LifeShape Field and remove stale time-surface ownership.

## Active source truth to inspect
Truth files, source-refactor map, Time and Plan-compatibility source/tests/previews, Time docs/visual recipes.

## Allowed scope
Scoped Time source organization, LifeShape Field naming, compatibility bridge cleanup where safe, tests/previews, docs/recipe IDs.

## Forbidden scope
No calendar clone, generic planning dashboard, Plan as active IA/surface, behavior deletion, or broad visual rewrite.

## Implementation requirements
Time is canonical destination. Plan may remain only as ordinary/domain/compatibility language, never as active IA/surface ownership.

## Visual proof expectations
Run preview/screenshot checks if available or record Yellow.

## Accessibility expectations
Preserve time/capacity semantics and nonvisual equivalents.

## Privacy / trust expectations
No calendar permission change or new data path.

## Continuity expectations
Respect existing internal compatibility seams until safely migrated.

## Validation expectations
Run `xcodegen generate` if paths changed, focused Time tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Plan remains active root ownership, calendar-clone drift, build failure, or test deletion.

## Rollback expectations
Restore moved/renamed Time/Plan-compatibility files and imports from this train.

## Expected final report format
Time object map, compatibility decisions, validation, Yellow/non-claims.
