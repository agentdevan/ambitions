<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: authority-rewrite, merge-overlap
> Dispositions: merge-or-sequence-file-ownership, rewrite-authority-reference

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
