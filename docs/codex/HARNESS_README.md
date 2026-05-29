# Ambitions Harness Slice 1

Status: supporting process index.
Scope: approved Harness Slice 1 foundation.
Authority: supporting only; repo truth remains `docs/truth/*`, `AGENTS.md`, source, tests, scripts, and current proof artifacts.

## Approved boundary

- Linear control plane.
- Repo docs, scripts, and prompts only.
- No app source changes.
- No `docs/truth/*` changes.
- No public-distribution, device, accessibility, performance, or release-readiness claim.

## Installed docs

- `docs/codex/HARNESS_10_10_PLAN.md`
- `docs/codex/HARNESS_ARTIFACT_SCHEMA.md`
- `docs/codex/HARNESS_LINEAR_PROTOCOL.md`
- `docs/codex/HARNESS_MANUAL_RUNNER_PROTOCOL.md`
- `docs/codex/HARNESS_SCORECARD.md`

## Installed scripts

- `scripts/harness/install-harness-slice1.py`
- `scripts/harness/ambitions-artifact-manifest.py`
- `scripts/harness/ambitions-proof-baseline.sh`
- `scripts/harness/ambitions-xcresult-summary.py`
- `scripts/harness/ambitions-product-language-gate.py`
- `scripts/harness/ambitions-ia-gate.py`
- `scripts/harness/ambitions-local-only-gate.py`
- `scripts/harness/ambitions-architecture-gate.py`
- `scripts/harness/ambitions-claim-discipline-gate.py`

## Runner discipline

Use the Ambitions runner for serious work:

```bash
scripts/ambitions-codex-train.sh <BATCH_ID> <PROMPT_FILE>
```

Harness scripts support the runner; they do not replace it.
