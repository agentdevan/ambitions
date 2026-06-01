<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# AFEP-013 - Time Field Pressure Engine

## Batch ID

AFEP-013

## Linear Issue

AMB-407 - AFEP-013 - Time Field Pressure Engine

## Objective

Deepen Time as LifeShape Field with deterministic pressure, protected-time, capacity, and proof-opportunity projections while keeping Time local-first, inspectable, non-shaming, accessible, and rollback-safe.

## Active Source Truth

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- Live source, tests, runner guard reports, and current wrapper logs beat stale docs or old batch claims.

## Required Actions

- Keep Time -> LifeShape Field mapping unchanged.
- Preserve Time as time-reality and LifeShape, not a generic calendar clone.
- Add deterministic pressure engine inputs and projections for schedule pressure, protected time, capacity, and proof opportunity.
- Add provenance and privacy classes for schedule and capacity fields.
- Add accessibility-safe render equivalents for VoiceOver, Dynamic Type, Reduce Motion, and non-color-only review.
- Preserve local-only operation and rollback to AFRI Time routes when pressure, privacy, accessibility, or provenance evidence fails.
- Store the Time pressure packet, screenshot/accessibility packet, and state restoration/continuation test report under `build/reports/afep/AFEP-013/`.

## Acceptance Gates

- Time does not become a calendar clone, task grid, generic command panel, or gamified rating surface.
- Pressure is explainable, local, deterministic, and non-shaming.
- Protected time and capacity remain inspectable with privacy labels and user-owned controls.
- Proof opportunity projections explain what may count as proof without silently mutating goals, steps, receipts, or schedules.
- User-facing language stays canonical: `Time`, `LifeShape Field`, `protected time`, `capacity`, `proof`, `receipt`, `SourceRecord`, `ReplayTrace`, `Start here`, `Recommended step`, `Open step`, and `step`.
- No source path claims screenshot, accessibility conformance, privacy/legal approval, release readiness, device proof, TestFlight/App Store readiness, CI proof, or full-suite proof without current evidence.

## Allowed Scope

- Existing canonical Time, LifeShape, schedule, availability, protected-time, capacity, proof-opportunity, privacy/export, accessibility, design-system, Today/Start Here receipt, You inspection, and focused test owners under `Native/Ambitions/Domain`, `Native/Ambitions/Runtime`, `Native/Ambitions/Services`, `Native/Ambitions/Features/Plan`, `Native/Ambitions/Features/Time`, `Native/Ambitions/Features/Today`, `Native/Ambitions/Features/You`, `Native/Ambitions/UI`, `Sources/`, `AppUI/Sources`, and `Native/AmbitionsTests`.
- AFEP proof report files under `build/reports/afep/AFEP-013/`.
- This prompt and concept-lock or champion-coverage entries only if the guard requires explicit AFEP-013 permission for locked canonical owners.

## Forbidden Scope

- Do not create a parallel Time engine, calendar engine, pressure engine, proof ledger, receipt ledger, ReplayTrace path, privacy owner, accessibility owner, persistence owner, or design-system fork.
- Do not change top-level IA; active IA remains Today / Goals / Capture / Time / You.
- Do not reintroduce `Plan` as a user-facing top-level IA.
- Do not convert Time into a calendar clone, task board, generic command panel, generic status grid, gamified rating surface, habit-chain counter, shame surface, or productivity-guilt UI.
- Do not make pressure visual-only, color-only, animation-only, or unavailable to VoiceOver and Reduce Motion users.
- Do not leak private schedule, capacity, protected-time, proof, receipt, profile, or runtime data through labels, export-safe views, reports, logs, screenshots, or fixtures.
- Do not add cloud model, hosted inference, analytics, backend, account, tracking, paid service, hosted CI, signing, App Store, or telemetry dependencies.
- Do not claim release, device, accessibility conformance, performance, privacy/legal, CI, TestFlight, App Store, screenshot proof, state restoration proof, or broad full-suite proof without current evidence.

## Validation

- Run champion coverage and parallel implementation guard pre/post.
- Run `xcodegen generate`.
- Run `make xcode-build-for-testing BATCH=AFEP-013`.
- Run focused test lanes for Time pressure projections, protected-time/capacity privacy, proof-opportunity provenance, accessibility-safe render equivalents, and any changed canonical owner tests.
- Run `git diff --check`.
- If screenshot or state restoration proof is planned but not captured, record it as a plan or Yellow boundary, not as rendered proof.

## Proof Artifacts

- `build/reports/afep/AFEP-013/time-pressure-packet.md`
- `build/reports/afep/AFEP-013/screenshot-accessibility-packet.md`
- `build/reports/afep/AFEP-013/state-restoration-continuation-report.md`

## Rollback / Failure Behavior

Use AFRI Time routes and disable elevated pressure projections if deterministic pressure, provenance, privacy/export policy, local-only operation, accessibility equivalence, or inspectability evidence fails. On Red, stop with the smallest safe repair rather than widening into broad Time, Plan compatibility, persistence, proof, receipt, privacy, accessibility, or UI cleanup.

## Hard Red

- Time root becomes a calendar clone, task board, generic command panel, generic status grid, gamified rating surface, habit-chain counter, shame surface, or productivity-guilt UI.
- Pressure is hidden, non-deterministic, cloud-required, or framed as shame/urgency.
- Protected time or capacity lacks inspectable privacy/provenance labels.
- Proof opportunity projections silently mutate goals, steps, receipts, schedules, or runtime state.
- Parallel Time, proof, receipt, ReplayTrace, privacy, accessibility, persistence, or design-system owners.
- Top-level IA changes or `Plan` reintroduced as user-facing top-level IA.
- Required cloud model, backend, analytics, tracking, hosted inference, or telemetry dependencies.
- Unproven restoration, screenshot, accessibility, device, release, privacy/legal, CI, or full-suite claims.
