# Ambitions Harness Slice 1

Status: supporting process index.
Scope: approved Harness Slice 1 foundation.
Authority: supporting only; repo truth remains `docs/truth/*`, `AGENTS.md`, source, tests, scripts, and current proof artifacts.

## Boundary

- Linear control plane.
- Repo docs, scripts, and prompts only.
- No app source changes.
- No `docs/truth/*` changes.

## Installed docs

- `docs/codex/HARNESS_README.md`
- `docs/codex/HARNESS_PLAN.md`
- `docs/codex/HARNESS_ARTIFACT_SCHEMA.md`
- `docs/codex/HARNESS_LINEAR.md`
- `docs/codex/HARNESS_RUNS.md`

## Installed scripts

- `scripts/harness/install-harness-slice1.py`
- `scripts/harness/check-slice1.py`
- `scripts/ambitions-slice1-status.py`

## Installed prompts

- `prompts/batches/HARNESS-T00-B01-baseline-audit.md`
- `prompts/batches/HARNESS-T01-B01-docs.md`

## Runner discipline

Use the Ambitions runner for serious work:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

Harness scripts support the runner; they do not replace it.
