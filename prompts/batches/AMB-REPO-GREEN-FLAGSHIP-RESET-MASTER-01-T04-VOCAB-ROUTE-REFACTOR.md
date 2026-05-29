<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
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
# IA Surface Vocabulary And Route Refactor

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T04-VOCAB-ROUTE-REFACTOR

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T04-VOCAB-ROUTE-REFACTOR prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T04-VOCAB-ROUTE-REFACTOR.md`

## Objective
Remove stale active IA/surface ownership from source, tests, docs, visual recipes, prompts, and governance while preserving allowed ordinary language.

## Active source truth to inspect
Read truth files, T03 ledger, app shell/routing, feature folders, tests, accessibility identifiers, visual encyclopedia surfaces, docs front doors, and Codex batch names.

## Allowed scope
Scoped renames/edits required to remove forbidden active ownership; project regeneration if source/project paths move; tests updated to canonical IA.

## Forbidden scope
No behavior deletion without replacement/proof, no persistence break without migration test, no test deletion to get Green, no broad UI rewrite, no ordinary-language purge.

## Implementation requirements
Replace active root ownership with Today/Goals/Capture/Time/You and primary objects. Preserve `User System Profile`; never collapse it to top-level Profile. Classify residual hits.

## Visual proof expectations
Only update visual recipe IDs/names where active stale surface ownership exists; no visual redesign.

## Accessibility expectations
Root identifiers must use canonical surfaces; preserve semantic names and testability.

## Privacy / trust expectations
No new dependency or user-data behavior.

## Continuity expectations
If compatibility bridges are temporarily necessary, remove them before Green or record Red/Yellow.

## Validation expectations
Run required stale-ownership `rg`, `xcodegen generate` if paths/config changed, focused tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Stale active tab/route/feature/screen/shell/visual ID remains, source break without validation, or broad behavior/UI rewrite.

## Rollback expectations
Use `git diff --name-status` and restore moved/renamed files from this train only.

## Expected final report format
Repairs made, residual allowed hits, files moved/renamed, validation, Yellow items, rollback.

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
