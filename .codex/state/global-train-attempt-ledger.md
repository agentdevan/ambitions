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
  attempt_count: 1
  status: consumed_clean_attempt_green
  proof_path: .codex/runs/PK14/20260510T134429Z/final/03-review.final.md
  next_action: global_conductor_allowed_after_pk14_state_reconciliation
  retry_allowed: false
  note: clean PK14 attempt completed Green and commit e923189db05914ee69d7f4ddc3aa493689daa565 was pushed; do not rerun PK14 from the global conductor

- parent_batch_id: RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION
  parent_run_id: 20260510T145852Z
  child_batch_id: PK15
  attempt_count: 2
  status: aborted_conductor_loop_guard_red
  proof_path: .codex/runs/RUN-GLOBAL-BATCH-TRAIN-TO-COMPLETION/20260510T145852Z/
  next_action: run_pk15_from_top_level_after_nested_runner_guard
  retry_allowed: false
  note: parent Spark phase launched PK15 twice and both run statuses remained UNKNOWN; processes were stopped before tracked source mutation. These are not clean PK15 implementation attempts and must not authorize further nested conductor retries.
