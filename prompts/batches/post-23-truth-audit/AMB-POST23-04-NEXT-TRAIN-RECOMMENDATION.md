<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION

This runner batch recommends the next train after the post-23 truth audit, repair, and authority cleanup.

Use these repo OS files as controlling instructions:

- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-MANIFEST.md`
- `docs/codex/batch-trains/post-23-truth-audit/AMB-POST23-TRUTH-AUDIT-REPAIR-ROUTING.md`
- `docs/codex/reports/AMB-POST23-01-TRUTH-AUDIT.md`
- `docs/codex/reports/AMB-POST23-02-UNDERDELIVERY-REPAIR.md`
- `docs/codex/reports/AMB-POST23-03-AUTHORITY-CLEANUP-AND-ROUTING.md`

Default recommendation order is UI Suite, Backend Flagship, Frontend Flagship, Apple continuity/durability proof if not covered, then launch-believability/closed beta readiness. Override this order only when evidence requires it.

Required output:

`docs/codex/reports/AMB-POST23-04-NEXT-TRAIN-RECOMMENDATION.md`
