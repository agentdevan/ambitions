# Eval / QA Layer

## Purpose

Add local scoring scaffolds for docs/tooling artifacts.

## Scripts

- `tools/openai/evals/run_evals.py`: validates dataset shape and prints execution plan.
- `tools/openai/evals/score_reports.py`: aggregates simple result JSON.

## Datasets

- `batch_quality.jsonl`
- `claim_safety.jsonl`
- `visual_canon.jsonl`

## Constraints

No live Evals API is called in this phase.

Run only dry-run and schema checks until a later batch enables opt-in provider execution.
