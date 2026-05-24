# Champion Merge Runbook

Status: Installed, not run.

Run after `AMB-INTELLIGENCE-CONSOLIDATION-CHAMPION-SELECTION-01` and before feature trains that touch locked duplicate concepts.

```bash
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-OWNER-REVIEW-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-OWNER-REVIEW-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-TODAY-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TODAY-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-CAPTURE-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-CAPTURE-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-RUNTIME-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-RUNTIME-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-PROOF-RECEIPT-REPLAY-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-PROOF-RECEIPT-REPLAY-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-TIME-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-TIME-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-GOALS-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-GOALS-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-YOU-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-YOU-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-DESIGN-SYSTEM-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-DESIGN-SYSTEM-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-PERSISTENCE-EXTERNAL-SURFACES-01.md
scripts/ambitions-codex-train.sh AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01 prompts/batches/champion-merge/AMB-CHAMPION-MERGE-QUARANTINE-PLAN-01.md
```

Stop on Red. Continue on Yellow only with owner, reason, no-claim boundary, follow-up gate, affected canonical owner, and ledger update.
