# Step Context-Fit Validator

Status: Active PLOS M09 context-fit validator contract
Issue: AMB-713 / PLOS-092
Parent: AMB-627 / PLOS-M09
Depends on: AMB-711 / PLOS-090 and AMB-712 / PLOS-091
Runtime implementation proof: none

## Purpose

The Step Context-Fit Validator is the runnable context gate for the Step Quality Firewall. It prevents a candidate Step from accepting when the copy is specific but the user's current time, energy, resources, location, deadline, or dependency state cannot safely support the Step.

This validator is a downstream-consumable contract and local validation harness. It does not wire production Swift runtime behavior or prove app behavior.

## Validator Inputs

The validator evaluates `StepQualityInput.contextFit`, while preserving the AMB-711 `StepQualityInput` and `StepQualityVerdict` contract.

Required context fields:

- `timeFit`
- `energyFit`
- `resourceFit`
- `locationFit`
- `deadlineFit`
- `dependencyFit`

Accepted values are `fit` or `bounded`. All other values block acceptance until the Step Graph Compiler repairs, shrinks, replaces, or routes to safe starter guidance.

## Blocking Codes

The validator emits deterministic StepQualityVerdict blocking codes:

- `context_time_mismatch`
- `context_energy_mismatch`
- `context_resource_mismatch`
- `context_location_mismatch`
- `context_deadline_mismatch`
- `context_dependency_mismatch`
- `context_repair_required`

The base `context_mismatch` code remains the aggregate firewall code. AMB-713 adds field-level codes that downstream M10/M13/M14 work can consume without guessing which context dimension failed.

## Fixture Contract

Context fixtures live in `artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR_FIXTURES.json`.

Accepted fixtures must prove:

- concrete Step copy already passes AMB-712 generic scanner rules
- all context dimensions are `fit` or `bounded`
- proof, accessibility, elasticity, and repair metadata remain present

Rejected fixtures must prove:

- unavailable time blocks acceptance
- overloaded energy blocks acceptance
- missing resources block acceptance
- unavailable location blocks acceptance
- deadline conflict blocks acceptance
- blocked dependency blocks acceptance
- every rejection maps to StepQualityVerdict blocking codes and compiler repair fallback

## Existing-First Source Ownership

AMB-713 inspected existing source ownership before extending the local validator contract:

- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift` already computes missing context, validity, tradeoffs, and candidate rejection records.
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift` owns candidate validity, tradeoff, rejection, source, proof, and elastic variant model seams.
- `Native/Ambitions/Runtime/StepReallocationRuntimeBridge.swift` owns future-pressure and reallocation context seams.
- `Native/Ambitions/Domain/ProjectStepOperationModels.swift` owns Step mutation impact and operation models.
- `Native/Ambitions/Domain/GoalEngine/GoalEnginePlannerLinter.swift` owns planner validation linting.

This contract does not duplicate those Swift owners. It provides a local runnable context-fit gate that downstream M09 children and AMB-617 / PLOS-M10 can consume until a production integration issue owns Swift wiring.

## Validation

Run:

```bash
python3 scripts/codex/step-quality-firewall-validate.py
```

The validator must print:

- `context_validator=artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR.json`
- `context_fixtures=artifacts/personal-life-os/step-quality/STEP_CONTEXT_FIT_VALIDATOR_FIXTURES.json`
- `context_fit_validator=runnable`

Red if a context-mismatched Step fixture accepts, if context fixtures are missing, if field-level context blocking codes are missing, or if the validator cannot support M10 runnable validation.

## No-Claim Boundary

AMB-713 does not claim app source changes, Swift/domain runtime implementation, production Step Quality Firewall wiring, UI behavior, accessibility certification, device proof, measured performance proof, R2 or Source Atlas publication, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, M09 parent completion, M10 Golden Slice readiness, or full PLOS completion.
