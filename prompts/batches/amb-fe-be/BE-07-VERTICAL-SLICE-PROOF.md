<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-07-VERTICAL-SLICE-PROOF

## Batch Identity

- Batch ID: `BE-07-VERTICAL-SLICE-PROOF`
- Objective: prove one local end-to-end moat slice from intent/capture to placement, Start Here, receipt, closure, replay, and report.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `Native/Ambitions/App/`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/You/`

## Allowed Scope

- One local vertical slice and focused tests only.
- Minimal owner-file changes that prove the slice end to end.

## Forbidden Scope

- No broad architecture rewrite.
- No release/device/accessibility claim unless separately evidenced.

## Expected Changes

- Show the slice moving through the intended local seam.
- Keep receipts and replay visible.
- Preserve exact IA and compatibility seams.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`
- any batch-owned report artifact required by the slice

## Visual Proof Expectations

- If UI is touched, capture preview or screenshot evidence for the slice.

## Accessibility Proof Expectations

- If UI is touched, include the accessibility proof requirements from the owner files.

## Hard Red Stop Conditions

- The slice requires a second hidden path to work.
- The slice silently mutates data.
- The slice claims integrated proof without evidence.

## Rollback Expectations

- Revert only the files owned by the slice and preserve the stable seams.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-07-VERTICAL-SLICE-PROOF \
  prompts/batches/amb-fe-be/BE-07-VERTICAL-SLICE-PROOF.md
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
