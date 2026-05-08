# PK Train Integration And Dirty Worktree Report

<!-- markdownlint-disable MD013 -->

Date: 2026-05-08
Result: Yellow / accepted for integration commit. PK is integrated and helper
scripts route to PK00. The historical stash is preserved and not applied
because it conflicts with current PK priority and current IA truth.

## Initial State

- Current branch: `main`
- Current HEAD: `bf6bdea4` (`Harden ACX repair diagnosis defaults`)
- Remote origin: `https://github.com/agentdevan/ambitions.git`
- Tracking: `main...origin/main`
- Dirty files: none from `git status --short`
- Untracked files: none from `git status --short`
- Stash: `stash@{0}: On main: pre-sync local dirty work before pulling Codex OS upgrade`
- `.github/workflows`: no workflow files found during preflight.
- Initial risk classification: Green for active worktree cleanliness; Yellow for unreconciled historical stash that must be inspected before claiming all local work is complete.

## Repo Truth Findings

- Active global train before PK integration: Global full-stack execution.
- Current next eligible batch before PK integration: LDI15 Living Plan Recompiler, per `.codex/reports/current-run-state.md` and `.codex/reports/current-batch-train-state.md`.
- Existing backend/platform hardening exists through PFC, AOS, LDI, persistence, runtime, notification, EventKit, external snapshot, and test files.
- PK-equivalent source truth did not exist as a named active train before this pass.
- `GLOBAL_FULL_STACK_COMPLETION_ORDER.md`, `GLOBAL_OPTIMIZED_IMPLEMENTATION_ORDER.md`, `GLOBAL_FUTURE_BATCH_DEPENDENCY_GRAPH.md`, `BATCH_REGISTRY.md`, `CONTEXT_INDEX.md`, and current run-state files were active sequencing/status surfaces.
- The active worktree was clean; the remaining local-work concern is the
  historical stash, now classified below.

## PK Integration

- Added active PK train source truth: `docs/codex/batch-trains/PK00_PK41_PLATFORM_KERNEL_TRAIN.md`.
- Added PK00 execution prompt: `docs/codex/batches/PK00_Current_Backend_Proof_Baseline.md`.
- Added PK state mirror: `docs/codex/platform-kernel-current-state.md`.
- Added PK risk register: `docs/audits/platform-kernel-risk-register.md`.

## Sequencing Reconciliation

- Before: LDI15 Living Plan Recompiler was next eligible.
- After: PK00 Current Backend Proof Baseline is next eligible backend/platform batch and should run before LDI15 or other feature/intelligence expansion unless a dirty or half-complete active batch must close first.
- Existing PFC/AOS/LDI evidence is retained, not deleted. Future backend/platform work must be reconciled into PK batches where dependency order overlaps.

## Dirty / Stashed Worktree

- Active dirty worktree: none at preflight.
- Current intended dirty files: PK integration docs/state/script changes only.
- Historical stash: inspected with `git stash show --name-only`,
  `git stash show --stat`, and targeted diffs.
- Stash contents: global order/status docs plus
  `scripts/global-train-next-batch.sh` and
  `scripts/global-train-status-summary.sh`.
- Stash classification: docs/source truth, batch registry/state, and helper
  scripts. No generated artifacts were identified from the name/stat view.
- Stash disposition: defer with explicit Yellow. The stashed docs insert PLR/AFI
  and include `Today / Goals / Capture / Time / You`, which conflicts with the
  current supplied source truth of `Today / Goals / Capture / Plan / You` and
  with the new PK-first priority. The useful helper-script idea was reconciled
  narrowly by teaching the live helper scripts to recognize PK IDs and route
  `PK00` from run state.

## Validation Log

- `pwd`: `/Users/devan/Documents/GitHub/ambitions`.
- `git status --short`: clean before edits; expected docs/state/script changes
  after PK integration.
- `git branch --show-current`: `main`.
- `git remote -v`: `origin https://github.com/agentdevan/ambitions.git`.
- `git log --oneline -5`: HEAD began at `bf6bdea4 Harden ACX repair diagnosis defaults`.
- `git diff --check`: exit 0.
- `python3 scripts/ai/acx_local.py bundle quick`: exit 0; raw logs under
  `.codex/logs/2026-05-08T09-32-56/`.
- `python3 scripts/ai/acx_local.py bundle docs`: exit 0; `acx-gate-all`
  Green with advisory scan findings only; raw logs under
  `.codex/logs/2026-05-08T09-32-56/` and `09-32-57/`.
- `python3 scripts/ai/acx_local.py bundle batch-closeout`: exit 0; advisory
  scan findings only.
- `scripts/run-doc-qa.sh || true`: completed with existing broad advisory
  backlog. `lychee` reported 640 total links, 0 errors, 1 redirect. Markdownlint
  reported the known large pre-existing lint backlog. Logs under
  `docs/audits/doc-qa/20260508-093311-*`.
- `scripts/batch-train-gate-check.sh || true`: completed with Yellow hint for
  the expected working tree changes.
- `python3 scripts/ai/acx_closeout.py`: produced suggested Yellow until session
  confirms scope/evidence/claims.
- `python3 scripts/ai/acx_sanitized_evidence.py`: produced sanitized evidence
  packet; raw logs remain local.
- `bash -n scripts/global-train-next-batch.sh scripts/global-train-status-summary.sh`: exit 0.
- `scripts/global-train-next-batch.sh`: returned `PK00 Current Backend Proof
  Baseline after integration` from `.codex/reports/current-run-state.md`.
- `scripts/global-train-status-summary.sh`: returned PK insertion summary and
  `PK00` as next eligible.

## Known Yellows

- Historical stash is preserved and deferred because it contains PLR/AFI order
  changes that conflict with current PK-first sequencing and current IA truth.
- Docs QA has broad pre-existing markdown/deprecated-language advisory backlog.
- No app build/test was run because this pass changed docs/state/scripts only.

## Non-Claims

This integration pass does not claim production readiness, backend 100/100,
migration safety, data-loss-proof storage, sync readiness, cloud readiness, AI
readiness, privacy compliance, CI green, App Store readiness, TestFlight
readiness, physical-device proof, public accessibility proof, or
performance-budget proof.
