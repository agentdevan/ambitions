<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-006 - Scenario Mutation Lab

## Batch ID

AFEP-006

## Linear Issue

AMB-400 - AFEP-006 - Scenario Mutation Lab

## Objective

Stress-test recommendation sensitivity and resilience with deterministic mutation fixtures. Perturb context variables, compare outputs and explanations, flag unstable decision shifts, and store a mutation lab report.

## Active Source Truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- Live source, tests, and current wrapper logs beat stale docs or old batch claims.

## Required Actions

- Add deterministic mutation fixture models for recommendation/context perturbations.
- Compare selected recommendation outputs and AFEP-005 explanation/counterfactual graph facts across mutation variants.
- Flag unstable decision shifts when explanation deltas are missing, non-deterministic, or not bounded by the mutated context.
- Preserve explicit SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows inspection seams in every mutation fixture or report row that references recommendation provenance.
- Store a mutation lab report under `build/reports/afep/AFEP-006/`.
- Preserve AFRI same-intent/different-context proof as the rollback base if new mutation coverage is unstable.

## Acceptance Gates

- Sensitivity is intentional and bounded.
- Mutation fixtures identify why a recommendation changed or why it stayed stable.
- Explanations remain deterministic and inspectable.
- You / What Ambitions knows inspection can tell which SourceRecord and ReplayTrace inputs made a mutation result trustworthy, stale, or review-required.
- No mutation path mutates user data silently.

## Allowed Scope

- Existing canonical recommendation, planning, replay/proof, and local fixture owners in `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, and focused tests under `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-006/`.
- This prompt and concept-lock allowlist entries only if the guard requires explicit AFEP-006 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel recommendation engine, planner, runtime, proof/receipt/replay path, or user-profile owner.
- Do not add cloud AI, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not revive `Plan` as a user-facing top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not modify user data, schedule/calendar data, reminders, or persistence outside deterministic fixtures.
- Do not claim release, device, accessibility, performance, privacy/legal, CI, TestFlight, App Store, or broad full-suite proof.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-006`.
- Run focused test lanes for the mutation lab and any changed owner tests.
- Run `git diff --check`.
- If the broad `AmbitionsTests` lane is attempted, record any existing out-of-scope failures honestly as Yellow unless they are introduced by this batch.

## Proof Artifacts

- `build/reports/afep/AFEP-006/mutation-lab-report.md`

## Rollback / Failure Behavior

Keep the AFRI same-intent/different-context suite as the base if mutation coverage is unstable. On Red, stop with the smallest safe repair rather than widening into broad runtime cleanup.

## Hard Red

- Unexplained instability in recommendation output.
- Mutation fixtures that silently mutate user data.
- Non-deterministic recommendation or explanation behavior.
- Opaque AI confidence framing.
- Required cloud AI, backend, analytics, tracking, or hosted inference.
- New parallel runtime/recommendation/planning/proof owner.
- Release or full-suite proof claims without current evidence.
