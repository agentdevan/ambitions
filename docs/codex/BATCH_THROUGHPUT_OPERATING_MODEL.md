# Batch Throughput Operating Model

## Purpose

This is a Codex OS operating model for speeding safe queue movement while preserving
source-truth discipline and proof honesty. It exists for non-product batch infrastructure work.

## Fastest-safe model

1. **One canonical write lane**
   - `GPT-5.5` (plan/decision/review/final gate) executes through `make batch`.
2. **Many read-only prep lanes**
   - Spark/mini/unknown-tier model work is limited to prep notes, classification,
     validation routing, and deterministic script-assisted reporting.
3. **Spark bounded execution**
   - `GPT-5.5` approves every hard decision.
4. **Repair desk ownership**
   - Non-Green outcomes route to repair/finalization as repair prompts only.
5. **No run-time feature drift**
   - This model owns no product behavior changes.

## Exact command flow

```bash
git pull --ff-only
git status --short --branch
make batch-self-check
make prompt-audit
make autonomous-train-status
make autonomous-train-next
make autonomous-train-run-current
make autonomous-train
make repair-status
make repair-next
make repair-current
```

## Batch execution command policy

- Standard run:
  - `make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md`
- Review or staging-safe draft:
  - `make batch-no-commit BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md`
- Explicit push by owner only:
  - `AUTO_PUSH=1 make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md`

Auto-push is discouraged until several clean eligible batches close consecutively with no
new unresolved continuation gates in active state.

## Model and lane boundary

- GPT-5.5 owns planning, source-truth judgment, canonical proof interpretation,
  and final commit eligibility.
- Spark implements only the bounded patch requested by an approved Phase 01 boundary.
- All runners, autonomous commands, repair lanes, and queue tooling remain read-only
  unless in the approved batch command lane.
- EFC, queue truth, and current-state posture are never relaxed to improve throughput.

## Continuation

- If next executable batch is now known, lane choice comes from queue truth and active
  train state (not stale memoized status).
- If PK/other command files are missing or stale, prep notes must remain candidate-only
  and cannot be used for implementation decisions.

