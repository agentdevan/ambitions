<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: duplicate_stable_id, same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-duplicate_stable_id-91382211, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-38999459

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-authority, merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-FE-BE-PREFLIGHT-00

## Batch Identity

- Batch ID: `AMB-FE-BE-PREFLIGHT-00`
- Objective: inspect current repo authority, active batch state, train docs, prompt layout, duplicates, obsolete material, and runner readiness before any implementation batch runs.
- Stage: docs/governance

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `docs/README.md`
- `docs/status/current-implementation-map.md`
- `docs/status/repo-cleanup-index.md`
- `docs/status/release-evidence-packet.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/batch-trains/amb-fe-be/`
- `prompts/batches/amb-fe-be/`

## Allowed Scope

- Docs and prompt inspection only.
- Write `.codex/reports/AMB-FE-BE-PREFLIGHT-00.md` only.
- Do not edit app source, tests, project files, signing, workflows, or `.codex/runs/`.

## Forbidden Scope

- Any `Native/**`, `Sources/**`, `AppUI/**`, or `project.yml` edit.
- Any branch creation, commit, push, or staged `.codex/runs/` artifact.
- Any claim of implementation, validation, accessibility, or release proof.

## Expected Changes

- Confirm whether the new train package is discoverable through repo OS docs.
- Confirm the active queue is not silently overridden.
- Record duplicates, obsolete names, and prompt-path mapping notes.

## Validation Expectations

- `git status --short`
- `make runner-access-check`
- `make batch-self-check`
- `make prompt-audit`
- `scripts/ambitions-codex-train.sh --help`
- `python3 scripts/ambitions-swift6-modernization-scan.py --help`
- `git diff --check`

## Visual Proof Expectations

- None. This is docs/governance only.

## Accessibility Proof Expectations

- None. This is docs/governance only.

## Hard Red Stop Conditions

- Active authority cannot be located.
- Prompt headers are missing or malformed.
- The train would duplicate active canon or repo OS.
- The batch would require app-source edits.
- The batch would claim proof it does not have.

## Rollback Expectations

- Remove only any files created by this prompt and preserve existing repo truth.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  AMB-FE-BE-PREFLIGHT-00 \
  prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md
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
