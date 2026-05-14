# Batch Prep Notes

This directory stores read-only prep notes used by throughput lanes.

## Purpose

Prep notes support GPT-5.4-mini/unknown-tier preparation lanes by capturing candidate
scope, evidence pointers, risks, and fast-lane validation hints without implementation.

## Current seeded notes

- `PK16.md`
- `PK17.md`
- `PK18.md`
- `PK19.md`
- `PK20.md`
- `PK21.md`
- `PK22.md`
- `PK23.md`
- `PK24.md`
- `PK25.md`

## How to use

- GPT-5.4-mini/unknown-tier models should read these notes before bounded patch generation.
- Missing prompt files are valid; they must be marked `Prompt availability: missing` and kept candidate-only.
- Candidates do not authorize implementation.
- Route to the canonical runner lane for execution through:

```bash
make batch BATCH=<BATCH_ID> PROMPT=prompts/batches/<BATCH_ID>.md
```

## Tooling

- `scripts/ambitions-batch-lane-classifier.py`
- `scripts/ambitions-batch-prep-scaffold.py`
- `scripts/ambitions-throughput-plan.sh`
- `scripts/ambitions-known-yellow-scan.sh`

## Scope discipline

- Do not rewrite product strategy, IA, route/raw-value definitions, production
  claims, release posture, or proof boundaries from this folder.
- Keep each prep note deterministic and bounded to available evidence.

