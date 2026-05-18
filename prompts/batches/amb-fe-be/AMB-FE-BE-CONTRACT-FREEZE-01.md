<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-FE-BE-CONTRACT-FREEZE-01

## Batch Identity

- Batch ID: `AMB-FE-BE-CONTRACT-FREEZE-01`
- Objective: freeze the train contracts for Start Here, Reality Meridian, LifeShape capacity, recommendation explanation, source freshness, proof receipts, closure/recovery, protected time, privacy/local-only, replay/restoration, and the no-claim boundary for downstream AMB-FE-BE work.
- Stage: docs/governance

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `docs/README.md`
- `docs/codex/batch-trains/amb-fe-be/README.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-CONTRACTS.md`
- `docs/codex/batch-trains/amb-fe-be/AMB-FE-BE-IMPLEMENTATION-MANIFEST.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`

## Allowed Scope

- Train contract docs and prompt files only.
- Do not edit app source, tests, or project wiring.

## Forbidden Scope

- No new product strategy.
- No app-source edits.
- No duplicate canon or duplicate repo OS.

## Expected Changes

- Freeze the contract language for the whole train.
- Document the exact no-claim boundaries and local-only posture.
- Keep `Plan` as compatibility-only/contextual language, not active top-level IA.
- Prevent any downstream prompt from implying hosted AI, hosted sync, cloud user profiling, or a custom cloud personal-data backend.

## Validation Expectations

- `git status --short`
- `git diff --check`
- `make runner-access-check`
- `make batch-self-check`
- `make prompt-audit`

## Visual Proof Expectations

- None. This is contract-only.

## Accessibility Proof Expectations

- None. This is contract-only.

## Hard Red Stop Conditions

- Any contract would weaken the active IA or local-first posture.
- Any text would restore a banned top-level tab or duplicate authority.
- Any claim would outrun current proof or imply a hosted data/backend posture the repo has not proven.

## Rollback Expectations

- Revert only files created by this prompt.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  AMB-FE-BE-CONTRACT-FREEZE-01 \
  prompts/batches/amb-fe-be/AMB-FE-BE-CONTRACT-FREEZE-01.md
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
