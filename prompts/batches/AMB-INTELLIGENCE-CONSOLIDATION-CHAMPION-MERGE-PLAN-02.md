<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-MERGE-PLAN-02

Batch type: guard-repair

Mission: install Champion Merge execution system after champion selection guard installation.

Allowed scope:

- `scripts/ambitions-champion-merge-planner.py`
- `scripts/ambitions-parallel-implementation-guard.py`
- `docs/codex/CHAMPION_MERGE_EXECUTION_PROTOCOL.md`
- `docs/codex/CHAMPION_MERGE_TRAIN_MANIFEST.yml`
- `docs/codex/CHAMPION_MERGE_RUNBOOK.md`
- `docs/codex/concept-lock-registry.yml`
- `docs/audits/intelligence-consolidation/CHAMPION_MERGE_QUEUE.md`
- `prompts/batches/champion-merge/**`
- `prompts/trains/ios26-flagship/TRAIN_04L_CHAMPION_MERGE_AND_INTELLIGENCE_CONSOLIDATION.md`
- `build/reports/intelligence-consolidation/champion-merge-plan.*`
- `build/reports/parallel-implementation-guard/*CHAMPION-MERGE-PLAN-02*`

Accepted Yellow boundary:

- owner: Ambitions repo/process owner
- reason: Champion Merge planner creates initial locks and queue from bootstrap ledgers; source merge is deferred to dedicated batches
- no-claim boundary: does not merge source, does not delete duplicates, does not prove runtime consolidation
- follow-up gate: run Champion Merge queue batches before feature trains touching locked concepts
- canonical owner affected: all locked concepts in `docs/codex/concept-lock-registry.yml`

Required outcome:

- Champion Merge protocol installed
- merge queue generated
- concept lock registry generated
- planner script installed
- merge train/runbook/prompts installed
- parallel guard reads concept locks

STATUS: YELLOW
