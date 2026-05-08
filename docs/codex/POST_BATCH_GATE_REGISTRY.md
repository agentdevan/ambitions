# Post-Batch Gate Registry

<!-- markdownlint-disable MD013 -->

Status: Active continuation gate registry.  
Date: 2026-05-08  
Scope: post-batch safety gates for the global train.

## Purpose

This registry defines mandatory gates that must run after specific batches and before the global train continues.

It exists to prevent Codex from continuing over dirty, unclassified, stale, or unsafe repo state.

## Gate Rules

- Gates do not replace the active global batch train.
- Gates do not change product IA or app behavior by themselves.
- Gates must re-read `.codex/state/active-batch.yml` before acting.
- Gates must not run destructive git cleanup commands.
- If a gate exits nonzero, the global train must stop until the report is classified.

## Active Gates

| Trigger | Gate | Required command | Pass condition | Block condition | Resume behavior |
| --- | --- | --- | --- | --- | --- |
| After PK03 AppUnitOfWork Foundation closes, before selecting the next global batch | Post-PK03 Dirty Worktree Reconciliation Gate | `bash scripts/codex-post-pk03-dirty-reconciliation.sh` | exit 0 and clean worktree | exit 86 or unknown dirty state | Re-read active batch, then resume global train only after clean/classified state |

## Post-PK03 Dirty Worktree Reconciliation Gate

Source prompt:

- `docs/codex/batches/POST_PK03_Dirty_Worktree_Reconciliation_Gate_Prompt.md`

Script:

- `scripts/codex-post-pk03-dirty-reconciliation.sh`

Generated evidence:

- `.codex/logs/dirty-worktree/status-*.txt`
- `.codex/logs/dirty-worktree/untracked-*.txt`
- `.codex/logs/dirty-worktree/name-status-*.txt`
- `.codex/patches/dirty-worktree-*.patch`
- `.codex/patches/dirty-worktree-staged-*.patch`
- `docs/audits/post-pk03-dirty-worktree-reconciliation-*.md`
- `docs/audits/post-pk03-dirty-worktree-reconciliation-latest.md`

## Required Codex Behavior

After PK03 closes:

1. Do not start PK04 or any next global batch yet.
2. Re-read active batch state.
3. Run the required command.
4. If clean, record the report and continue.
5. If dirty, classify every dirty file before continuing.
6. Do not discard or reset anything without human approval.

## Hard Red

Continuing the global train after PK03 without this gate is a Hard Red.

Continuing with dirty unclassified state is a Hard Red.

## Non-Claims

This registry does not implement app behavior, validate builds/tests, prove release readiness, prove device behavior, prove public accessibility conformance, or grant legal/privacy approval.
