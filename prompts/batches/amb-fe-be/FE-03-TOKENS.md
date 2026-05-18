<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-03-TOKENS

## Batch Identity

- Batch ID: `FE-03-TOKENS`
- Objective: define token architecture for color, surface, material, typography, spacing, geometry, motion, haptic, accessibility, proof, source freshness, closure/recovery, Start Here, Reality Meridian, Quiet Glass, and Graphite Recess.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/AmbitionsCanon/`
- `Sources/AmbitionsDesignSystem/`
- `AppUI/Sources/AmbitionsWidgetUI/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Design-system token files and focused tests/previews only.
- Small additive token changes only.

## Forbidden Scope

- No app-wide visual rewrite.
- No top-level IA change.
- No generic UI fallback.

## Expected Changes

- Make the token architecture explicit and inspectable.
- Keep source freshness and proof tokens local and meaningful.
- Preserve calm premium material language.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused design-system tests if present
- `make prompt-audit`

## Visual Proof Expectations

- If token visuals change, capture preview evidence from the design-system package.

## Accessibility Proof Expectations

- If token visuals change, include Dynamic Type, Reduce Motion, contrast, and non-color meaning evidence.

## Hard Red Stop Conditions

- Tokens become generic theme knobs.
- Tokens weaken accessibility or proof language.
- Tokens create a second authority root.

## Rollback Expectations

- Revert only the token files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-03-TOKENS \
  prompts/batches/amb-fe-be/FE-03-TOKENS.md
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
