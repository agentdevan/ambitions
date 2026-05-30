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
- `docs/codex/HARNESS_SCORECARD.md`

## Installed scripts

- `scripts/harness/install-harness-slice1.py`
- `scripts/harness/check-slice1.py`
- `scripts/ambitions-slice1-status.py`
- `scripts/harness/ambitions-artifact-helper.py`
- `scripts/harness/ambitions-proof-wrapper.sh`
- `scripts/harness/ambitions-static-gates.py`

## Installed prompts

- `prompts/batches/HARNESS-T00-B01-baseline-audit.md`
- `prompts/batches/HARNESS-T01-B01-docs.md`
- `prompts/batches/IOS26-HARNESS-T02-B01-artifact-proof-wrapper-static-gates.md`
- `prompts/batches/IOS26-HARNESS-T02-B02-first-proof-wrapper-run.md`

## Artifact root

Harness inventory and gate outputs for this slice live under:

```text
build/reports/harness/<batch-id>/<utc-timestamp>/
```

The wrapper is inventory-only by default and does not claim app build, test, device, accessibility, performance, or release proof.

## Runner discipline

Use the Ambitions runner for serious work:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

Harness scripts support the runner; they do not replace it.

## Status notes

- This is a support-only install.
- No app source changed in this slice.
- No `docs/truth/*` file changed in this slice.
- Proof and gate artifacts are local support evidence, not release proof.
