<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-POST23-00-COMPLETION-SENTINEL

This runner batch is installed as the completion gate for the post-23 truth audit train.

Before doing any audit or repair, inspect the eligibility gate at:

`docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-ELIGIBILITY-GATE.md`

If the original 23-batch FE/BE train is not complete, stop and report Red without touching app source.

If the original 23-batch train is complete and the final integrated proof report is present, create the sentinel report at:

`docs/codex/reports/AMB-POST23-00-COMPLETION-SENTINEL.md`

Do not modify app source in this sentinel batch.
