<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-02-DESIGN-LANGUAGE

## Batch Identity

- Batch ID: `FE-02-DESIGN-LANGUAGE`
- Objective: freeze the Ambitions design language, one-primary-object rule, anti-patterns, native iOS rules, materials, proof language, and recovery tone.
- Stage: frontend/governance

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/AmbitionsCanon/README.md`
- `docs/AmbitionsCanon/`
- `frontend/visual-encyclopedia/`

## Allowed Scope

- Design-language docs only.
- No app-source, token, or primitive edits.

## Forbidden Scope

- No generic productivity language.
- No dashboard/card-stack drift.
- No new visual authority root.

## Expected Changes

- Define the active design language and banned counter-patterns.
- Keep recovery tone non-shaming and calm.
- Keep the one-primary-object rule explicit.

## Validation Expectations

- `git status --short`
- `git diff --check`
- `make prompt-audit`

## Visual Proof Expectations

- None. This is design-language only.

## Accessibility Proof Expectations

- None. This is design-language only.

## Hard Red Stop Conditions

- A prompt weakens the one-primary-object rule.
- A prompt normalizes AI theater or generic dashboard visuals.
- A prompt makes recovery language shaming or punitive.

## Rollback Expectations

- Delete only the files written by this prompt.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-02-DESIGN-LANGUAGE \
  prompts/batches/amb-fe-be/FE-02-DESIGN-LANGUAGE.md
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
