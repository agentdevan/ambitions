<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Tests Previews Accessibility And Identifier Repair

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T14-TESTS-PREVIEWS-A11Y

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T14-TESTS-PREVIEWS-A11Y prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T14-TESTS-PREVIEWS-A11Y.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Make tests, previews, and accessibility identifiers match canonical IA and object ownership.

## Active source truth to inspect
Truth files, T03/T04 vocabulary ledger/refactor reports, tests, UI tests, preview support, accessibility identifiers.

## Allowed scope
Test/previews/accessibility identifier repairs, canonical root navigation expectations, focused source fixes required by tests.

## Forbidden scope
No test deletion to get Green, no broad UI rewrite, no release/accessibility conformance claim without proof.

## Implementation requirements
Root navigation expects Today/Goals/Capture/Time/You. Preview fixture names and root accessibility identifiers use canonical surfaces/objects.

## Visual proof expectations
Preview/screenshot checks where available; record Yellow if unavailable.

## Accessibility expectations
Run or add focused accessibility identifier/semantic tests where feasible; do not claim public conformance.

## Privacy / trust expectations
No data/network changes.

## Continuity expectations
Tests should reflect existing behavior and canonical IA, not aspirational behavior.

## Validation expectations
Run `xcodegen generate`, focused unit/UI tests when simulator is available, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Tests deleted to hide failure, stale root navigation remains, build/test failure due refactor, or accessibility overclaim.

## Rollback expectations
Restore touched tests/previews/source from this train.

## Expected final report format
Tests changed, identifiers repaired, commands, pass/fail/blocked, Yellow/non-claims.
