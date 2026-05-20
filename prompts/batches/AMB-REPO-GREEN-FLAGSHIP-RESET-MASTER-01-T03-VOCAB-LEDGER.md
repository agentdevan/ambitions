<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# Final IA Surface Vocabulary Ledger

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T03-VOCAB-LEDGER.md`

## Objective
Create a context-aware ledger for stale IA/surface vocabulary before refactoring.

## Active source truth to inspect
Read truth files, current audit files, source routing/shell files, docs front doors, visual recipe roots, tests, `.codex`, `.agents`, and prompts.

## Allowed scope
Classification scripts/reports if needed, `docs/audits/*ia-surface-vocabulary-ledger.md`, validation proof, master JSON.

## Forbidden scope
No blind replacements, source renames, test deletes, historical deletes, or release claims.

## Implementation requirements
Search tracked files for Plan/Profile/Habits/Insights/Captures variants; classify every hit using the master taxonomy; identify forbidden active ownership hits and repair trains; record allowed hits without forcing zero-token cleanup.

## Visual proof expectations
None; visual recipe hits are classification evidence only.

## Accessibility expectations
Classify root accessibility identifiers if stale.

## Privacy / trust expectations
Do not inspect secrets; no new data path.

## Continuity expectations
Historical references may remain only with classification.

## Validation expectations
Run tracked-file scans, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Unclassified active ownership hits, false zero claim, or blind ordinary-language rewrite.

## Rollback expectations
Restore only ledger/report/script changes from this train.

## Expected final report format
Ledger path, counts by classification, forbidden hit map, allowed hit policy, Yellow owner-review list, non-claims.
