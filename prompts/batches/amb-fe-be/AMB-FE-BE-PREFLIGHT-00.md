<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-FE-BE-PREFLIGHT-00

## Batch Identity

- Batch ID: `AMB-FE-BE-PREFLIGHT-00`
- Objective: inspect current repo authority, active batch state, train docs, prompt layout, duplicates, obsolete material, and runner readiness before any implementation batch runs.
- Stage: docs/governance

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `README.md`
- `docs/README.md`
- `docs/status/current-implementation-map.md`
- `docs/status/repo-cleanup-index.md`
- `docs/status/release-evidence-packet.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/CONTEXT_INDEX.md`
- `docs/codex/batch-trains/amb-fe-be/`
- `prompts/batches/amb-fe-be/`

## Allowed Scope

- Docs and prompt inspection only.
- Write `.codex/reports/AMB-FE-BE-PREFLIGHT-00.md` only.
- Do not edit app source, tests, project files, signing, workflows, or `.codex/runs/`.

## Forbidden Scope

- Any `Native/**`, `Sources/**`, `AppUI/**`, or `project.yml` edit.
- Any branch creation, commit, push, or staged `.codex/runs/` artifact.
- Any claim of implementation, validation, accessibility, or release proof.

## Expected Changes

- Confirm whether the new train package is discoverable through repo OS docs.
- Confirm the active queue is not silently overridden.
- Record duplicates, obsolete names, and prompt-path mapping notes.

## Validation Expectations

- `git status --short`
- `make runner-access-check`
- `make batch-self-check`
- `make prompt-audit`
- `scripts/ambitions-codex-train.sh --help`
- `python3 scripts/ambitions-swift6-modernization-scan.py --help`
- `git diff --check`

## Visual Proof Expectations

- None. This is docs/governance only.

## Accessibility Proof Expectations

- None. This is docs/governance only.

## Hard Red Stop Conditions

- Active authority cannot be located.
- Prompt headers are missing or malformed.
- The train would duplicate active canon or repo OS.
- The batch would require app-source edits.
- The batch would claim proof it does not have.

## Rollback Expectations

- Remove only any files created by this prompt and preserve existing repo truth.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  AMB-FE-BE-PREFLIGHT-00 \
  prompts/batches/amb-fe-be/AMB-FE-BE-PREFLIGHT-00.md
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
