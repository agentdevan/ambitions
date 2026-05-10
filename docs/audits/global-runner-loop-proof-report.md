# Global Runner Loop Proof Report

## Status

Green for governance/tooling hardening and commit eligibility only.

The follow-up cleanup gate stopped the overlapping PK15 runner/Codex execution chain, confirmed no Ambitions runner/Codex exec/actual `xcodebuild` validation job remained, and kept the unresolved PK15 source/test work uncommitted for `PK15-FINALIZE-01`.

## Failure Class Repaired

- nested conductor loop: parent prompt now forbids unbounded child execution; supervisor owns top-level loop.
- repeated child launch: attempt ledger records unresolved child state and blocks normal reruns.
- incomplete artifact retry: Unknown/incomplete artifacts are classified unresolved, not retry triggers.
- Phase 02 rerun when finalization needed: `prompts/_BATCH_FINALIZE_TEMPLATE.md` and `PK15-FINALIZE-01` route existing diffs to review/finalization.
- Xcode build lock risk: supervisor checks active `ambitions-codex-train`, `codex exec`, and `xcodebuild` processes before launching.
- same-root retry risk: supervisor blocks repeated same-batch launch within a supervisor pass.

## Files Changed

- `.codex/state/global-train-attempt-ledger.md` - committed attempt state and PK15 finalization-required route.
- `prompts/_BATCH_FINALIZE_TEMPLATE.md` - reusable finalization prompt template.
- `prompts/batches/PK15-FINALIZE-01.md` - bounded PK15 finalization prompt for existing Yellow diff.
- `prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md` - converted from nested conductor posture to supervisor-compatible prompt.
- `prompts/batches/GLOBAL-RUNNER-LOOP-PROOF-01.md` - saved batch prompt for this governance hardening pass.
- `scripts/ambitions-global-train-supervisor.sh` - external one-batch-at-a-time supervisor.
- `Makefile` - supervisor targets.
- `docs/codex/ambitions-hybrid-runner.md` - supervisor run guidance.
- `docs/codex/global-train-supervisor.md` - operator runbook.
- `docs/audits/global-runner-loop-proof-report.md` - this report.

## Guards Added

- guard: process conflict preflight - file: `scripts/ambitions-global-train-supervisor.sh` - effect: stops before overlapping runner/Codex/Xcode work.
- guard: actual Xcode build matching - file: `scripts/ambitions-global-train-supervisor.sh` - effect: blocks real `xcodebuild` jobs without treating `xcodebuildmcp` helper processes as build-lock conflicts.
- guard: lock file - file: `scripts/ambitions-global-train-supervisor.sh` - effect: prevents concurrent supervisor launches and safely clears stale locks.
- guard: tracked dirty worktree stop - file: `scripts/ambitions-global-train-supervisor.sh` - effect: prevents global train launch over unresolved tracked work.
- guard: global conductor child refusal - file: `scripts/ambitions-global-train-supervisor.sh` - effect: refuses to run `RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION` as a child.
- guard: same-pass repeat block - file: `scripts/ambitions-global-train-supervisor.sh` - effect: prevents repeated same-root launch in `--until-complete`.
- guard: finalization-required ledger route - file: `.codex/state/global-train-attempt-ledger.md` - effect: routes PK15 to finalization instead of a normal rerun.

## Supervisor Commands

- status: `make global-train-status`
- next: `make global-train-next`
- once: `make global-train-once`
- until-complete: `make global-train-until-complete`

## Attempt Ledger

- path: `.codex/state/global-train-attempt-ledger.md`
- states supported: planned, running, green, accepted-yellow, yellow-unresolved, red-unresolved, unknown-unresolved, repair-required, finalization-required, blocked.
- continuation rules: continue on Green or accepted Yellow only; stop and route unresolved Yellow/Red/Unknown to finalization or repair.

## Finalization Template

- path: `prompts/_BATCH_FINALIZE_TEMPLATE.md`
- intended use: inspect existing diff/run artifacts, avoid Spark reruns, run focused sequential validation, and commit only with evidence-supported Green or accepted Yellow.

## Remaining Train Execution Path

- command: `make global-train-until-complete`
- when safe: after unresolved PK15 tracked work is finalized or otherwise classified and the tracked worktree is clean.
- when blocked: unresolved Yellow, Red, Unknown, process conflict, dirty tracked worktree, queue/state inconsistency, repeated same-root failure, or forbidden scope change.

## Validation

Commands run:

- `git diff --check` - exit 0 - passed.
- `python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json >/tmp/ambitions-global-queue-json-check.txt` - exit 0 - queue JSON parsed.
- `bash -n scripts/ambitions-codex-train.sh` - exit 0 - syntax passed.
- `bash -n scripts/ambitions-prompt-audit.sh` - exit 0 - syntax passed.
- `bash -n scripts/ambitions-global-train-supervisor.sh` - exit 0 - syntax passed.
- `test -x scripts/ambitions-codex-train.sh` - exit 0 - executable.
- `test -x scripts/ambitions-prompt-audit.sh` - exit 0 - executable.
- `test -x scripts/ambitions-global-train-supervisor.sh` - exit 0 - executable.
- `make -n global-train-status` - exit 0 - target dry-run printed supervisor command.
- `make -n global-train-next` - exit 0 - target dry-run printed supervisor command.
- `make -n global-train-once` - exit 0 - target dry-run printed supervisor command.
- `make -n global-train-until-complete` - exit 0 - target dry-run printed supervisor command.
- `scripts/ambitions-global-train-supervisor.sh --status` - exit 0 - reported dirty tracked worktree and active conflicting PK15 runner/Codex/Xcode processes.
- `scripts/ambitions-global-train-supervisor.sh --next` - exit 0 - reported `PK15-FINALIZE-01` and `prompts/batches/PK15-FINALIZE-01.md`.
- `scripts/ambitions-prompt-audit.sh` - exit 0 - accepted Yellow: support/eval/template files classified; no active runnable prompt missing metadata.
- `scripts/ambitions-codex-train.sh --self-check` - exit 0 - runner self-check passed.
- `kill 7766 27533 27542 27544` - exit 0 - stopped overlapping PK15 runner/Codex execution chain.
- `pgrep -fl 'ambitions-codex-train|codex exec|(^|/| )xcodebuild( |$)' || true` - exit 0 - no remaining Ambitions runner, Codex exec, or actual `xcodebuild` process.
- `scripts/ambitions-global-train-supervisor.sh --status` - exit 0 - no process conflicts after cleanup.

Commands not run:

- `make global-train-until-complete` - intentionally not run by this governance batch.
- `scripts/ambitions-global-train-supervisor.sh --until-complete` - intentionally not run by this governance batch.
- `make batch BATCH=PK15 ...` - intentionally not run by this governance batch.
- `make batch BATCH=RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION ...` - intentionally not run by this governance batch.

## Claims Not Made

- release readiness
- build success beyond recorded commands
- test success beyond recorded commands
- visual quality
- accessibility conformance
- performance validation
- physical-device validation
- TestFlight/App Store readiness
- actual global train completion
