# POST-PK03 — Dirty Worktree Reconciliation Gate Prompt

<!-- markdownlint-disable MD013 -->

Status: Active safety gate prompt.  
Date: 2026-05-08  
Scope: post-PK03 / pre-continuation worktree safety.  
Type: governance, evidence preservation, and continuation gate.

## Mission

After PK03 closes and before the global train continues, run a Dirty Worktree Reconciliation Gate.

This gate exists because prior tooling/MCP work left a dirty worktree while the global train resumed. The global train must not continue over unknown dirty state.

## Hard Rules

- Do not run `git reset --hard`.
- Do not run `git clean -fd`.
- Do not discard files.
- Do not continue the global train until dirty state is classified.
- Do not overwrite active-batch state with stale values.
- Preserve current active batch truth from `.codex/state/active-batch.yml`.
- If another process changes active batch state during this gate, re-read active state before any state write.

## Required Read Order

Read:

- `AGENTS.md`
- `.codex/state/active-batch.yml`
- `.codex/reports/current-batch-train-state.md`
- `docs/codex/BATCH_REGISTRY.md`
- `docs/codex/BATCH_REGISTRY_EFC_OVERLAY.md`
- `docs/codex/GLOBAL_FULL_STACK_COMPLETION_ORDER_EFC_PEAK_OVERLAY.md`
- `docs/codex/EFC_FLAGSHIP_PROOF_OPERATING_LAYER.md`
- this prompt

## Required Command

Run:

```bash
bash scripts/codex-post-pk03-dirty-reconciliation.sh
```

If the script exits `0`, the worktree is clean and the global train may continue after re-reading active state.

If the script exits `86`, stop and classify dirty files.

## Classification Required If Dirty

Classify every dirty file into one of:

1. Expected PK03 output.
2. Expected global-train output before/after PK03.
3. Expected MCP/tooling output from prior prompt.
4. Generated/log artifact that should remain untracked or ignored.
5. Accidental or unsafe change.
6. Unknown / needs human review.

## Required Report

If dirty, create or update:

```text
docs/audits/dirty-worktree-reconciliation-report.md
```

Include:

- current active batch
- next eligible batch
- full dirty file list
- classification table
- recommended action per file: keep / commit / stash / ignore / discard-after-approval
- EFC applicability
- non-claims
- exact commands proposed next
- hard Red blockers

## Allowed Outcomes

### Green / Clean

- Worktree is clean.
- Active batch state has been re-read.
- Global train may continue.

### Green / Classified And Committed

- Dirty files are legitimate.
- Files are committed in the smallest coherent commit.
- Active state is re-read.
- Global train may continue.

### Accepted Yellow / Intentional Dirty State

Allowed only if:

- dirty files are generated artifacts or local logs;
- they are documented;
- they are ignored/stashed or intentionally preserved;
- continuation risk is low and recorded.

### Hard Red

Stop if:

- unknown dirty files remain;
- app source changed outside PK03 scope;
- active state cannot be reconciled;
- dirty generated files would pollute the repo;
- release/device/accessibility/legal/privacy claims were added without proof.

## EFC Applicability

EFC applicability: invoked.

This gate affects continuation proof, release-claim safety, source-truth integrity, and dirty-state recovery.

## Non-Claims

This gate does not claim build success, test success, release readiness, device proof, public accessibility proof, legal/privacy compliance, App Store readiness, TestFlight readiness, or product behavior implementation.
