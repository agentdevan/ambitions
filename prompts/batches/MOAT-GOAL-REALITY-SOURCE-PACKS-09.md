<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-GOAL-REALITY-SOURCE-PACKS-09 — Public Requirement Source Pack Boundary

## Batch ID

`MOAT-GOAL-REALITY-SOURCE-PACKS-09`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-GOAL-REALITY-SOURCE-PACKS-09 prompts/batches/MOAT-GOAL-REALITY-SOURCE-PACKS-09.md
```

## Objective

Add read-only public requirement/source-pack boundaries for source-sensitive Goal Reality outputs. This lets the compiler say “source needed” or “source reviewed” without inventing regulated, legal, education, eligibility, deadline, or public requirement claims.

This batch does not add network fetching by default. It defines local source-pack contracts, validation, freshness/review state, and fallback behavior. Any future R2/public pack fetch must remain anonymous, read-only, and non-user-personal.

## Source Truth To Inspect

```text
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/GOAL_REALITY_COMPILER_BACKEND_MASTER_PLAN.md
Native/Ambitions/Domain/GoalRealityModels.swift
Native/Ambitions/Domain/GoalRealityRiskModels.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift
Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift
```

## Allowed Scope

```text
Native/Ambitions/Domain/GoalRealitySourcePackModels.swift
Native/Ambitions/Runtime/GoalRealitySourceBoundaryService.swift
Native/Ambitions/Runtime/GoalRealityCompiler.swift
Native/Ambitions/Runtime/GoalRealityValidator.swift
Native/AmbitionsTests/Runtime/GoalRealitySourcePackTests.swift
Native/AmbitionsTests/Runtime/GoalRealityNegativeFixtureTests.swift
docs/audits/moat-goal-reality-source-packs-09-report.md
docs/truth/IMPLEMENTATION_TRUTH.md
```

## Required Behavior

Add source-pack value models for public, non-personal requirements:

```text
pack id/title/version/domain
source record
claim record
requirement record
freshness state
review state
risk class
revocation state
```

The compiler must route source-sensitive goals to:

```text
sourceNeeded
sourceReview
sourceBackedCandidate if local pack supports it
blocked if source is stale/revoked/conflicted
```

Domains that require source boundaries:

```text
regulated career / education
legal / immigration
public eligibility
public deadline
certification / licensing
high-risk public requirements
```

## Forbidden Scope

No private user data upload. No network fetch unless already implemented and safe. No hosted backend. No official claim if source state is missing/stale/conflicted. No professional advice. No release claim.

## Required Tests

Prove:

```text
source-sensitive goal without pack routes to sourceNeeded
current reviewed local pack can support a requirement-limited recommendation
stale source blocks high-risk use
revoked/conflicted source blocks recommendation
private user context is never written into source pack
source pack models are local/read-only
```

## Validation

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealitySourcePackTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/GoalRealityNegativeFixtureTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

## Hard Red Stop Conditions

Stop if source packs require user-data upload, live network dependency, unsourced official claims, professional advice, or cloud backend.

## Claim Boundary

Allowed: local source-pack boundary models and tests exist. Forbidden: live freshness fetching, official requirement coverage, or production source-pack completeness unless separately proven.

## Rollback

Normal revert.

## Next Batch

`MOAT-GOAL-REALITY-EVAL-HARNESS-10`
