<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches
> Prior recommended actions: Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-01-RUNTIME-BASELINE

## Batch Identity

- Batch ID: `BE-01-RUNTIME-BASELINE`
- Objective: promote explicit Private Life Runtime boundaries around the existing local runtime, container, persistence, repository, and local-only seams.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-MANIFEST.md`
- `Native/Ambitions/App/`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Persistence/`
- `scripts/`
- `project.yml`

## Allowed Scope

- Runtime/container/persistence/service boundary files and focused tests only.
- Small additive source changes that keep the app local-first and compatibility-safe.

## Forbidden Scope

- No hosted backend, cloud sync, hosted AI, or new top-level IA.
- No unrelated UI redesign or broad cleanup.
- No signing, workflow, or dependency changes.

## Expected Changes

- Name the runtime boundary clearly.
- Keep the local-only path explicit.
- Preserve compatibility seams without expanding them.

## Validation Expectations

- `git status --short`
- `git diff --check`
- `xcodegen generate` if project generation is affected
- focused `xcodebuild` tests for the changed owner files
- `./scripts/build-local.sh`

## Visual Proof Expectations

- None unless a UI seam is unexpectedly touched.

## Accessibility Proof Expectations

- None unless a UI seam is unexpectedly touched.

## Hard Red Stop Conditions

- Any cloud, hosted, or external-LLM dependency appears.
- Any runtime change requires a new top-level product destination.
- Any claim of release or device proof appears without evidence.

## Rollback Expectations

- Revert only the files changed by this batch and preserve the existing local runtime model.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-01-RUNTIME-BASELINE \
  prompts/batches/amb-fe-be/BE-01-RUNTIME-BASELINE.md
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
