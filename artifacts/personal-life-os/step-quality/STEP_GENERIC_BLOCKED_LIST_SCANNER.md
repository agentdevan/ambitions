# Step Generic Blocked-List Scanner

Status: Active PLOS M09 scanner contract
Issue: AMB-712 / PLOS-091
Parent: AMB-627 / PLOS-M09
Depends on: AMB-711 / PLOS-090 Step Quality Firewall contract
Runtime implementation proof: none

## Purpose

The Step Generic Blocked-List Scanner is the runnable scanner surface for the Step Quality Firewall's non-generic language check. It blocks candidate Step copy that can pass superficial field checks while still reading like a generic task, vague productivity prompt, or uninspectable action.

This scanner is a downstream-consumable contract and validation harness. It does not wire production Swift runtime behavior or prove app behavior.

## Scanner Inputs

The scanner evaluates `StepQualityInput.stepText` and emits deterministic blocking codes that feed `StepQualityVerdict.blockingCodes`.

Required linkage:

- `generic_step`: exact or normalized blocked phrase.
- `generic_pattern`: vague verb plus generic object or pronoun.
- `generic_progress_language`: progress/improvement language without a concrete artifact, source, proof, or action object.
- `generic_repair_required`: repair route must name Step Graph Compiler repair and a safe fallback.

## Blocked Exact Phrases

The scanner inherits the AMB-711 baseline list and adds normalized variants that must remain blocked:

- work on your goal
- make progress
- make progress on your goal
- research this
- review your plan
- continue
- continue your plan
- do the next thing
- try to improve
- keep going
- make a plan
- work on it

Exact phrase matching is case-insensitive, whitespace-normalized, and punctuation-tolerant.

## Generic Pattern Rules

The scanner must reject:

- vague verbs paired with generic objects: work on, make progress, continue, handle, deal with, improve, research, review, make
- generic objects or pronouns: it, this, that, your goal, the goal, your plan, the plan, the next thing, everything
- progress language without a concrete artifact: progress, improve, advance, move forward
- single-word command copy that has no concrete action object, such as `Continue`

The scanner must not reject concrete Step copy solely because it contains a common verb. A Step such as `Review the three signed source notes and mark the stale one for repair.` is valid scanner-level copy because it names a concrete object and outcome.

## Fixture Contract

Scanner fixtures live in `artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER_FIXTURES.json`.

Accepted fixtures must prove:

- concrete action and object
- no exact blocked phrase
- no vague verb plus generic object
- no generic progress language without a concrete output
- repair metadata can remain present without turning accepted copy into a reject

Rejected fixtures must prove:

- exact baseline phrase is blocked
- case and whitespace normalization are enforced
- punctuation does not bypass the list
- generic pronoun/object variants are blocked
- progress/improvement language without a concrete object is blocked
- each rejection maps to StepQualityVerdict blocking codes and compiler repair fallback

## Existing-First Source Ownership

AMB-712 inspected the existing Swift seams before extending the local scanner contract:

- `Native/Ambitions/Domain/GoalEngine/GoalEngineStepRewriter.swift` already owns vague Step rewrite detection in planning code.
- `Native/Ambitions/Domain/GoalEngine/GoalEnginePlannerLinter.swift` already maps vague Step copy to planner lint defects.
- `Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift` already has a `vague_step` code.
- `Native/Ambitions/Domain/GoalEngine/StepCandidateFieldModels.swift` owns `StepCandidateRejectionRecord`.
- `Native/Ambitions/Runtime/StepCandidateFieldGenerator.swift` owns candidate validity and rejection history.

This contract does not duplicate those Swift owners. It provides a local runnable gate that downstream M09 children and AMB-617 / PLOS-M10 can consume until the production integration issue owns Swift wiring.

## Validation

Run:

```bash
python3 scripts/codex/step-quality-firewall-validate.py
```

The validator must print:

- `scanner=artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER.json`
- `scanner_fixtures=artifacts/personal-life-os/step-quality/STEP_GENERIC_BLOCKED_LIST_SCANNER_FIXTURES.json`
- `generic_scanner=runnable`

Red if a generic Step fixture accepts, if scanner fixtures are missing, if the scanner has no StepQualityVerdict linkage, or if the scanner cannot support M10 runnable validation.

## No-Claim Boundary

AMB-712 does not claim app source changes, Swift/domain runtime implementation, production Step Quality Firewall wiring, UI behavior, accessibility certification, device proof, measured performance proof, R2 or Source Atlas publication, privacy/legal approval, release readiness, TestFlight readiness, App Store readiness, M09 parent completion, M10 Golden Slice readiness, or full PLOS completion.
