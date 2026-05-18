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
