# AMB-1117 Pre-Source Guard Prompt

Program: `amb-master`
Issue: `AMB-1117`
Train: `M02.T08`
Title: High-risk safety and jurisdiction handling
Project: `ca716546-e3d4-4d5b-a399-03076ccba9ee`
Baseline SHA: `bf1e7afc56dee127c7fe49bc4326d37086a7262e`

## Scope

Implement the smallest deterministic local runtime owner needed for high-risk and jurisdiction-sensitive fail-safe handling before runtime outputs become user-visible or installable.

The implementation should extend the existing `private_life_runtime` chain and compose current source owners:

- `AnyGoalRuntimeCoverage`
- `SourceAtlasAuthorityMesh`
- `LifeConsequenceEngine`
- `RuntimeCoreUmbrellaGate`

Expected source boundary:

- `Native/Ambitions/Runtime`
- `Native/AmbitionsTests/Runtime`
- AMB master proof/control-plane artifacts
- concept-lock and champion coverage metadata only if required by the guard

## Required Behavior

- Unsafe or non-local runtime paths must block before coverage request, visible Step, schedule install, or share projection.
- Jurisdiction-needed cases must produce an inspectable handoff before runtime pathing.
- High-risk review cases must remain local and review-required until source authority, jurisdiction, and review state are acceptable.
- Source authority failures from revoked, contradicted, stale, missing, review-blocked, or jurisdiction-incompatible source state must block or require review instead of silently continuing.
- The output must include local `Receipt` references, `ReplayTrace` references, `SourceRecord` references, and What Ambitions Knows inspection routes.
- The runtime segment must be `.highRiskSafety` and must be blocked when safety boundaries are not satisfied.

## Non-Goals

- No user-facing UI.
- No crisis-service implementation.
- No legal, medical, financial, privacy, App Review, accessibility, device, performance, TestFlight, App Store, or release readiness claim.
- No external/cloud LLM, telemetry, analytics, hosted backend, private data export, R2 personal data, Calendar/EventKit integration, notifications, persistence mutation, or share publication path.

## Validation Plan

- Run the AMB master preflight and M02 phase gate.
- Run parallel implementation guard pre and post.
- Run focused high-risk safety and jurisdiction tests.
- Run adjacent M02 runtime tests covering Any Goal, Source Authority, Life Consequence, Runtime Core, and Source Atlas replay.
- Run build-for-testing.
- Run champion coverage.
- Run Source Atlas readiness, no-claim, release-claim, privacy-boundary advisory, JSON, closeout, readiness, repository wiring, and whitespace checks.
