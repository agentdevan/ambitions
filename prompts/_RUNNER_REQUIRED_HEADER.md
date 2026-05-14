<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

This prompt must be run through `scripts/ambitions-codex-train.sh` so execution
uses:

GPT-5.5 plan -> GPT-5.4-mini bounded patch -> GPT-5.5
review/repair/final commit.

Direct pasted implementation remains forbidden unless the user explicitly says
`bypass the Ambitions runner.`
