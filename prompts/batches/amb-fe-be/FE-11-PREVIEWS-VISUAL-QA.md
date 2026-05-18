<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-11-PREVIEWS-VISUAL-QA

## Batch Identity

- Batch ID: `FE-11-PREVIEWS-VISUAL-QA`
- Objective: install preview, screenshot, visual-QA, and honest proof reporting infrastructure.
- Stage: frontend/tooling

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/status/release-evidence-packet.md`
- `Sources/AmbitionsDesignSystem/`
- `AppUI/Sources/AmbitionsWidgetUI/`
- `Native/Ambitions/Features/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Preview scaffolding, screenshot helpers, and QA reporting only.
- No app behavior changes unless required by preview support.

## Forbidden Scope

- No fabricated visual proof.
- No release or device claim.
- No broad UI redesign.

## Expected Changes

- Make preview evidence easy to reproduce.
- Keep the visual-QA report honest about what is and is not proven.
- Support the owned state matrix.

## Validation Expectations

- `git status --short`
- `git diff --check`
- preview-focused checks or tests if present
- `make prompt-audit`

## Visual Proof Expectations

- Required. Capture the matrix states the batch owns.

## Accessibility Proof Expectations

- Required when previews touch UI state: Dynamic Type, VoiceOver, Reduce Motion, contrast, and non-color proof.

## Hard Red Stop Conditions

- The batch pretends screenshots are device proof.
- The batch mutates source outside the preview seam.
- The batch writes a generic QA dashboard.

## Rollback Expectations

- Remove only the preview/QA files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-11-PREVIEWS-VISUAL-QA \
  prompts/batches/amb-fe-be/FE-11-PREVIEWS-VISUAL-QA.md
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
