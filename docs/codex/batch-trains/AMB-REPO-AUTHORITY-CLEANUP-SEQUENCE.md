# AMB Repo Authority Cleanup Sequence

Status: Installed control sequence.

Preferred runner: `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL`.

## Top-level sequence

1. `AMB-REPO-AUTHORITY-CLEANUP-INSTALL-00`
2. `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL`

## Internal RUN-ALL phases

0. `AMB-REPO-AUTHORITY-00-SAFETY-SNAPSHOT`
1. `AMB-REPO-AUTHORITY-01-FRONT-DOOR-PORTALS`
2. `AMB-REPO-AUTHORITY-02-FRONTEND-VISUAL-ENCYCLOPEDIA`
3. `AMB-REPO-AUTHORITY-03-BACKEND-HONESTY`
4. `AMB-REPO-AUTHORITY-04-CODEX-OS-CONSOLIDATION`
5. `AMB-REPO-AUTHORITY-05-HISTORICAL-ARCHIVE-MIGRATION`
6. `AMB-REPO-AUTHORITY-06-ACTIVE-DRIFT-REPAIR`
7. `AMB-REPO-AUTHORITY-07-GATES-FINAL-PROOF`

## Execution rule

Run `AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL` unless replaying a specific failed phase.

```bash
make batch BATCH=AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL PROMPT=prompts/batches/AMB-REPO-AUTHORITY-CLEANUP-RUN-ALL.md
```

No phase may proceed unless the prior phase is GREEN.

YELLOW is report-only and may not permit continuation.

RED stops the train immediately.

## Replay rule

Individual phase prompts are for repair/replay only after a RED stop or for focused audit. They must preserve the same hard-green contract.
