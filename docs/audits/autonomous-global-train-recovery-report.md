# Autonomous Global Train Recovery Report

Status: YELLOW

## Dirty Worktree Cleanup

- Preserved tracked PK15 persistence work under `Native/Ambitions/Persistence/*`.
- Preserved governance and prompt artifacts introduced by this recovery phase in `prompts/batches/` and `.codex/runs/**` as uncommitted evidence.
- No source feature/UI files were edited in this phase.
- Final gate stopped Yellow instead of auto-committing because the working tree intentionally still contains unfinalized PK15 source/test work.

## Runner Decision

- Created: `scripts/ambitions-autonomous-train.sh`.
- Added non-recursive CLI modes: `--status`, `--next`, `--run-current`, `--until-complete`.
- Wired autonomous execution through `Makefile` as `make autonomous-train` (default continuation entry).
- Maintains queue fallback from `docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json` and active-finalization routing from `.codex/state/global-train-attempt-ledger.md`.
- Uses `AUTO_BRANCH=0`, `ALLOW_MAIN_COMMIT=1`, `ALLOW_DIRTY=1` when launching `make batch`.
- Keeps recursive conductor prompts blocked through active-runner detection.
- Does not hold `.codex/state/global-train.lock` across a child runner launch; stale locks are cleared before launch, then live process preflight and same-pass repeat protection own concurrency control so child finalization prompts do not self-block.
- Phase 03 review repair: moved `current_attempt_status` above the command dispatcher so `--run-current` can resolve the helper before launch.
- Phase 04 repair pass: no additional code repair was required after rerunning bounded governance validation; `PK15-FINALIZE-01` remains the selected next child batch.

## PK15 Status

- Not modified in this phase.
- Existing `PK15` diff remains untouched for `PK15-FINALIZE-01`.
- PK15 is the next selected child batch; this recovery report does not claim PK15 completion.

## Autonomous Execution Model

- One bounded batch is selected from queue/ledger, run through canonical runner, then stopped on command failure.
- `--until-complete` advances one batch at a time with same-batch repeat protection in-session.
- No nested conductor prompts were introduced.

## Remaining Queue

- Current executable target remains PK15, then PK16 by canonical queue ordering.

## Validation

- `scripts/ambitions-process-preflight.sh --assert-clear`
- `git status --short --branch`
- `git diff --name-status`
- `python3 -m json.tool docs/codex/GLOBAL_QUEUE_CANONICAL_ORDER.json`
- `bash -n scripts/ambitions-autonomous-train.sh`
- `bash -n scripts/ambitions-codex-train.sh`
- `bash -n scripts/ambitions-process-preflight.sh`
- `bash -n scripts/ambitions-global-train-supervisor.sh`
- `bash -n scripts/ambitions-prompt-audit.sh`
- `scripts/ambitions-autonomous-train.sh --status`
- `scripts/ambitions-autonomous-train.sh --next`
- `AMBITIONS_RUNNER_ACTIVE=1 scripts/ambitions-autonomous-train.sh --run-current` confirmed recursive invocation blocks before launch.
- `make -n autonomous-train`
- `git diff --check -- scripts/ambitions-autonomous-train.sh Makefile docs/codex/ambitions-hybrid-runner.md docs/codex/global-train-supervisor.md docs/audits/autonomous-global-train-recovery-report.md`
- Phase 04 rerun: `scripts/ambitions-process-preflight.sh --assert-clear` returned clear while ignoring only this phase's own runner process tree and MCP helper processes.
- Phase 04 rerun: `scripts/ambitions-autonomous-train.sh --status` and `--next` selected `PK15-FINALIZE-01`.
- Post-final local repair: removed the autonomous script's live lock handoff so `PK15-FINALIZE-01` can run its own process preflight without treating the parent autonomous command as a stale global lock.
- Final gate: `STATUS: YELLOW` because committing every dirty path would mix governance work with pending PK15 persistence/test work.

## Claims Not Made

- No release readiness, full accessibility coverage, device proof, or App Store/TestFlight claims.
- No global completion claim has been made.
