<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B06 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04A-B06`

## Train ID and title
`TRAIN_04A` - Life Context & Historical Catch-Up Runtime Inputs

## Batch role in train
Batch 6 of 6 in TRAIN_04A

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`

## Downstream dependencies
- `TRAIN_04B`
- `TRAIN_04C`
- `TRAIN_04D`
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_08`
- `TRAIN_09`
- `TRAIN_10`
- `TRAIN_16`

## Objective
Install a first-class `PersonalizationFactorLedger` proof path so Ambitions recommendations are deterministic, inspectable, multi-factor, reality-aware, user-owned, context-composed, and explainable.

This batch must prove that the runtime builds recommendations through constraint composition, candidate competition, and replayable reasoning, not demographic templates, static archetypes, hidden profile buckets, or fake personalization theater.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
Preserve local-first deterministic behavior. Do not introduce external personal-data, cloud LLM, analytics, tracking, backend SDK, or paid service dependencies.

## Accessibility constraints
Preserve VoiceOver semantics, Dynamic Type, Reduce Motion, Increase Contrast, and 44 pt minimum touch-target expectations where UI is touched. Do not claim accessibility verification without proof.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Allowed files/directories
- Add domain/runtime model support for `PersonalizationFactorLedger`.
- Add typed factor models, source/freshness/user-control fields, permissions, and fallback behavior.
- Wire ledger generation into local recommendation candidate competition and Start Here explanation inputs.
- Add deterministic replay support for factor ledger, candidate ranking, and recommendation output.
- Add receipts for factor use, disablement, expiry, recommendation change, stale confidence, replay differences, fallback reasoning, demographic rejection, and candidate rejection.
- Add You -> Life Context inspection/control surfaces for Runtime Factors, Recommendation Inputs, Why This Changes Plans, Rejected Factors, Sensitive Context Usage, Context Confidence, Needs Review, Disabled Factors, and Replay & Receipts.
- Add focused unit tests, UI tests, preview fixtures, and proof artifact.
- Update only source, tests, previews, and proof artifacts required for this batch.

## Forbidden files/directories
- No cloud profiling.
- No ad-style optimization.
- No opaque recommendation engine.
- No `AI confidence` consumer language.
- No hidden demographic categorization.
- No generic productivity template engine.
- No top-level IA changes.
- No external analytics dependency.
- No required cloud AI/LLM dependency.
- No hosted personal-data backend.
- No demographic-only full-plan selection.
- No `users like you` language.
- No hardcoded bucket plans.
- No sensitive factors used without explicit permission.
- No factorless recommendations.
- No non-inspectable recommendation logic.
- No release, device, accessibility, privacy/legal, TestFlight, App Store, CI, or performance claims without current proof.

## Exact implementation steps
1. Re-read active truth files.
2. Inspect only the allowed source and proof areas.
3. Implement the smallest patch that satisfies this sealed work order.
4. Write the required proof artifact.
5. Run validation and report proof honestly.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsUITests
git diff --check
```

## Proof artifacts to write
`build/reports/life-context/anti-bucket-factor-ledger-proof.md`

The proof artifact must include:
- Status: Green / Yellow / Red
- Branch and commit
- Commands run
- Commands not run
- Files changed
- Ledger object proof
- Factor type proof
- Receipt proof
- You inspection/control proof
- Test Group A result
- Test Group B result
- Test Group C result
- Test Group D result
- Test Group E result
- Test Group F result
- Accessibility status
- Privacy/local-first status
- Claims allowed
- Claims forbidden
- Yellow/Red items
- Rollback notes
- `build/reports/ios26-baseline/`
- `build/reports/ios26-migration/`
- `build/reports/ios26-shell/`
- `build/reports/private-life-runtime/`
- `build/reports/goal-intent-compiler/`
- `build/reports/life-context/`
- `build/reports/step-optionality/`
- `build/reports/source-atlas-runtime-bridge/`
- `build/reports/capture-runtime-bridge/`
- `build/reports/core-replacement-contracts/`
- `build/reports/core-life-object-store/`
- `build/reports/time-operations/`
- `build/reports/reminder-operations/`
- `build/reports/project-step-operations/`
- `build/reports/life-knowledge-operations/`
- `build/reports/life-command-search/`
- `build/reports/private-life-runtime-integration/`
- `build/reports/reality-meridian/`
- `build/reports/lifeshape-field/`
- `build/reports/constellation-atlas/`
- `build/reports/atmosphere-composer/`
- `build/reports/user-system-profile/`
- `build/reports/proof-receipts-replay/`
- `build/reports/data-safety/`
- `build/reports/external-surfaces/`
- `build/reports/accessibility-nutrition/`
- `build/reports/performance/`
- `build/reports/repo-hygiene/`
- `build/reports/release-candidate/`

## Green / Yellow / Red gates
Green: sealed objective, validation, and proof artifact pass. Yellow: bounded gap with owner, reason, no-claim boundary, and follow-up gate. Red: missing prompt, boundary violation, failed validation without accepted Yellow, or forbidden dependency/claim.

## Rollback behavior
Rollback only files touched by this batch. Preserve unrelated dirty work, generated logs, and existing Life Context source changes owned by other batches or threads.

If runtime source changes must be reverted, also revert matching tests, preview fixtures, receipts, and proof artifact updates from this batch only.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status: Green / Yellow / Red
Batch:
Train:
Scope:
Branch:
Commit:
Files changed:
Truth files inspected:
Source areas inspected:
Commands run:
Commands not run:
Environment:
Evidence:
PersonalizationFactorLedger status:
Factor types status:
Receipt status:
You surface status:
Test Group A:
Test Group B:
Test Group C:
Test Group D:
Test Group E:
Test Group F:
Accessibility status:
Privacy/local-first status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04A-B06 - Anti-Bucket Personalization & Factor Ledger Proof

## Batch type
Private Life Runtime moat-hardening, anti-bucket personalization, factor ledger proof, deterministic tests, receipts, replay, and You inspection controls.

## Objective
Install a first-class `PersonalizationFactorLedger` proof path so Ambitions recommendations are deterministic, inspectable, multi-factor, reality-aware, user-owned, context-composed, and explainable.

This batch must prove that the runtime builds recommendations through constraint composition, candidate competition, and replayable reasoning, not demographic templates, static archetypes, hidden profile buckets, or fake personalization theater.

## Why this exists
The moat is not:

```text
16-year-old athlete template.
```

The moat is:

```text
This exact person, with this exact history, this exact access reality, this exact availability, this exact deadline pressure, and this exact execution behavior should probably do this step now.
```

The runtime must prove:
- Same demographic bucket can produce radically different plans.
- Different demographics can produce similar plans when real constraints match.
- Recommendations are built from constraint composition, not profile stereotypes.
- Every recommendation has a visible factor ledger.
- Every factor is sourced, freshness-aware, and controllable.

## Product standard
Ambitions should feel like:

```text
This understands my life.
```

It must not feel like:

```text
This categorized me.
```

Start Here explanations must reference actual runtime factors, user-owned context, real constraints, and real availability.

Good:
- `Recommended because you have a 38-minute opening, a nearby YMCA, and your tryout is 9 weeks away.`
- `Your recent completion history suggests shorter evening sessions succeed more reliably.`

Bad:
- `Recommended for high school athletes.`
- `Users like you usually prefer...`

No `users like you` language is allowed.

## Dependencies
IOS26-T04A-B01, IOS26-T04A-B02, IOS26-T04A-B03, IOS26-T04A-B04, and IOS26-T04A-B05.

This batch hardens TRAIN_04A before downstream Today, Time, You, proof/receipts/replay, data safety, accessibility, performance, and release trains may rely on Life Context personalization claims.

## Truth files to read
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

## Exact source areas to inspect
- Runtime
- Recommendation engine
- Goal compiler
- Today
- Time
- You
- Persistence
- Receipts
- Replay
- Services
- Tests
- UI tests
- Preview fixtures
- `Native/Ambitions/Domain/`
- `Native/Ambitions/Services/`
- `Native/Ambitions/Persistence/`
- `Native/Ambitions/Features/Today/`
- `Native/Ambitions/Features/Time/`
- `Native/Ambitions/Features/You/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`
- `build/reports/life-context/`

## Exact changes allowed
- Add domain/runtime model support for `PersonalizationFactorLedger`.
- Add typed factor models, source/freshness/user-control fields, permissions, and fallback behavior.
- Wire ledger generation into local recommendation candidate competition and Start Here explanation inputs.
- Add deterministic replay support for factor ledger, candidate ranking, and recommendation output.
- Add receipts for factor use, disablement, expiry, recommendation change, stale confidence, replay differences, fallback reasoning, demographic rejection, and candidate rejection.
- Add You -> Life Context inspection/control surfaces for Runtime Factors, Recommendation Inputs, Why This Changes Plans, Rejected Factors, Sensitive Context Usage, Context Confidence, Needs Review, Disabled Factors, and Replay & Receipts.
- Add focused unit tests, UI tests, preview fixtures, and proof artifact.
- Update only source, tests, previews, and proof artifacts required for this batch.

## Exact changes forbidden
- No cloud profiling.
- No ad-style optimization.
- No opaque recommendation engine.
- No `AI confidence` consumer language.
- No hidden demographic categorization.
- No generic productivity template engine.
- No top-level IA changes.
- No external analytics dependency.
- No required cloud AI/LLM dependency.
- No hosted personal-data backend.
- No demographic-only full-plan selection.
- No `users like you` language.
- No hardcoded bucket plans.
- No sensitive factors used without explicit permission.
- No factorless recommendations.
- No non-inspectable recommendation logic.
- No release, device, accessibility, privacy/legal, TestFlight, App Store, CI, or performance claims without current proof.

## Runtime philosophy
The runtime must operate like:

```text
constraint composition + candidate competition + replayable reasoning
```

It must not operate like:

```text
if user == archetype then use template
```

Demographic context may affect feasibility, eligibility, opportunity access, sequencing, deadlines, safety, travel reality, and developmental pacing.

Demographic context may not force static templates, silently stereotype users, override more relevant lived constraints, become hidden optimization categories, or become unexplained intuition.

## Required factor ledger structure
Install planning and implementation requirements for `PersonalizationFactorLedger` as a first-class inspectable runtime object.

Required ledger fields:
- `recommendationID`
- `generatedAt`
- `runtimeVersion`
- `userContextVersion`
- `goalID`
- `selectedCandidateID`
- `rejectedCandidateIDs`
- `factors[]`
- `confidenceBand`
- `missingContextQuestions`
- `sensitiveFactorUsage`
- `explanationProjection`
- `replayProjection`

Each factor requires:
- `factorType`
- `factorCategory`
- `humanReadableReason`
- `source`
- `freshness`
- `userControlled`
- `runtimeWeight`
- `affectedRecommendationArea`
- `allowedForRuntimeUse`
- `canDisable`
- `fallbackBehaviorIfRemoved`

Required factor types at minimum:
- `GoalRequirementFactor`
- `DeadlinePressureFactor`
- `AvailabilityWindowFactor`
- `TravelFitFactor`
- `TransportationConstraintFactor`
- `FacilityAccessFactor`
- `EquipmentAccessFactor`
- `HistoricalContextFactor`
- `PastFailureFactor`
- `PastSuccessFactor`
- `RecoveryConstraintFactor`
- `ExecutionBehaviorFactor`
- `TimeOfDayFitFactor`
- `EnergyPatternFactor`
- `EligibilityPathwayFactor`
- `SeasonalityFactor`
- `DependencyConstraintFactor`
- `BudgetConstraintFactor`
- `PreferenceFactor`
- `TrustAllowanceFactor`
- `RecentProofFactor`
- `RecentDriftFactor`
- `SafetyConstraintFactor`

No demographic-only factor may directly select a full plan.

## Required deterministic tests
### Test Group A - Same bucket, different reality
Two users have the same age, same sport, and same region type, but different transportation, equipment, travel radius, history, injury, schedule, facilities, and execution behavior.

Expected:
- Different milestones.
- Different cadence.
- Different Today recommendation.
- Different Time fit.
- Different explanation ledger.
- Different rejected candidates.

### Test Group B - Different bucket, same reality
Two users have different demographics but the same access, capacity, experience, deadline, facilities, and execution patterns.

Expected:
- Materially similar plan shape where appropriate.
- No forced demographic divergence.
- No stereotype explanation.

### Test Group C - Constraint removal
Remove transportation access, facility access, or injury limitation.

Expected:
- Only relevant plan areas change.
- Unrelated recommendation logic remains stable.
- Ledger shows exact changed factors.

### Test Group D - Sensitive context disabled
Disable eligibility context, injury history, or location precision.

Expected:
- Runtime removes those factors entirely.
- Fallback reasoning appears.
- Receipts are created.
- Replay shows recommendation difference.

### Test Group E - Historical freshness drift
Old context is marked `Based on Older Context` and `Needs Review`.

Expected:
- Runtime confidence lowers.
- Confirmation/review path appears.
- Stale factors are weighted lower.
- Start Here explanation acknowledges uncertainty.

### Test Group F - Deterministic replay
Use the same runtime version, context, schedule, goals, and constraints.

Expected:
- Same factor ledger.
- Same candidate ranking.
- Same recommendation output.

## Required You surface additions
Extend `You -> Life Context` with:
- Runtime Factors
- Recommendation Inputs
- Why This Changes Plans
- Rejected Factors
- Sensitive Context Usage
- Context Confidence
- Needs Review
- Disabled Factors
- Replay & Receipts

Every factor must show:
- where it affected recommendations
- when it last affected recommendations
- whether it is active
- source
- freshness
- runtime use permission
- disable/edit/delete controls

## Required receipts
Add receipt types:
- `personalizationFactorUsed`
- `personalizationFactorDisabled`
- `personalizationFactorExpired`
- `recommendationChangedDueToContext`
- `staleContextReducedConfidence`
- `replayDifferenceDetected`
- `fallbackReasoningActivated`
- `demographicFactorRejected`
- `candidateRejectedByConstraint`

## Required accessibility rules
- VoiceOver must expose the selected recommendation, factor categories, human-readable reasons, source, freshness, active/disabled state, sensitive-use state, and available controls.
- Ledger and factor states must not rely on color alone.
- Dynamic Type must preserve factor inspection, controls, and explanations without truncating critical reason/source text.
- Reduce Motion must preserve replay and recommendation-difference meaning with static equivalents.
- Disable/edit/delete controls must be reachable through standard accessibility navigation.
- UI tests or accessibility-oriented proof must cover at least one ledger with active, stale, disabled, sensitive, and rejected factors.
- Do not claim public accessibility verification unless current proof artifacts exist.

## Required privacy rules
- Core behavior remains local-first/on-device-first.
- No required external LLM, hosted personal-data backend, analytics SDK, tracking SDK, or cloud profiling.
- Sensitive factors require explicit permission before runtime use.
- Disabled factors must be excluded from runtime inputs and replay inputs.
- Location precision must degrade safely when disabled.
- Injury, eligibility, and other sensitive factors must show why they matter and what fallback is used if disabled.
- Receipts must avoid leaking sensitive detail beyond what is necessary for user-owned inspection.
- Logs and proof artifacts must not contain private personal data.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B06 TEST=AmbitionsUITests
git diff --check
```

## Required proof artifacts
`build/reports/life-context/anti-bucket-factor-ledger-proof.md`

The proof artifact must include:
- Status: Green / Yellow / Red
- Branch and commit
- Commands run
- Commands not run
- Files changed
- Ledger object proof
- Factor type proof
- Receipt proof
- You inspection/control proof
- Test Group A result
- Test Group B result
- Test Group C result
- Test Group D result
- Test Group E result
- Test Group F result
- Accessibility status
- Privacy/local-first status
- Claims allowed
- Claims forbidden
- Yellow/Red items
- Rollback notes

## Green / Yellow / Red rules
Green requires:
- `PersonalizationFactorLedger` is first-class, inspectable, deterministic, and replayable.
- Required ledger fields and factor fields exist.
- Required factor types exist.
- No demographic-only factor can directly select a full plan.
- Required deterministic tests pass.
- Start Here explanations use real factors, user-owned context, constraints, and availability.
- `users like you` and stereotype explanations are absent from active user-facing recommendation copy.
- You -> Life Context exposes factor inspection and controls.
- Required receipts are source-present and covered by focused tests.
- Proof artifact is written.
- No false release/accessibility/privacy/performance/device/App Store claims.

Yellow is allowed only with owner, reason, no-claim boundary, and follow-up gate when environment or proof gaps block full validation but no hard Red condition is introduced.

Red conditions:
- Demographic-only recommendation templates.
- `users like you` language.
- Hidden profiling.
- Unexplained demographic optimization.
- Hardcoded bucket plans.
- Demographic factors outweigh direct lived constraints.
- Sensitive factors used without explicit permission.
- Factorless recommendations.
- Non-inspectable recommendation logic.
- Required cloud AI/LLM, hosted personal-data backend, analytics, tracking, or cloud profiling.
- Top-level IA changes.
- Release/accessibility/privacy/performance/device/TestFlight/App Store overclaim.

## Rollback strategy
Rollback only files touched by this batch. Preserve unrelated dirty work, generated logs, and existing Life Context source changes owned by other batches or threads.

If runtime source changes must be reverted, also revert matching tests, preview fixtures, receipts, and proof artifact updates from this batch only.

## Final report format
```text
Status: Green / Yellow / Red
Batch:
Train:
Scope:
Branch:
Commit:
Files changed:
Truth files inspected:
Source areas inspected:
Commands run:
Commands not run:
Environment:
Evidence:
PersonalizationFactorLedger status:
Factor types status:
Receipt status:
You surface status:
Test Group A:
Test Group B:
Test Group C:
Test Group D:
Test Group E:
Test Group F:
Accessibility status:
Privacy/local-first status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
----- END ORIGINAL PROMPT -----
