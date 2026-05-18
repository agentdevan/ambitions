<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# FE-01-CANON-FREEZE

## Batch Identity

- Batch ID: `FE-01-CANON-FREEZE`
- Objective: freeze the final IA, root ownership, deprecated terminology, migration map, and frontend doc classification.
- Stage: frontend/governance

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md`
- `docs/README.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `frontend/visual-encyclopedia/`
- `docs/canon/frontend/` if present

## Allowed Scope

- Docs and canonical mapping files only.
- No app source and no new implementation.

## Forbidden Scope

- No new top-level tab or destination.
- No duplicate frontend authority root.
- No app behavior claims.

## Expected Changes

- Lock the final user-facing IA.
- Mark deprecated terminology and migration notes clearly.
- Classify frontend docs as active, supporting, historical, or obsolete.

## Validation Expectations

- `git status --short`
- `git diff --check`
- `make runner-access-check`
- `make prompt-audit`
- `git diff --check`

## Visual Proof Expectations

- None. This is canon freeze only.

## Accessibility Proof Expectations

- None. This is canon freeze only.

## Hard Red Stop Conditions

- Any prompt revives a banned top-level tab.
- Any prompt promotes a compatibility name to active truth.
- Any prompt creates a duplicate canon root.

## Rollback Expectations

- Delete only the files written by this prompt.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  FE-01-CANON-FREEZE \
  prompts/batches/amb-fe-be/FE-01-CANON-FREEZE.md
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
