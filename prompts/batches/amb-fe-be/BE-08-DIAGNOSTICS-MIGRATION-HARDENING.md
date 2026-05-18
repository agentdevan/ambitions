<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-08-DIAGNOSTICS-MIGRATION-HARDENING

## Batch Identity

- Batch ID: `BE-08-DIAGNOSTICS-MIGRATION-HARDENING`
- Objective: harden diagnostics, migration safety, schema notes, rollback notes, and known-failure classification.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`

## Allowed Scope

- Diagnostics and migration hardening code, docs, and focused tests only.
- Small additive rollback notes and failure classification changes.

## Forbidden Scope

- No broad cleanup outside the batch-owned seam.
- No release claim without current proof.

## Expected Changes

- Make known failure states explicit.
- Improve migration/rollback observability.
- Keep scope narrow and local.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`

## Visual Proof Expectations

- None unless diagnostics become a UI surface.

## Accessibility Proof Expectations

- None unless diagnostics become a UI surface.

## Hard Red Stop Conditions

- Migration safety becomes speculative.
- Diagnostics claim production observability or hosted CI.
- The batch expands into unrelated repo cleanup.

## Rollback Expectations

- Remove only the diagnostics and migration changes made here.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-08-DIAGNOSTICS-MIGRATION-HARDENING \
  prompts/batches/amb-fe-be/BE-08-DIAGNOSTICS-MIGRATION-HARDENING.md
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
