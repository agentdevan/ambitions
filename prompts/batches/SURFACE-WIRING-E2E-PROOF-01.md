<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

SURFACE-WIRING-E2E-PROOF-01

## Objective

Install focused source/test proof for cross-surface wiring between Today, Goals, Capture, Time, You, persistence-backed services, and visible receipt/proof paths.

This is not a redesign batch. Prefer tests and tiny connector fixes over new UI.

## Active Source Truth To Inspect

- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/App/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/You/`
- `Native/Ambitions/Persistence/`
- `Native/AmbitionsTests/App/CoreSurfaceIntegrationScenarioTests.swift`
- `Native/AmbitionsTests/Today/`
- `Native/AmbitionsTests/Captures/`
- `Native/AmbitionsTests/Goals/`
- `Native/AmbitionsTests/Plan/`
- `Native/AmbitionsTests/You/`

## Allowed Scope

- Focused tests under `Native/AmbitionsTests/**`
- Minimal source fixes under `Native/Ambitions/App/**`, `Native/Ambitions/Services/**`, `Native/Ambitions/Features/**`, or `Native/Ambitions/Persistence/**` only when required by tests
- `docs/status/current-implementation-map.md` only for source-truth status correction

## Required Work

- Prove or improve one end-to-end path for Capture -> Goal/Time placement.
- Prove or improve one Today closure/proof receipt path.
- Prove or improve one You trust/history/defaults path connected to live services.
- Keep evidence scoped and conservative.

## Validation Expectations

- Focused unit/integration tests selected by the plan.
- `git diff --check`
- claim scan on changed docs/prompts if any.

## Forbidden Scope

- No broad app redesign.
- No new dependencies.
- No release/readiness claims.

## Runner Command

```bash
make batch BATCH=SURFACE-WIRING-E2E-PROOF-01 PROMPT=prompts/batches/SURFACE-WIRING-E2E-PROOF-01.md
```
