<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# Batch ID

PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01

## Objective

Install the smallest meaningful proof slice for the Private Life Runtime target: same intent plus different local context produces different inspectable daily execution behavior with relaunch/persistence boundaries identified honestly.

This batch may add focused tests and minimal deterministic fixture/projector code only where current source already has the seam.

## Active Source Truth To Inspect

- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/runtime/PRIVATE_LIFE_RUNTIME_PROOF_SPEC.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `Native/Ambitions/Runtime/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Domain/`
- `Native/AmbitionsTests/Runtime/`
- `Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift`

## Allowed Scope

- `Native/Ambitions/Runtime/**`
- `Native/Ambitions/Services/**`
- `Native/Ambitions/Domain/**`
- `Native/AmbitionsTests/Runtime/**`
- `Native/AmbitionsTests/Domain/**`
- `docs/status/current-implementation-map.md` only for non-claim status correction if tests expose proof limits

## Required Work

- Add or repair focused golden scenario tests for same intent / different context behavior.
- Keep runtime deterministic, local-first, inspectable, and non-cloud.
- Do not claim the full Private Life Runtime is complete unless test evidence actually proves the full proof spec.

## Validation Expectations

- Focused Swift tests selected by the plan, preferably around runtime/domain golden scenarios.
- `git diff --check`
- `scripts/codex-forbidden-claim-scan.sh <changed files>` where applicable

## Forbidden Scope

- No external LLM/cloud/provider dependency.
- No hosted backend or account system.
- No release/readiness claims.
- No broad UI redesign.

## Runner Command

```bash
make batch BATCH=PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01 PROMPT=prompts/batches/PRIVATE-LIFE-RUNTIME-GOLDEN-SCENARIO-PROOF-01.md
```
