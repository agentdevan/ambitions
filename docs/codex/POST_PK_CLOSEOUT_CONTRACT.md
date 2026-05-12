# Post-PK Closeout Contract

Status: active after PK41  
Authority: supporting process contract

## Contract

Every post-PK batch should close in one eligible commit whenever practical:

1. implementation / docs / prompt changes,
2. focused tests or proof-light evidence,
3. closeout report,
4. state advancement,
5. queue advancement,
6. next-batch handoff.

## Required Closeout Fields

Closeout reports must include:

- status (`Green`, `Accepted Yellow`, or `installed_unverified`),
- source truth inspected,
- files changed,
- validation commands and exit codes,
- EFC applicability,
- claims not made,
- rollback notes,
- next handoff.

## State Advancement

Use:

```bash
python3 scripts/ambitions-advance-batch-state.py --completed <BATCH> --next <NEXT> --status <green|accepted_yellow|installed_unverified> --commit <SHA> --report <REPORT> --write
python3 scripts/ambitions-state-advance-validate.py
```

## Coalescing Commit

Use:

```bash
python3 scripts/ambitions-closeout-coalesce.py --batch <BATCH>
python3 scripts/ambitions-closeout-coalesce.py --batch <BATCH> --stage
```

Only stage after scope review.

## Rule

Do not finish a batch unless the next executable batch is already set.
