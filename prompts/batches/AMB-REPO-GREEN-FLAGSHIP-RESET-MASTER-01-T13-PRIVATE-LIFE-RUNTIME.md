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
# Private Life Runtime Source Proof Alignment

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T13-PRIVATE-LIFE-RUNTIME

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T13-PRIVATE-LIFE-RUNTIME prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T13-PRIVATE-LIFE-RUNTIME.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Align source, tests, and docs around the Private Life Runtime proof target without claiming completion.

## Active source truth to inspect
Truth files, `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md`, Domain/Services/Persistence runtime files, tests, receipts/proof docs.

## Allowed scope
Runtime proof maps, focused deterministic/local source or tests when tightly scoped, docs/status proof boundaries, reset reports.

## Forbidden scope
No cloud/LLM/backend shortcut, no hidden recommendation engine, no completion claim without scenario tests, no frontend-doc truth relocation.

## Implementation requirements
Map or test the proof target: same intent plus different local context yields different inspectable daily execution sequence, relaunch replay, closure/recovery adaptation, and proof/receipt continuity.

## Visual proof expectations
None unless UI proof seams are touched.

## Accessibility expectations
No accessibility proof claims unless tested.

## Privacy / trust expectations
Runtime remains deterministic, local, inspectable, receipt-backed, and user-controllable.

## Continuity expectations
Preserve existing persistence and recommendation contracts; avoid migrations unless tested.

## Validation expectations
Run focused runtime tests if present/added, build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Cloud/core LLM/backend introduced, proof target claimed complete without tests, persistence break, or build failure.

## Rollback expectations
Restore touched runtime/test/docs files from this train only.

## Expected final report format
Proof target map, tests added/run, gaps, validation, non-claims.

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
