<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_surface_multiple_active_batches-96568748

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
# Capture Object Extraction

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T10-CAPTURE-EXTRACTION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T10-CAPTURE-EXTRACTION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T10-CAPTURE-EXTRACTION.md`

## Objective
Make Capture ownership clean around Atmosphere Composer and remove plural destination ownership.

## Active source truth to inspect
Truth files, source-refactor map, Capture/Captures source/tests/previews, capture routing docs and visual recipes.

## Allowed scope
Scoped Capture source organization, canonical naming, tests/previews, docs/recipe ID repair, project regeneration if paths move.

## Forbidden scope
No default notes feed/inbox top-level, no plural Captures destination ownership, no broad visual rewrite, no behavior deletion.

## Implementation requirements
Capture is the canonical destination; Atmosphere Composer is primary object. Route reveal after input remains; Needs a Place / Ready to Place / Grow into Goal language stays where applicable.

## Visual proof expectations
Run preview/screenshot checks if available or record Yellow.

## Accessibility expectations
Composer labels, route actions, and input semantics must remain accessible.

## Privacy / trust expectations
No cloud intake or external processing.

## Continuity expectations
Preserve existing capture promotion/routing behavior.

## Validation expectations
Run `xcodegen generate` if paths changed, focused Capture tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Plural destination remains active, route break, build failure, test deletion, or source-proof overclaim.

## Rollback expectations
Restore moved Capture files/imports and project changes from this train.

## Expected final report format
Capture object map, plural repair proof, validation, Yellow/non-claims.

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
