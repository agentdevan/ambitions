<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# BE-02-LEDGER-REPLAY

## Batch Identity

- Batch ID: `BE-02-LEDGER-REPLAY`
- Objective: formalize command, operation, event, side-effect, and receipt ledger taxonomy, idempotency, replay, and double-apply protection.
- Stage: backend/implementation

## Active Source Truth to Inspect

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Features/`
- `docs/status/current-implementation-map.md`
- `docs/status/release-evidence-packet.md`

## Allowed Scope

- Ledger/domain/service/repository tests and implementation seams only.
- Small additive changes that keep replay local and deterministic.

## Forbidden Scope

- No hosted telemetry, no cloud event bus, no external command sink.
- No hidden automation or silent mutation.
- No new top-level destination.

## Expected Changes

- Separate command, event, side effect, and receipt concerns.
- Make replay and idempotency explicit.
- Protect against double apply.

## Validation Expectations

- `git status --short`
- `git diff --check`
- focused `xcodebuild` tests
- `./scripts/build-local.sh`
- any focused ledger or replay scan that already exists in-repo

## Visual Proof Expectations

- None unless UI receives new ledger state.

## Accessibility Proof Expectations

- None unless UI receives new ledger state.

## Hard Red Stop Conditions

- A change would make the ledger non-local.
- A change would hide receipt or replay semantics.
- A change would require release proof the repo does not have.

## Rollback Expectations

- Undo only the batch-owned ledger changes.

## Runner Command

```bash
ALLOW_DIRTY=1 AUTO_BRANCH=0 AUTO_COMMIT=0 ACCESS_MODE=full \
  scripts/ambitions-codex-train.sh \
  BE-02-LEDGER-REPLAY \
  prompts/batches/amb-fe-be/BE-02-LEDGER-REPLAY.md
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
