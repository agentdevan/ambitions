# Global Train Attempt Ledger
# Scope: compact conductor-loop safety state (best-effort history)

- parent_batch_id: RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION
  parent_run_id: 20260510T072129Z
  child_batch_id: PK14
  attempt_count: 1
  status: YELLOW
  proof_path: .codex/runs/PK14/20260510T073722Z/final-summary.md
  next_action: emit-repair
  retry_allowed: false
  note: historical failed attempt; does not authorize parent re-run

- parent_batch_id: RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION
  parent_run_id: 20260510T072129Z
  child_batch_id: PK14
  attempt_count: 2
  status: RED
  proof_path: .codex/runs/PK14/20260510T074120Z/final-summary.md
  next_action: emit-repair
  retry_allowed: false
  note: historical failed attempt; does not authorize parent re-run

- parent_batch_id: PK14-CONDUCTOR-REPAIR-01
  parent_run_id: 20260510T132524Z
  child_batch_id: PK14
  attempt_count: 0
  status: prepared_clean_attempt
  proof_path: prompts/batches/PK14.md
  next_action: run_once_after_repair_commit
  retry_allowed: true
  note: one clean future PK14 attempt is allowed through the PK14 runner prompt only; do not run the global conductor first
