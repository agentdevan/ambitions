<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-12-CHROME-CONTRACTS-HARDENING

## Batch Identity

- Batch ID: `FE-12-CHROME-CONTRACTS-HARDENING`
- Objective: harden chrome, contract binding, migration, visual anti-generic checks, reports, and rollback guidance.
- Stage: frontend/handoff

## Active Source Truth to Inspect

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/codex/batch-trains/amb-fe-be/`
- `frontend/visual-encyclopedia/`
- `docs/status/release-evidence-packet.md`

## Allowed Scope

- Frontend contract and handoff docs plus focused supporting source if required.
- Final train-report assets only.

## Forbidden Scope

- No new app behavior claim.
- No unsupported release or integrated proof.
- No duplicate authority root.

## Expected Changes

- Lock the chrome contract and visual anti-generic checks.
- Preserve rollback guidance.
- Keep migration language explicit and truthful.

## Validation Expectations

- `git status --short`
- `git diff --check`
- `make prompt-audit`
- any existing visual-QA scan already in-repo

## Visual Proof Expectations

- Include the required screenshot/preview/report references for any UI-affecting handoff.

## Accessibility Proof Expectations

- Include the required accessibility references for any UI-affecting handoff.

## Hard Red Stop Conditions

- The batch claims final UX approval without evidence.
- The batch weakens the visual anti-generic checks.
- The batch invents a second frontend authority root.

## Rollback Expectations

- Revert only the chrome/contract docs written by this batch.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-12-CHROME-CONTRACTS-HARDENING \
  prompts/batches/amb-fe-be/FE-12-CHROME-CONTRACTS-HARDENING.md
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
