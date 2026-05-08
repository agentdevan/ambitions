# Post-PK03 Dirty Worktree Gate Installation Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08  
Result: Green with running-Codex visibility caveat  
Scope: post-batch safety gate installation  
Trigger: After PK03 AppUnitOfWork Foundation closes, before global-train continuation

## Result

A mandatory Post-PK03 Dirty Worktree Reconciliation Gate was installed into the repo.

The gate preserves worktree evidence, blocks continuation over unclassified dirty state, and allows the global train to continue only after the worktree is clean or explicitly classified.

## Active Batch Observed During Installation

At installation time, `.codex/state/active-batch.yml` reported:

```text
Current batch: PK02 Architecture Boundary Scanner
Next eligible batch: PK03 AppUnitOfWork Foundation
```

The gate was installed without modifying active batch state.

## Files Added

- `scripts/codex-post-pk03-dirty-reconciliation.sh`
- `docs/codex/batches/POST_PK03_Dirty_Worktree_Reconciliation_Gate_Prompt.md`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/audits/post-pk03-dirty-worktree-gate-installation-report.md`

## Files Updated

- `AGENTS.md`

## Gate Behavior

The script:

```bash
bash scripts/codex-post-pk03-dirty-reconciliation.sh
```

Creates evidence before making any decision:

- `.codex/logs/dirty-worktree/status-*.txt`
- `.codex/logs/dirty-worktree/untracked-*.txt`
- `.codex/logs/dirty-worktree/name-status-*.txt`
- `.codex/patches/dirty-worktree-*.patch`
- `.codex/patches/dirty-worktree-staged-*.patch`
- `docs/audits/post-pk03-dirty-worktree-reconciliation-*.md`
- `docs/audits/post-pk03-dirty-worktree-reconciliation-latest.md`

Exit behavior:

- `0`: worktree is clean; global train may continue after re-reading active state.
- `86`: worktree is dirty; continuation is blocked until every dirty file is classified.

## Required Classification If Dirty

Every dirty file must be classified as one of:

1. Expected PK03 output.
2. Expected global-train output before/after PK03.
3. Expected MCP/tooling output from prior prompt.
4. Generated/log artifact that should remain untracked or ignored.
5. Accidental or unsafe change.
6. Unknown / needs human review.

## Running-Codex Visibility Caveat

This gate was committed to the remote repo through GitHub connector writes.

If a local Codex process is already running in the Mac VM, it may not automatically see these new files until it pulls/reloads context. To make the running process use this gate, provide it the interruption instruction from the user-facing closeout or manually run the script after PK03.

## EFC Applicability

EFC applicability: invoked.

- Product proof: not applicable; no app behavior changed.
- Trust proof: dirty state is preserved before decision.
- Privacy proof: no secrets/network/user data access added.
- Accessibility proof: not applicable; no UI behavior changed.
- Degraded-state proof: dirty worktree exits `86` and blocks continuation.
- Test proof: script added but not run from this environment.
- Release-claim boundary: no build/test/release/device/accessibility/legal/privacy/App Store claim added.
- Recovery proof: rollback path below.
- Performance proof: not applicable.
- Continuation proof: post-batch registry and AGENTS now reference the gate.

## Non-Claims

This installation does not claim:

- app behavior implementation
- production Swift changes
- build success
- test success
- dirty worktree cleanup completed
- PK03 completion
- global train continuation completed
- release readiness
- App Store readiness
- TestFlight readiness
- physical-device proof
- public accessibility proof
- legal/privacy compliance

## Rollback Path

Remove or revert:

- `scripts/codex-post-pk03-dirty-reconciliation.sh`
- `docs/codex/batches/POST_PK03_Dirty_Worktree_Reconciliation_Gate_Prompt.md`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- `docs/audits/post-pk03-dirty-worktree-gate-installation-report.md`
- post-batch gate references in `AGENTS.md`

No app data, schema, source code, signing, entitlement, dependency, generated project, or runtime rollback is required.

## Next Action

After PK03 closes, Codex must run:

```bash
bash scripts/codex-post-pk03-dirty-reconciliation.sh
```

If the script exits `86`, Codex must stop and classify dirty state before resuming the global train.
