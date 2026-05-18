<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-05-GEOMETRY-REALITY-MERIDIAN

## Batch Identity

- Batch ID: `FE-05-GEOMETRY-REALITY-MERIDIAN`
- Objective: lock Reality Meridian geometry/topology with labels, current-time glow, NOW marker, connected nodes, attached Start Here, commitments, source freshness, proof trail, closure prompts, and Dynamic Type behavior.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Time/`
- `Sources/AmbitionsDesignSystem/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Reality Meridian UI/layout primitives and focused previews/tests only.
- Additive geometry or read-model changes that preserve the root shell.

## Forbidden Scope

- No calendar grid clone.
- No new top-level tab.
- No silent time mutation.

## Expected Changes

- Make the Meridian readable as a living object.
- Keep the current-time treatment visible and non-shaming.
- Preserve the Start Here attachment and proof trail.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused UI tests or preview checks if present
- `make prompt-audit`

## Visual Proof Expectations

- Provide preview or screenshot evidence for normal, overloaded, and reduced-motion states.

## Accessibility Proof Expectations

- Provide Dynamic Type, VoiceOver, Reduce Motion, contrast, and non-color meaning proof.

## Hard Red Stop Conditions

- The screen becomes a calendar clone or generic chart.
- The Meridian loses attachment to the active object model.
- The batch claims public accessibility proof without evidence.

## Rollback Expectations

- Revert only the Meridian files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-05-GEOMETRY-REALITY-MERIDIAN \
  prompts/batches/amb-fe-be/FE-05-GEOMETRY-REALITY-MERIDIAN.md
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
