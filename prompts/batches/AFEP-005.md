<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-005 - Planner Explanation and Counterfactual Graph

Linear issue: AMB-399
Linear project: Ambitions Flagship Elevation Program
Milestone: Decision and Experience Semantics

## Required Truth And Predecessor Checks

Read these before editing:

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `project.yml`
- `Package.swift`
- `prompts/batches/AFEP-001.md`
- `prompts/batches/AFEP-002.md`
- `prompts/batches/AFEP-003.md`
- `prompts/batches/AFEP-004.md`
- AFEP-001 through AFEP-004 source, tests, commits, and proof reports
- relevant planner, recommendation, proof, receipt, runtime snapshot, SourceRecord, ReplayTrace, policy override, and explanation owner files

Confirm AFEP-001 through AFEP-004 are locally Green before source edits. Do not modify, split, rename, or rewrite AFRI-000 through AFRI-040.

## Purpose

Make recommendations explainable against deterministic alternatives so Ambitions can answer why this step was recommended instead of another without opaque AI framing, cloud inference, shame, urgency, or non-deterministic confidence language.

## Product And Architecture Boundaries

- Preserve canonical IA: Today / Goals / Capture / Time / You.
- Preserve primary objects: Reality Meridian, Constellation Atlas, Atmosphere Composer, LifeShape Field, User System Profile.
- Preserve local-first Private Life Runtime as core architecture.
- Do not add cloud AI, hosted inference, analytics SDKs, backend accounts, custom server infrastructure, hosted CI, signing automation, or paid services.
- Do not claim release readiness, accessibility verification, performance verification, device proof, TestFlight readiness, App Store readiness, privacy/legal approval, or CI proof unless current evidence exists.
- Explanations must be deterministic, source-backed, inspectable, and testable.
- Confidence must be a local deterministic fit/uncertainty model, not opaque AI confidence or model probability theater.
- Counterfactuals must preserve explicit `SourceRecord`, `Receipt`, and `ReplayTrace` boundaries and must not create a parallel recommendation/planner owner.
- Policy override hooks must be explicit, reversible, and receipt/proof aware; no silent plan mutation.
- Any touched explanation, policy override, proof, or runtime learning path must remain inspectable through You / What Ambitions knows.
- Recommendation language must use `Recommended step`, `step`, `Start now`, and `Open step` where user-facing copy is touched.

## Implementation Scope

Implement the smallest source-backed planner explanation and counterfactual graph layer that satisfies AMB-399:

1. Add a deterministic reason graph for recommendation decisions.
2. Add a local confidence/fit model without opaque AI framing.
3. Add counterfactual diff records that explain why an alternative was not selected.
4. Add policy override hooks that remain inspectable and receipt/proof aware.
5. Add golden explanation cases that prove deterministic explanation output.

Prefer existing owner seams and names over new broad architecture. Extend current domain, runtime, proof, persistence, support, test, and proof-report owners where appropriate:

- `Native/Ambitions/Domain/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Features/Today/` only if needed for an existing recommendation inspection seam
- `Native/Ambitions/Features/You/` only if needed for an existing inspection/control seam
- `Native/AmbitionsTests/`
- proof/report files under `build/reports/afep/AFEP-005/` or an equally scoped existing proof root

## Acceptance Gates

- Recommendations can explain why this instead of that.
- Explanation output is deterministic across golden cases.
- Counterfactual diffs are source-backed and preserve privacy/export boundaries.
- Confidence/fit language is local and inspectable, with no opaque AI framing.
- Policy override hooks are explicit and reversible, with receipt/proof boundaries.
- No parallel planner, recommendation, receipt, SourceRecord, ReplayTrace, or proof owner is introduced.

## Validation Commands

Run the tightest relevant commands first, then repair failures:

```bash
xcodegen generate
make xcode-build-for-testing BATCH=AFEP-005
make xcode-focused-test BATCH=AFEP-005 TEST=AmbitionsTests
```

If a broad `AmbitionsTests` lane is too slow or blocked, run focused tests for the new AFEP planner explanation, reason graph, counterfactual, policy override, and golden explanation cases and clearly record the unrun broader lane as Yellow, not Green.

## Required Proof Artifacts

Create or update current artifacts for:

- Golden explanation pack
- Counterfactual diff report

Each artifact must include branch, commit if available, date/time, command names, pass/fail/skipped state, known Yellow items, rollback notes, and non-claims.

## Green / Yellow / Red Expectations

Green: deterministic explanations match golden cases and counterfactuals, source/proof boundaries are preserved, and local wrapper evidence is current.

Yellow: explanation layer is behind an adapter with no claim of full recommendation coverage, plus owner, follow-up gate, and no release/performance/privacy overclaim.

Red: opaque confidence, cloud AI dependency, non-deterministic recommendations, parallel planner/recommendation owner, private metadata leakage, canonical IA drift, or release/accessibility/privacy/performance claims exceed evidence.

## Closeout Requirements

Closeout must include:

- Files changed
- Why the change was needed
- Truth files inspected
- Validation run and exact commands
- Validation not run and why
- Proof/claim boundaries
- Risks or Yellow items
- Rollback notes
- Linear issue status recommendation for AMB-399
