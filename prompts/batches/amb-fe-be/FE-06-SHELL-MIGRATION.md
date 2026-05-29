<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260, AMB28-same_surface_multiple_active_batches-13212827, AMB28-same_surface_multiple_active_batches-26899932, AMB28-same_surface_multiple_active_batches-34058953, AMB28-same_surface_multiple_active_batches-66075429, AMB28-same_surface_multiple_active_batches-96568748

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-06-SHELL-MIGRATION

## Batch Identity

- Batch ID: `FE-06-SHELL-MIGRATION`
- Objective: lock the final shell tabs Today / Goals / Capture / Time / You and rehome valuable legacy surfaces without broad deletion.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/App/`
- `Native/Ambitions/Features/`
- `frontend/visual-encyclopedia/`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md`

## Allowed Scope

- Shell/router code and focused migration tests only.
- Preserve compatibility seams that are still active.

## Forbidden Scope

- No sixth tab.
- No Time surface revival.
- No broad route/raw-value cleanup beyond the batch seam.

## Expected Changes

- Keep the five-tab shell explicit.
- Rehome legacy surfaces only where the active truth allows it.
- Preserve the internal compatibility seams.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`

## Visual Proof Expectations

- If shell UI changes, provide preview or screenshot evidence for the top level.

## Accessibility Proof Expectations

- If shell UI changes, provide Dynamic Type, VoiceOver, Reduce Motion, contrast, and non-color proof.

## Hard Red Stop Conditions

- Any top-level tab count changes.
- Any compatibility seam becomes user-facing truth without approval.
- Any batch claims integrated proof.

## Rollback Expectations

- Undo only the shell/router files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-06-SHELL-MIGRATION \
  prompts/batches/amb-fe-be/FE-06-SHELL-MIGRATION.md
```

## Final Report Format

- Status
- Summary
- Repo OS / Repo Doctor integration
- Files changed
- Installed train location
- Recommended next runner command
- Full recommended execution order
- Validation
- Classification
- Risks / blockers
- Worktree hygiene
- Rollback
- Next decision needed from user

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
