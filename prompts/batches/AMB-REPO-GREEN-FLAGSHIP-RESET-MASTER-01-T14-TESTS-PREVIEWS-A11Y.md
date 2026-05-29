<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
