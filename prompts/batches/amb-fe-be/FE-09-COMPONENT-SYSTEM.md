<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-09-COMPONENT-SYSTEM

## Batch Identity

- Batch ID: `FE-09-COMPONENT-SYSTEM`
- Objective: define the Ambitions component system and preview matrix.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Sources/AmbitionsDesignSystem/`
- `AppUI/Sources/AmbitionsWidgetUI/`
- `Native/Ambitions/Features/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Shared component definitions, previews, and focused tests only.
- Additive component work that preserves root-surface ownership.

## Forbidden Scope

- No generic component library drift.
- No new top-level route or destination.
- No broad visual redesign.

## Expected Changes

- Make the component system inspectable and reusable.
- Provide a preview matrix for the owned states.
- Keep the system calm and native.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused component/package tests
- `make prompt-audit`

## Visual Proof Expectations

- Provide preview evidence for the required state matrix.

## Accessibility Proof Expectations

- Provide Dynamic Type, VoiceOver, Reduce Motion, contrast, and non-color proof across the matrix.

## Hard Red Stop Conditions

- The system becomes a generic UI kit.
- The system weakens primary-object ownership.
- The system claims visual proof without screenshots or previews.

## Rollback Expectations

- Revert only the component-system files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-09-COMPONENT-SYSTEM \
  prompts/batches/amb-fe-be/FE-09-COMPONENT-SYSTEM.md
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
