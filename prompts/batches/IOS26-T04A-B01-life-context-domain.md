<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B01 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04A-B01`

## Train ID and title
`TRAIN_04A` - Life Context & Historical Catch-Up Runtime Inputs

## Batch role in train
Batch 1 of 6 in TRAIN_04A

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
Install durable local-first domain models for Life Context, Eligibility Pathways, Opportunity Context, Historical Context Facts, Context Sources, and Life Context Runtime Projection.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
Must be local-only. Must not require cloud AI, hosted backend, analytics SDK, tracking SDK, or sensitive logs. Document local-first invariants in the proof artifact.

## Accessibility constraints
No UI is expected in this batch. Classify accessibility as source support only unless UI is touched and current proof exists.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `private_life_runtime` owns life-context runtime inputs that affect recommendations.
- `you_root` owns user inspection/reset/delete controls under `Native/Ambitions/Features/You`; focused XCTest proof remains Yellow until rerun after simulator repair.

## Allowed files/directories
Domain models/contracts, repository or persistence adapter extension, tests, fixtures, and `build/reports/life-context/domain.md`.

## Forbidden files/directories
No UI changes. No top-level IA changes. No cloud AI, hosted backend, analytics SDK, or tracking dependency. No sensitive-value logging. No migration-unsafe persistence change.

## Exact implementation steps
1. Inspect existing runtime, compiler, receipt, and persistence seams before adding types.
2. Add typed Life Context value models and source/freshness/control enums.
3. Add or extend a local repository/persistence path without cloud or sensitive logging.
4. Add deterministic fixture profiles for the five required contexts.
5. Add unit tests proving persistence/reload/update/delete or mark-deleted behavior and projection safety.
6. Write `build/reports/life-context/domain.md` with local-first and proof boundaries.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B01 TEST=AmbitionsTests
git diff --check
```

## Proof artifacts to write
build/reports/life-context/domain.md
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
Green: models compile, persistence/repository path exists or accepted existing repository extension exists, tests prove save/load/update/delete or mark deleted, no sensitive logs, local-first invariant documented.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: cloud/LLM/backend dependency, sensitive logs, hidden sensitive inference, persistence-unsafe mutation, release overclaim, or missing truth-file read.

## Rollback behavior
Revert only files touched by this batch. Preserve unrelated dirty work.

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
Passes:
Failures:
Skipped:
Unproven:
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
# IOS26-T04A-B01 - Life context domain

## Batch type
Domain/runtime life-context foundation

## Objective
Install durable local-first domain models for Life Context, Eligibility Pathways, Opportunity Context, Historical Context Facts, Context Sources, and Life Context Runtime Projection.

## Why this exists
The Private Life Runtime needs user-owned real-world context and pre-download history to plan from reality instead of generic goal decomposition.

## Dependencies
TRAIN_03 and TRAIN_04.

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
Native/Ambitions/Domain/; Native/Ambitions/Persistence/; Private Life Runtime models; Goal intent compiler models; receipt/history models; Domain/Persistence tests.

## Exact changes allowed
Domain models/contracts, repository or persistence adapter extension, tests, fixtures, and `build/reports/life-context/domain.md`.

## Exact changes forbidden
No UI changes. No top-level IA changes. No cloud AI, hosted backend, analytics SDK, or tracking dependency. No sensitive-value logging. No migration-unsafe persistence change.

## Implementation steps
1. Inspect existing runtime, compiler, receipt, and persistence seams before adding types.
2. Add typed Life Context value models and source/freshness/control enums.
3. Add or extend a local repository/persistence path without cloud or sensitive logging.
4. Add deterministic fixture profiles for the five required contexts.
5. Add unit tests proving persistence/reload/update/delete or mark-deleted behavior and projection safety.
6. Write `build/reports/life-context/domain.md` with local-first and proof boundaries.

## Models to install or extend
LifeContextProfile:
- id
- birthdate or exactAgeYears, with source
- ageLastConfirmedAt
- timezone
- locale
- generalLocationLabel
- locationPrecision: none / timezone / cityRegion / userEnteredPlace / precisePermissioned
- sexOrEligibilityContext: optional, user-provided, purpose-limited
- lifeStage: middleSchool / highSchool / college / earlyCareer / adult / parent / caregiver / custom / unknown
- schoolOrWorkContext
- travelRadiusMinutes
- travelRadiusMiles
- transportationAccess: walk / bike / transit / rideshare / car / parentGuardian / limited / custom
- scheduleAnchors
- dependencyConstraints
- budgetConstraintBand
- energyPattern
- recoveryConstraints
- accessibilityNeeds
- userNotes

EligibilityPathway:
- pathwayType: sport / academic / career / creative / health / finance / custom
- eligibilityRulesSummary
- ageWindow
- gradeWindow
- sexLeaguePathway where materially relevant
- locationDependent
- source
- freshness
- userConfirmed

OpportunityContext:
- facilities: YMCA, gym, field, court, studio, library, school, park, trail, rink, pool, maker space, etc.
- equipmentAccess
- coachingMentorAccess
- localOrganizations
- eventExposureAccess
- remoteAccess
- travelRequirement
- costRequirement
- seasonalAvailability
- verificationStatus

HistoricalContextFact:
- category: priorExperience / priorAttempt / pastAchievement / injuryLimitation / trainingHistory / educationHistory / workHistory / creativeCatalog / financialBaseline / healthBaseline / relationshipDependency / locationHistory / custom
- title
- detail
- dateRange
- confidence
- sourceType: userToldAmbitions / imported / inferredFromLocalAction / correctedByUser / deleted / paused
- freshness: current / mayNeedReview / basedOnOlderContext / stale
- sensitivity: normal / sensitive / highlySensitive
- runtimeUseAllowed: bool
- usedFor: feasibility / sequencing / safety / eligibility / opportunity / recovery / duration / travel / explanation
- createdAt
- updatedAt
- confirmedAt
- deletedAt optional

ContextSource:
- source label
- user confirmed / imported / inferred / corrected
- timestamp
- visible explanation
- canDelete
- canPause
- canEdit

LifeContextRuntimeProjection:
- ageYears
- lifeStage
- availableOpportunityAnchors
- hardConstraints
- softConstraints
- travelModel
- eligibilityModel
- historySummary
- sourceFreshnessSummary
- sensitiveUseWarnings
- missingContextQuestions

## Fixture profiles required
1. 14-year-old varsity football goal, small town, parent transportation, YMCA.
2. 16-year-old varsity football goal, compressed timeline, school weight room.
3. Woman pursuing professional basketball, WNBA pathway.
4. Adult mountain biking goal, no nearby trails, limited travel radius.
5. User with no historical context yet.

## Tests to add/update
- Save/load/update/delete or mark-deleted behavior.
- Projection excludes deleted or paused facts.
- Sensitive fields require explicit runtime-use permission.
- Fixture profiles produce typed projections without string-only runtime logic.
- No sensitive values are logged.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B01 TEST=AmbitionsTests
git diff --check
```

## Required proof artifacts
build/reports/life-context/domain.md

## Accessibility requirements
No UI is expected in this batch. Classify accessibility as source support only unless UI is touched and current proof exists.

## Privacy/local-first requirements
Must be local-only. Must not require cloud AI, hosted backend, analytics SDK, tracking SDK, or sensitive logs. Document local-first invariants in the proof artifact.

## iOS 26 API verification requirements
No new iOS 26 API adoption is required. If implementation touches new platform APIs, record source proof and fallback/posture in the proof artifact.

## Green / Yellow / Red closeout rules
Green: models compile, persistence/repository path exists or accepted existing repository extension exists, tests prove save/load/update/delete or mark deleted, no sensitive logs, local-first invariant documented.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: cloud/LLM/backend dependency, sensitive logs, hidden sensitive inference, persistence-unsafe mutation, release overclaim, or missing truth-file read.

## Rollback strategy
Revert only files touched by this batch. Preserve unrelated dirty work.

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
Passes:
Failures:
Skipped:
Unproven:
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
