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
- No Plan tab revival.
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
