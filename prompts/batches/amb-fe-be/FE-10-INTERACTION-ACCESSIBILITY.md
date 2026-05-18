<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-10-INTERACTION-ACCESSIBILITY

## Batch Identity

- Batch ID: `FE-10-INTERACTION-ACCESSIBILITY`
- Objective: lock motion, haptics, Dynamic Type, VoiceOver, focus, hit targets, contrast, and non-color state.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Features/`
- `Sources/AmbitionsDesignSystem/`
- `AppUI/Sources/AmbitionsWidgetUI/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Interaction and accessibility code, previews, and tests only.
- Additive state/motion work that preserves existing routes.

## Forbidden Scope

- No motion without a reduced-motion equivalent.
- No color-only or gesture-only meaning.
- No accessibility claim without evidence.

## Expected Changes

- Keep interaction readable and calm.
- Keep accessibility and motion proof explicit.
- Preserve native iPhone touch behavior.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused accessibility or UI tests
- `make prompt-audit`

## Visual Proof Expectations

- Provide preview or screenshot evidence if interaction visuals change.

## Accessibility Proof Expectations

- Provide Dynamic Type, VoiceOver, Reduce Motion, contrast, focus, hit target, and non-color proof.

## Hard Red Stop Conditions

- Motion has no reduced-motion equivalent.
- Accessibility becomes a late add-on.
- The batch claims public accessibility approval.

## Rollback Expectations

- Revert only the interaction/accessibility files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-10-INTERACTION-ACCESSIBILITY \
  prompts/batches/amb-fe-be/FE-10-INTERACTION-ACCESSIBILITY.md
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
