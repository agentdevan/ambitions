# Runner Repair Autopilot Report

## Scope

Phase 02 bounded repair for `RUNNER-REPAIR-AUTOPILOT-01` and PK15 finalization routing.

## Root Cause

PK15 finalization was blocked because the old preflight logic relied on broad process pattern matching:

- `pgrep -fl 'ambitions-codex-train|codex exec|xcodebuild'` matched the active repair runner itself.
- The same broad pattern could also match helper processes, including `xcodebuildmcp`.
- This produced a false positive hard blocker in `PK15-FINALIZE-01` and interrupted safe repair progression.

## Process Pattern Audit

- Too broad: broad `pgrep` patterns on `ambitions-codex-train`, `codex exec`, and `xcodebuild`.
- Correctly ignored/filtered:
  - current runner process family (self, parent shell, runner ancestors, and same-runner descendants),
  - `xcodebuildmcp` helper processes,
  - grep/pgrep helper commands,
  - stale lock files whose pid is no longer alive.
- Correct blockers:
  - `xcodebuild` jobs with real `xcodebuild` commands,
  - active `scripts/ambitions-codex-train.sh` processes outside current process tree,
  - active `codex exec` processes outside current process tree,
  - live global trainer lock file with running lock pid.

## Implemented Repair

- Added `scripts/ambitions-process-preflight.sh` with:
  - `--status`, `--assert-clear`, and `--json`.
  - deterministic classification from `ps -axo pid=,ppid=,command=`.
  - exit codes for assert-clear: `0` clear, `86` blocked, `87` unknown.
  - optional stale lock cleanup/reporting.
  - runner-family expansion so sibling shell processes from the same active runner are not misclassified as external runner attempts.
- Wired supervisor preflight call to `scripts/ambitions-process-preflight.sh --assert-clear`.
- Replaced broad preflight in:
  - `prompts/_BATCH_FINALIZE_TEMPLATE.md`,
  - `prompts/batches/PK15-FINALIZE-01.md`
  with the shared helper and explicit helper behavior text.
- Added repair autopilot targets in `Makefile`:
  - `repair-status`,
  - `repair-next`,
  - `repair-current`.
- Updated runner self-check to verify helper presence, syntax, executable bit, `assert-clear` behavior, nested-run checks, path-limited staging, and no auto-push default regression.

## Avoiding Repeated Same-Root Failures

- `repair-next` resolves targets in deterministic order:
  1) unresolved finalization target from ledger,
  2) available `*-FINALIZE-01`,
  3) available `*-REPAIR-01`,
  4) queue-derived next batch fallback.
- `repair-current` only runs when the target name matches `*-FINALIZE-01` or `*-REPAIR-01`, and preflight is clear.

## Next Command

Expected next command once repair is clear:

```bash
ALLOW_DIRTY=1 ALLOW_MAIN_COMMIT=1 AUTO_BRANCH=0 make batch BATCH=PK15-FINALIZE-01 PROMPT=prompts/batches/PK15-FINALIZE-01.md
```
