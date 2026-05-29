<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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

## Source-of-truth references

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: BEGIN -->

This file must not be treated as standalone active canon. Current authority must be resolved through:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`
- `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`
- `docs/ops/change-protocol/change-request-template.md`
- `docs/ops/change-protocol/change-impact-check.md`
- `docs/ops/change-protocol/implementation-prompt-template.md`
- `docs/ops/change-protocol/post-implementation-proof-reconciliation.md`

<!-- AMB-291-SOURCE-OF-TRUTH-REFERENCES: END -->

## Non-claims

<!-- AMB-291-NON-CLAIMS: BEGIN -->

- This file does not prove implementation.
- This file does not prove build success.
- This file does not prove test success.
- This file does not prove accessibility validation.
- This file does not prove performance validation.
- This file does not prove device validation.
- This file does not prove privacy/legal approval.
- This file does not prove TestFlight readiness.
- This file does not prove App Store readiness.
- This file does not prove release readiness.
- Linear status is not repo truth.

<!-- AMB-291-NON-CLAIMS: END -->
