# PK14 Conductor Repair Report

## Diagnosis Questions

1. Did the parent conductor invoke nested child runner processes?
   - Yes. The PK14 child prompt used a `Child Runner Command` block that called `scripts/ambitions-codex-train.sh PK14 prompts/batches/PK14.md`, creating nested runner execution under the global parent run.

2. Did `RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION` allow more than one PK14 attempt without a fresh human/Green gate?
   - Yes. Evidence shows two PK14 run attempts were executed (`.codex/runs/PK14/20260510T073722Z` and `.codex/runs/PK14/20260510T074120Z`) with no completed PK14 Green boundary and no manual gate between them.

3. Did the parent confuse Yellow, Red, accepted Yellow, and retryable Red?
   - Yes. The first PK14 attempt exited YELLOW with parent-loop continuation intent (`KEEP_GOING_ON_YELLOW=0`) and the second exited RED with a tracked dirty-worktree issue, but parent behavior treated these as retryable retry points instead of requiring explicit repair handoff.

4. Did the PK14 prompt itself cause recursive calls back into the global train?
   - Yes. `prompts/batches/PK14.md` contained a `Child Runner Command` instructing direct execution of PK14 via `scripts/ambitions-codex-train.sh`, which is recursive in practice when launched from within the global conductor.

5. Did `PK14.md` exist before the run, or was it generated during the failed parent run?
   - It was generated during the failed run sequence; `git ls-files prompts/batches/PK14.md` returned no tracked file and `git status` showed `?? prompts/batches/PK14.md`.

6. Was PK14 Yellow due to implementation risk, validation unavailable, missing acceptance criteria, or runner/conductor loop behavior?
   - Mixed but loop-bound and governance-driven: first failure was runner/plan gating (`KEEP_GOING_ON_YELLOW` path and non-committal status), and second was conductor-level dirty-worktree Hard-Red enforcement. Not a clean “implementation-only” failure.

7. What exact loop guard must be added before another global run?
   - A parent-only one-attempt-per-batch ledger check:
     1. before launching any child batch, check an attempt ledger key `(parent, child)`;
     2. block launch if any previous attempt exists and is not Green;
     3. require an explicit `<child>-REPAIR-01` handoff on first failure;
     4. never self-reinvoke the same batch from within parent/child prompts.

## Root Cause

The failure was a prompt-governance recursion defect: `PK14.md` carried executable child-rerun instructions while the parent run logic did not enforce a durable one-attempt-per-batch conductor lock. This produced uncontrolled repeated PK14 attempts and bypassed explicit repair/boundary handoff.

## Repair Chosen

- Add conductor guard language in `prompts/batches/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION.md`:
  - consult an attempt ledger,
  - block re-entry for failed/non-green child attempts,
  - emit repair prompts only.
- Replace `prompts/batches/PK14.md` with a single-attempt-safe prompt with no recursive `make batch` or global-train invocation.
- Add `.codex/state/global-train-attempt-ledger.md` to persist parent-child attempt state and retry-allowed policy.
- Add `prompts/batches/PK14-REPAIR-01.md` as the bounded repair target.

## Phase 04 Repair Pass 1

- Tightened the conductor ledger rule to apply to the current parent pass/run so
  historical failed PK14 attempts remain evidence without permanently blocking a
  separately approved clean PK14 attempt.
- Repaired `prompts/batches/PK14.md` so it remains single-attempt safe while
  allowing only the GPT-5.5-approved PK14 source/test boundary needed for a real
  Durable Command/Event Ledger implementation attempt.
- Updated `.codex/state/global-train-attempt-ledger.md` with `parent_run_id`
  evidence and a prepared clean-attempt entry for this repair batch.

## Evidence Artifacts

- `.codex/runs/PK14/20260510T073722Z/final-summary.md`
- `.codex/runs/PK14/20260510T074120Z/final-summary.md`
- `.codex/runs/PK14/20260510T073722Z/final/01-plan.final.md`
- `.codex/runs/PK14/20260510T074120Z/final/01-plan.final.md`
- `.codex/runs/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION/20260510T072129Z/runner-status.env`
