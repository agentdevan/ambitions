# MRI09 Source-to-Recommendation Bridge Report

Status: Accepted Yellow  
Date: 2026-05-13  
Branch: `main`  
Starting commit: `59d78c3478a32734fa285a3d798393740a0455bc`  
Operating system: Inspectable Intelligence Engine  
Product loop: Source-to-recommendation

## Source Truth Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `.codex/reports/current-run-state.md`
- `.codex/state/active-batch.yml`
- `docs/codex/POST_BATCH_GATE_REGISTRY.md`
- Target source and test files listed below

## Files Changed

- `Native/Ambitions/Domain/RecommendationExplanationModels.swift`
- `Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift`
- `Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift`
- `Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift`
- `docs/audits/mri09-source-to-recommendation-bridge-report.md`

## Loop Behavior Added

- Added `sourceTruth` recommendation evidence category for Source Atlas-backed recommendation evidence.
- Added a value-model bridge from `SourceAtlasQueryResult` into `RecommendationExplanationEvidence`.
- Added source-state/freshness/risk/review/fallback metadata and explicit Source Atlas block reasons to `RecommendationEvidenceModel`.
- Added a value-model bridge from `SourceAtlasQueryResult` into `AmbitionsOSSourceTruthClaim`.
- Added Start Here fit-state projection for current, source-needed, stale, contradicted, revoked, and review-required Source Atlas query results.
- Added tests proving official current Source Atlas results can support recommendation evidence.
- Added tests proving source-needed, stale, contradicted, revoked, and review-required Source Atlas results cannot be treated as current recommendation support.

Deferred:

- No UI presentation was added.
- No persistence, migration, network, backend, hosted AI, release automation, or shell/routing behavior was added.
- No Source Atlas store behavior was changed.

## EFC Applicability

EFC applicable: invoked. This batch touches intelligence, recommendation evidence, source trust, and validator-visible source/freshness/risk constraints.

## Validation

| Command | Exit | Result |
|---|---:|---|
| `git status --short` | 0 | Started clean on `main`; dirty set after patch is limited to MRI09 files. |
| `xcodegen generate` | 0 | Generated `Ambitions.xcodeproj`; no project diff remained. |
| `git diff --check` | 0 | Passed. |
| `python3 scripts/ambitions-state-advance-validate.py \|\| true` | 0 | Reported `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py <MRI09 changed files> 2>/dev/null \|\| true` | 0 | Reported `GREEN: unsupported completion/readiness claim scan passed`. |
| `swiftc -parse <MRI09 changed Swift files>` | 0 | Syntax parse passed for changed Swift files. |
| Shell `xcodebuild ... RecommendationExplanationModelsTests ...` | not executed | Rejected by outer command policy: `approval required by policy, but AskForApproval is set to Never`. |
| XcodeBuildMCP `test_sim` for `AmbitionsTests/RecommendationExplanationModelsTests` | 1 | Build failed before MRI09 assertions because unrelated app-target compile debt blocked the lane: `Native/Ambitions/Services/LargeStoreFixtureGenerator.swift:89` missing `metadata` for `GoalPlannedResult`. |
| XcodeBuildMCP `test_sim` for `AmbitionsTests/AmbitionsOSRecommendationStartHereModelsTests` | 1 | Build failed before MRI09 assertions because unrelated app-target compile debt blocked the lane: `Native/Ambitions/Features/Today/TodayReadModelProjector.swift:44` references missing `TodayTimeApertureState.summary`. |

Accepted Yellow reason: static checks and MRI09-local syntax validation passed, but focused simulator assertions could not run because existing unrelated app-target compile debt blocked the build before the selected tests executed.

## Phase 03 GPT-5.5 Review Rerun

Review status: Accepted Yellow. No MRI09 repair required in this phase.

Rerun commands:

| Command | Exit | Result |
|---|---:|---|
| `git diff --check` | 0 | Passed. |
| `python3 scripts/ambitions-state-advance-validate.py \|\| true` | 0 | Reported `GREEN: state advancement coherent; current=SA16 Source Container Model; next=SA17 URL Source Importer`. |
| `python3 scripts/ambitions-unsupported-claim-scan.py <MRI09 changed files and report> 2>/dev/null \|\| true` | 0 | Reported `GREEN: unsupported completion/readiness claim scan passed`. |
| `xcodegen generate` | 0 | Generated `Ambitions.xcodeproj`; no project diff remained. |
| `xcrun swiftc -parse <MRI09 changed Swift files>` | 0 | Syntax parse passed for changed Swift files. |
| Shell `xcodebuild ... RecommendationExplanationModelsTests ...` | not executed | Rejected before execution by outer command policy: `approval required by policy, but AskForApproval is set to Never`. |
| XcodeBuildMCP `test_sim` for `AmbitionsTests/RecommendationExplanationModelsTests` | 1 | Build failed before MRI09 assertions because unrelated test-target compile debt blocked the lane: `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`, `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`, and `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`. |
| XcodeBuildMCP `test_sim` for `AmbitionsTests/AmbitionsOSRecommendationStartHereModelsTests` | 1 | Build failed before MRI09 assertions because unrelated app-target compile debt blocked the lane: `Native/Ambitions/Services/LargeStoreFixtureGenerator.swift:89` missing `metadata` for `GoalPlannedResult`. |

Review notes:

- Diff remained inside the Phase 02 approved boundary.
- Source Atlas-backed recommendation evidence is value-model-only and local-only.
- Blocked Source Atlas states add explicit recommendation block metadata and cannot drive `RecommendationEvidenceModel.canDriveRecommendation`.
- Start Here Source Atlas bridge maps current official approved source evidence to `.fits` and stale/source-needed/contradicted/revoked/review-required results to reviewable, source-needed, or blocked states.
- No UI, persistence, migration, network, hosted AI, shell/routing, release automation, signing, entitlement, or privacy manifest changes were added.

Accepted Yellow reason from this review: MRI09 static/source-local validation passed and no scoped repair issue was found, but focused simulator tests still cannot execute their MRI09 assertions because unrelated compile blockers remain outside the MRI09 ownership boundary.

## Claims Not Made

- No release readiness claim.
- No TestFlight readiness claim.
- No App Store readiness claim.
- No physical-device proof claim.
- No public accessibility conformance claim.
- No performance validation claim.
- No privacy/legal approval claim.
- No visual runtime completion claim.
- No hosted AI, external LLM, cloud backend, sync, or network behavior claim.
- No global train completion claim.

## Rollback Notes

Rollback only MRI09 files:

```bash
git restore -- Native/Ambitions/Domain/RecommendationExplanationModels.swift Native/Ambitions/Domain/AmbitionsOSRecommendationStartHereModels.swift Native/AmbitionsTests/Domain/RecommendationExplanationModelsTests.swift Native/AmbitionsTests/Domain/AmbitionsOSRecommendationStartHereModelsTests.swift docs/audits/mri09-source-to-recommendation-bridge-report.md
```

## Next Handoff

Repair unrelated compile blockers before rerunning the focused MRI09 test lanes:

- `Native/Ambitions/Services/LargeStoreFixtureGenerator.swift:89`
- `Native/Ambitions/Features/Today/TodayReadModelProjector.swift:44`
- `Native/AmbitionsTests/Services/PolicyGuardedCommandExecutorTests.swift:28`
- `Native/AmbitionsTests/Persistence/PortableRestoreRollbackTests.swift:109`
- `Native/AmbitionsTests/Persistence/PreMigrationBackupTests.swift:110`

Then rerun:

```bash
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/RecommendationExplanationModelsTests test CODE_SIGNING_ALLOWED=NO
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AmbitionsTests/AmbitionsOSRecommendationStartHereModelsTests test CODE_SIGNING_ALLOWED=NO
```
