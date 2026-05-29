<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_surface_multiple_active_batches-13212827

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
# You Object Extraction

## Batch ID
AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T12-YOU-EXTRACTION

## Runner command
`scripts/ambitions-codex-train.sh AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T12-YOU-EXTRACTION prompts/batches/AMB-REPO-GREEN-FLAGSHIP-RESET-MASTER-01-T12-YOU-EXTRACTION.md`

## Protected workspace material
Do not delete `.agents/` or `.codex/` material. Another workspace session may be updating the skills database. If unrelated `.agents/` or `.codex/` changes block this train, preserve them, stash them with an explicit message, or stop for owner direction; do not remove them to get Green.

## Objective
Make You ownership clean around User System Profile, Trust, and Data Controls.

## Active source truth to inspect
Truth files, source-refactor map, You/Profile source/tests/previews, trust/privacy/data-control docs.

## Allowed scope
Scoped You source organization, canonical User System Profile naming, trust/data-control seams, tests/previews, docs/recipe IDs.

## Forbidden scope
No top-level Profile destination, social profile framing, admin console, generic settings wall, behavior deletion, or broad visual rewrite.

## Implementation requirements
You is canonical destination. Profile may remain only as ordinary data/model language or inside User System Profile.

## Visual proof expectations
Run preview/screenshot checks if available or record Yellow.

## Accessibility expectations
Preserve settings-style grouped navigation semantics, labels, and controls.

## Privacy / trust expectations
Preserve inspect/reset/delete/export local trust posture; no external profile backend.

## Continuity expectations
Keep trust and memory continuity flows wired.

## Validation expectations
Run `xcodegen generate` if paths changed, focused You tests/build when feasible, prompt validators, Codex OS validator, JSON parse, `git diff --check`, and `git status --short`.

## Hard Red stop conditions
Profile remains active root ownership, privacy/trust weakening, build failure, or tests deleted.

## Rollback expectations
Restore moved You/Profile files/imports and project changes from this train.

## Expected final report format
You object map, trust/data-control proof status, validation, Yellow/non-claims.

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
