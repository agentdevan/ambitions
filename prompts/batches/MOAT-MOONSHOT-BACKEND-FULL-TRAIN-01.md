<!-- AMB-291-CANON-HYGIENE-REPAIR: BEGIN -->

> AMB-291 repair status: **canon-hygiene-reconciled**
> This file was reviewed as part of the actual canon content/hygiene rewrite pass.
> It is not standalone active product truth. Use `docs/truth/*` and current manifest/sequence authority before implementation.
> Conflict types reconciled: same_source_file_targeted_by_multiple_active_batches, same_surface_multiple_active_batches
> Prior recommended actions: Expedite, Merge
> Candidate references: AMB28-same_source_file_targeted_by_multiple_active_batches-19279448, AMB28-same_source_file_targeted_by_multiple_active_batches-22647572, AMB28-same_source_file_targeted_by_multiple_active_batches-23326226, AMB28-same_source_file_targeted_by_multiple_active_batches-29168866, AMB28-same_source_file_targeted_by_multiple_active_batches-31211961, AMB28-same_source_file_targeted_by_multiple_active_batches-3247698, AMB28-same_source_file_targeted_by_multiple_active_batches-37886007, AMB28-same_source_file_targeted_by_multiple_active_batches-40595983, AMB28-same_source_file_targeted_by_multiple_active_batches-41488053, AMB28-same_source_file_targeted_by_multiple_active_batches-43487967, AMB28-same_source_file_targeted_by_multiple_active_batches-53599448, AMB28-same_source_file_targeted_by_multiple_active_batches-54846811 and 16 more

<!-- AMB-291-CANON-HYGIENE-REPAIR: END -->
<!-- AMB-291-CANON-HYGIENE-HEADER: BEGIN -->

> Canon hygiene status: **execution-work-order-needs-sequencing**
> AMB-291 note: This batch/prompt is a work-order artifact and must be sequenced before execution.
> Active authority: `docs/truth/*`, `docs/codex/GLOBAL_BATCH_SEQUENCE_AUTHORITY.json`, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.
> Before using this file for implementation, run `make change-impact-check` and follow `docs/ops/change-protocol/implementation-prompt-template.md`.
> Resolution classes: merge-overlap, terminology-quarantine
> Dispositions: merge-or-sequence-file-ownership, merge-or-sequence-surface-ownership, quarantine-or-rewrite-terminology

<!-- AMB-291-CANON-HYGIENE-HEADER: END -->
<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->

# MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01 — Full Local Moonshot Proof-Path Backend Runtime

## Batch ID

`MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01`

## Runner Command

```bash
scripts/ambitions-codex-train.sh MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01 prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md
```

Equivalent:

```bash
make batch BATCH=MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01 PROMPT=prompts/batches/MOAT-MOONSHOT-BACKEND-FULL-TRAIN-01.md
```

## Objective

Implement the full local backend/runtime feature described in:

```text
docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md
```

The target is a world-class Ambitions backend/runtime feature that can convert a raw life-scale moonshot ambition into a grounded, proof-gated, receipt-backed, Today-ready execution candidate without hosted AI, hidden mutation, unsafe advice, false feasibility claims, or generic productivity behavior.

The canonical proof scenario is:

```text
User says: I want to be an Olympic swimmer.
Known context: user is 32 and cannot swim.
```

Expected result:

```text
North Star: Olympic swimmer
Active path: Become a swimmer from zero
Literal outcome truth: moonshotNotEvidenceSupportedYet
Current gate: Water safety baseline
Start Here candidate: Book adult beginner swim assessment
Receipt: Ambitions preserved the North Star but did not assume Olympic feasibility yet.
Blocked behavior: Olympic training plan, high-volume swim schedule, elite benchmark comparison, guarantee language, unsafe training intensity.
```

## Required Operating Mode

Run as a bounded multi-phase backend implementation train.

Use the runner sequence:

```text
GPT-5.5 plan → GPT-5.3-Codex-Spark bounded patch → GPT-5.5 review/repair/final commit
```

Do not bypass the Ambitions runner. Do not paste this directly into Codex unless the user explicitly bypasses the runner.

## Active Source Truth To Inspect First

Before editing, inspect:

```text
docs/truth/PRODUCT_DESIGN_TRUTH.md
docs/truth/IMPLEMENTATION_TRUTH.md
docs/truth/RELEASE_TRUTH.md
docs/truth/CODEX_PROCESS_TRUTH.md
docs/codex/MOONSHOT_PROOF_PATH_BACKEND_MASTER_PLAN.md

docs/canon/Ambitions_Intelligence_Runtime.md
docs/canon/AmbitionsOS_Runtime_Contract.md
docs/canon/Ambitions_Found_Life_Layer.md

Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift

Native/Ambitions/Domain/AmbitionsOSLivingDreamStartingPositionPrivacyIntakeModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamPathPortfolioModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamCapacityBridgeModels.swift
Native/Ambitions/Domain/AmbitionsOSLivingDreamTodayBridgeModels.swift
Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift

Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift
Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift
Native/AmbitionsTests/Domain/InspectableIntelligenceGoldenScenarioTests.swift
```

Implementation truth wins over plans. Source/test evidence wins over audit docs. Docs-only canon does not prove implementation.

## Allowed Scope

Implement as much of the master plan as is safe in one backend train.

Preferred new files:

```text
Native/Ambitions/Domain/MoonshotProofPathModels.swift
Native/Ambitions/Runtime/MoonshotProofPathRuntime.swift
Native/AmbitionsTests/Runtime/MoonshotProofPathRuntimeTests.swift
docs/audits/moat-moonshot-backend-full-train-01-report.md
```

Allowed touched files:

```text
Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift
Native/Ambitions/Runtime/AmbitionsRuntimeFactory.swift
Native/Ambitions/Runtime/AmbitionsRuntimeGoalIntelligence.swift
Native/Ambitions/Features/Today/TodayExecutionProjector.swift
Native/Ambitions/Features/Today/DayRailViewState.swift
Native/Ambitions/PreviewSupport/PreviewTodayScenarios.swift
Native/AmbitionsTests/Runtime/AmbitionsRuntimeGoalIntelligenceServiceTests.swift
Native/AmbitionsTests/Domain/AmbitionsOSLivingDreamTodayBridgeModelsTests.swift
Native/AmbitionsTests/Today/TodayViewModelTests.swift
docs/truth/IMPLEMENTATION_TRUTH.md
docs/codex/BATCH_REGISTRY.md
docs/codex/CONTEXT_INDEX.md
.codex/reports/current-run-state.md
.codex/reports/current-batch-train-state.md
```

If a file listed above does not exist or is not the right seam after inspection, choose the smallest adjacent existing seam and document the deviation.

## Forbidden Scope

Do not add or modify:

```text
.github/
.github/workflows/
entitlements
PrivacyInfo.xcprivacy
CloudKit/iCloud sync
Cloudflare R2 client/source-pack fetching
OpenAI/API/cloud LLM dependencies
hosted backend
network client
analytics/telemetry
release/App Store/TestFlight claims
signing/export configuration
new top-level tabs/routes
notifications/widgets/Live Activities/App Intents
broad UI redesign
```

Do not create:

```text
chatbot UI
generic dream planner
generic AI coach
motivation score
proof signal
user-facing confidence score
hard-coded Olympic-only implementation
automatic schedule mutation
hidden plan activation
unsafe athletic/health advice
source-sensitive Olympic eligibility claims without source/review state
```

## Phase 0 — Authority And Boundary Read

Read active truth, master plan, relevant runtime/domain files, and tests.

Produce an internal implementation map before patching:

```text
existing seams
new files needed
tests needed
risk boundaries
whether persistence is safe
whether Today preview wiring is safe
```

Do not patch before this map is complete.

## Phase 1 — Pure Domain Models

Add moonshot proof-path value models.

Required concepts:

```text
MoonshotAmbitionInput
MoonshotStartingCapabilitySignal
MoonshotConstraintSignal
MoonshotTruthState
MoonshotNorthStar
MoonshotActivePath
MoonshotProofGate
MoonshotReceiptPayload
MoonshotStartHereCandidate
MoonshotProofPathResult
MoonshotProofPathIssue
MoonshotProofPathReadiness
```

Models must be:

```text
Sendable
Equatable
Codable where appropriate
small
stable
non-UI-owned
```

No persistence write in this phase.

## Phase 2 — Deterministic Compiler

Add a deterministic runtime compiler.

Preferred shape:

```swift
struct MoonshotProofPathRuntime {
    func compile(_ input: MoonshotAmbitionInput) -> MoonshotProofPathResult
}
```

Required behavior:

```text
recognize Olympic/Olympian as a moonshot North Star signal
recognize cannot swim / beginner swim as a water-safety starting-position signal
separate North Star from Active Path
build first proof gate before any training schedule
produce Start Here candidate
produce receipt payload
preserve unknowns instead of guessing
```

No network. No hosted AI. No persistence write. No automatic mutation.

## Phase 3 — Validator

Add strict validation.

Preferred shape:

```swift
struct MoonshotProofPathValidator {
    func validate(_ result: MoonshotProofPathResult) -> [MoonshotProofPathIssue]
}
```

Must detect and test:

```text
missingNorthStar
missingStartingPosition
missingActivePath
missingFirstProofGate
activePathNotSeparatedFromNorthStar
literalOutcomeTreatedAsGuaranteed
unsafeTrainingBeforeSafetyProof
highVolumeScheduleBeforeBeginnerProof
sourceSensitiveClaimWithoutSource
missingReceipt
missingCorrectionControl
hiddenPlanMutation
hiddenCommitmentMutation
externalServerDependency
confidenceScoreExposed
punitiveClosureLanguage
genericProductivityLanguage
unsafeAthleticHealthImplication
```

Issue names may vary only if they are equally explicit and stable.

## Phase 4 — Start Here / Existing Runtime Bridge

Implement a bridge to existing runtime shapes where safe.

Preferred outcomes:

```text
MoonshotStartHereAdapter can produce a bridgeable Today candidate.
The bridge preserves recommended step, proof/review support, receipt, closure, controls, runtime boundary, and no hidden mutation.
```

If cleanly possible, bridge to existing `AmbitionsOSLivingDreamTodayBridge` or `AmbitionsOSStartHereRecommendation` value models.

If not cleanly possible in this batch, keep a typed adapter result and document Yellow:

```text
Today live wiring deferred; backend candidate is source-present and tested.
```

## Phase 5 — Runtime Service Exposure

Expose the service through local runtime seams if safe.

Preferred:

```text
MoonshotProofPathCompiling protocol
DefaultMoonshotProofPathRuntime implementation
AmbitionsRuntime property or RepositoryBackedRuntimeGoalIntelligenceService helper
AmbitionsRuntimeFactory injection
```

Only add runtime wiring if it is small and compile-safe.

Do not make the app depend on this for launch.

## Phase 6 — Persistence Decision Gate

Inspect existing persistence, proof, receipt, event ledger, goal draft, and capture structures.

Implement persistence only if all are true:

```text
existing records can store review candidate safely, or new schema has migration/rollback tests
no automatic plan activation
no hidden mutation
receipt/correction path exists
validation and rollback proof can be completed in this batch
```

If not safe, do not persist. Report Yellow:

```text
Pure backend/runtime feature installed; persistence deferred to MOAT-MOONSHOT-LOCAL-PERSISTENCE-03.
```

Do not add schema under pressure.

## Phase 7 — Golden And Negative Tests

Add focused tests.

Mandatory tests:

1. Olympic swimmer from zero becomes proof-gated path.
2. Unsafe Olympic training plan is blocked.
3. Guarantee/confidence/punitive language is blocked.
4. Missing starting position routes to intake review and does not create workout/training plan.
5. Today bridge candidate carries recommended step, proof/review, receipt, closure, controls, and value-model-only runtime boundary.
6. Pure compile has no network, no remote intelligence, no persistence write, no automatic schedule mutation, and no external projection.

Tests must assert specific values, not just non-nil objects.

## Phase 8 — Optional Preview Fixture

Only if small and safe, add a Today preview fixture for the golden scenario.

It must show:

```text
Start here
Book adult beginner swim assessment
Because the first proof gate is water safety...
Receipt / Why this seam
No training-plan language
```

Do not redesign Today.

If omitted, document why.

## Phase 9 — Truth / Audit / Registry Updates

Create:

```text
docs/audits/moat-moonshot-backend-full-train-01-report.md
```

Update implementation truth conservatively.

Allowed wording:

```text
Moonshot proof-path backend value models are source-present.
The Olympic swimmer from zero golden scenario is unit-tested as a deterministic local fixture.
The runtime can compile a structured moonshot input into a proof-gated Today-ready candidate without hidden mutation or remote intelligence.
Full raw Capture-to-persistence-to-Today live app flow remains unproven unless separately wired and validated.
```

Forbidden wording:

```text
Ambitions fully handles all dreams.
Ambitions understands all raw user intent.
Olympic swimmer flow is production-ready.
Moonshot runtime is complete.
Local AI is complete.
Personalized execution engine is complete.
```

Update registry/context/run-state files only if consistent with repo conventions.

## Validation Expectations

Run:

```bash
xcodegen generate
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/MoonshotProofPathRuntimeTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AmbitionsRuntimeGoalIntelligenceServiceTests
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO -only-testing:AmbitionsTests/AmbitionsOSLivingDreamTodayBridgeModelsTests
scripts/build-local.sh
git diff --check
scripts/run-doc-qa.sh || true
scripts/batch-train-gate-check.sh || true
```

If available, run:

```bash
scripts/cqs-product-drift-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-moonshot-backend-full-train-01-report.md || true
scripts/cqs-prompt-built-smell-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime || true
scripts/cqs-privacy-security-claim-scan.sh Native/Ambitions/Domain Native/Ambitions/Runtime Native/AmbitionsTests/Runtime docs/audits/moat-moonshot-backend-full-train-01-report.md || true
```

If a script is unavailable, record unavailable. Do not pretend it passed.

## Visual Proof Expectations

This is backend-first. Visual proof is optional.

If UI/preview is touched, provide a screenshot/preview artifact path or explain why visual proof is not applicable.

Do not claim final visual quality, device proof, accessibility conformance, or release readiness.

## Hard Red Stop Conditions

Stop and report Red if any of these are required:

```text
external LLM/API/network call
hosted backend/user-data server
schema migration without rollback proof
automatic plan mutation
hidden commitment mutation
new top-level route/tab
release/App Store/TestFlight claim
unsafe athletic or health advice
source-sensitive Olympic eligibility claim without source/review state
guarantee language cannot be removed
tests require disabling existing safety validators
broad Today redesign required
```

## Rollback Expectations

Rollback must be a normal commit revert.

If no schema is added, rollback should remove only:

```text
MoonshotProofPathModels.swift
MoonshotProofPathRuntime.swift
MoonshotProofPathRuntimeTests.swift
optional runtime wiring
optional preview fixture
audit/truth/registry updates
```

No entitlement, route, release, server, or migration rollback should be needed.

## Expected Final Status

Preferred:

```text
Green with accepted Yellow advisories
```

Acceptable Yellow advisories:

```text
Raw Capture-to-runtime live flow deferred.
Persistence deferred.
Today live UI surfacing deferred.
Official Olympic source requirements deferred to Source Atlas pack work.
Physical-device proof unavailable.
```

Unacceptable as Green:

```text
No golden test
No negative safety fixture
No validator
No receipt
No Start Here candidate
No local-only boundary assertion
No implementation truth update
```

## Next Recommended Batches

If Capture wiring is deferred:

```text
MOAT-MOONSHOT-CAPTURE-TO-GOAL-02
```

If persistence is deferred:

```text
MOAT-MOONSHOT-LOCAL-PERSISTENCE-03
```

If Today live surfacing is deferred:

```text
MOAT-MOONSHOT-TODAY-START-HERE-04
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
