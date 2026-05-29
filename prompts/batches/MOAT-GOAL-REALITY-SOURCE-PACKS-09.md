<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-11630089, AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-25124030, AMB28-same_source_file_targeted_by_multiple_active_batches-31211961, AMB28-same_source_file_targeted_by_multiple_active_batches-43487967, AMB28-same_source_file_targeted_by_multiple_active_batches-44395706, AMB28-same_source_file_targeted_by_multiple_active_batches-65376188, AMB28-same_source_file_targeted_by_multiple_active_batches-72395313, AMB28-same_source_file_targeted_by_multiple_active_batches-72778890, AMB28-same_source_file_targeted_by_multiple_active_batches-80494176, AMB28-same_source_file_targeted_by_multiple_active_batches-83544260 and 2 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
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
