<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-07-ROOT-SURFACES

## Batch Identity

- Batch ID: `FE-07-ROOT-SURFACES`
- Objective: build the five flagship root surfaces around one dominant object.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/You/`
- `Sources/AmbitionsDesignSystem/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Root-surface UI and focused tests/previews only.
- Additive surface composition that keeps the dominant object clear.

## Forbidden Scope

- No dashboard/card-stack fallback.
- No extra root destination.
- No generic productivity composition.

## Expected Changes

- Make each root answer one question quickly.
- Keep one dominant object per surface.
- Preserve calm, premium composition.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused UI tests or preview checks
- `make prompt-audit`

## Visual Proof Expectations

- Provide preview or screenshot evidence for all five roots.

## Accessibility Proof Expectations

- Provide Dynamic Type, VoiceOver, Reduce Motion, contrast, and non-color proof for the roots.

## Hard Red Stop Conditions

- Any root becomes a generic module pile or dashboard.
- Any root creates a sixth destination.
- Any root loses the dominant-object rule.

## Rollback Expectations

- Revert only the root-surface files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-07-ROOT-SURFACES \
  prompts/batches/amb-fe-be/FE-07-ROOT-SURFACES.md
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
