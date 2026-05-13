# Owned File Stager Skill

Status: Active speed skill  
Purpose: Stage only files owned by the active batch during autonomous train execution.

## Use when

Use after every batch run before commit/push.

## Fast command

```bash
python3 scripts/ambitions-owned-files-detector.py --batch <BATCH_ID> --print-git-add
```

For full classification:

```bash
python3 scripts/ambitions-owned-files-detector.py --batch <BATCH_ID> --json
```

## Default staging rule

Stage only:

```text
owned_by_current_batch
report_or_proof
```

Do not auto-stage support/governance files unless the active batch explicitly owns them.

## Never stage by default

```text
.codex/runs/**
.codex/DerivedData/**
.codex/xcode-results/**
.codex/xcode-logs/**
.codex/xcode-summaries/**
unknown external dirty files
forbidden package/project/signing/entitlement files
unrelated generated artifacts
```

## Procedure

1. Run the detector.
2. Inspect `requires_operator_review`.
3. Stage default-safe paths only.
4. If anything is external or forbidden, classify before continuing.
5. Never use broad `git add .` in autonomous train mode.

## Claim boundary

This skill classifies staging risk only. It does not prove file ownership, validation, or release readiness.
