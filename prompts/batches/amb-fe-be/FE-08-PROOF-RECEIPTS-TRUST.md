<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-08-PROOF-RECEIPTS-TRUST

## Batch Identity

- Batch ID: `FE-08-PROOF-RECEIPTS-TRUST`
- Objective: build the receipt drawer, proof trail, source freshness, recommendation explanation, closure/recovery states, and Trust & Automation surface.
- Stage: frontend/implementation

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Features/You/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Time/`
- `Sources/AmbitionsDesignSystem/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Trust/receipt/proof UI and focused tests/previews only.
- Additive surface state that preserves local-only trust behavior.

## Forbidden Scope

- No hidden automation.
- No cloud trust backend.
- No score-based or shaming trust language.

## Expected Changes

- Make receipts and proof trails visible and inspectable.
- Keep source freshness and explanation prominent.
- Preserve non-shaming recovery states.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused UI tests or preview checks
- `make prompt-audit`

## Visual Proof Expectations

- Provide preview or screenshot evidence for the trust and receipt states.

## Accessibility Proof Expectations

- Provide Dynamic Type, VoiceOver, Reduce Motion, contrast, and non-color proof for the trust states.

## Hard Red Stop Conditions

- The surface becomes a dashboard or audit console.
- Any receipt path hides correction or recovery.
- Any trust state depends on hosted services.

## Rollback Expectations

- Revert only the trust and receipt files written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-08-PROOF-RECEIPTS-TRUST \
  prompts/batches/amb-fe-be/FE-08-PROOF-RECEIPTS-TRUST.md
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
