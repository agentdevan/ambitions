<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B03 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04A-B03`

## Train ID and title
`TRAIN_04A` - Life Context & Historical Catch-Up Runtime Inputs

## Batch role in train
Batch 3 of 6 in TRAIN_04A

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
Prove Life Context changes actual Private Life Runtime output, not only UI copy or static reports.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or hidden sensitive assumptions. Sensitive context must be visible, editable, deletable, and purpose-limited.

## Accessibility constraints
Classify accessibility as source support unless UI explanation surfaces are touched. If UI is touched, preserve VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, and non-color-only state.

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
Runtime/domain/compiler integration, deterministic fixtures/tests, Today/Time explanation input adapters only where required, receipt/replay proof needed for runtime-difference scenarios, and `build/reports/life-context/runtime-effect-proof.md`.

## Forbidden files/directories
No fake UI-only proof. No stereotype language. No external AI, hosted backend, analytics SDK, or tracking dependency. No sensitive-detail exposure beyond the visible reason needed. No broad UI recomposition.

## Exact implementation steps
1. Inspect Life Context projection, compiler, recommendation, capacity, recovery, Today explanation, and replay seams.
2. Wire LifeContextRuntimeProjection into runtime decision inputs using typed fields, not fragile string-only logic.
3. Add deterministic fixture scenarios A through E.
4. Assert actual output differences in compiler/recommendation/Start Here outputs.
5. Add replay/receipt proof for paused/deleted context changing output.
6. Write `build/reports/life-context/runtime-effect-proof.md`.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B03 TEST=AmbitionsTests
git diff --check
```

## Proof artifacts to write
build/reports/life-context/runtime-effect-proof.md
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
Green: deterministic tests pass, context changes output, missing context does not crash, deleted/paused context excluded, source/freshness appears in proof.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: fake UI-only proof, stereotype language, hidden sensitive use, external AI/backend dependency, release overclaim, or missing truth-file read.

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
# IOS26-T04A-B03 - Runtime effect proof

## Batch type
Private Life Runtime integration and deterministic proof

## Objective
Prove Life Context changes actual Private Life Runtime output, not only UI copy or static reports.

## Why this exists
The moat is reality-aware execution: the same goal should produce different inspectable daily plans for different user-owned life contexts.

## Dependencies
IOS26-T04A-B01 and IOS26-T04A-B02.

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
Life Context domain/repository/projection; Goal intent compiler; recommendation candidate generation; feasibility scoring; capacity planning; travel/time-fit estimation; opportunity-aware step generation; recovery planning; Today Start Here explanation inputs; Time/LifeShape capacity proof where safe; runtime tests.

## Exact changes allowed
Runtime/domain/compiler integration, deterministic fixtures/tests, Today/Time explanation input adapters only where required, receipt/replay proof needed for runtime-difference scenarios, and `build/reports/life-context/runtime-effect-proof.md`.

## Exact changes forbidden
No fake UI-only proof. No stereotype language. No external AI, hosted backend, analytics SDK, or tracking dependency. No sensitive-detail exposure beyond the visible reason needed. No broad UI recomposition.

## Implementation steps
1. Inspect Life Context projection, compiler, recommendation, capacity, recovery, Today explanation, and replay seams.
2. Wire LifeContextRuntimeProjection into runtime decision inputs using typed fields, not fragile string-only logic.
3. Add deterministic fixture scenarios A through E.
4. Assert actual output differences in compiler/recommendation/Start Here outputs.
5. Add replay/receipt proof for paused/deleted context changing output.
6. Write `build/reports/life-context/runtime-effect-proof.md`.

## Wire LifeContextRuntimeProjection into
- Goal intent compiler
- recommendation candidate generation
- feasibility scoring
- capacity planning
- travel/time-fit estimation
- opportunity-aware step generation
- recovery planning
- Today Start Here explanation inputs
- Time/LifeShape capacity proof where safe

## Required deterministic proof scenarios
Scenario A:
Same goal: "Make varsity football."
User 1: age 14, freshman, 4-year runway, YMCA, parent rides 3 days/week.
User 2: age 16, junior, 1-year runway, school weight room, limited offseason.
Expected:
- Different milestones
- Different urgency
- Different weekly cadence
- Different Start Here step
- Different explanation

Scenario B:
Same goal: "Play professional basketball."
User 1: woman, high school player, WNBA pathway relevant.
User 2: male pathway context.
Expected:
- Different pathway labels where relevant
- Different exposure/recruiting assumptions
- No stereotype language
- Eligibility/pathway reason appears in explanation

Scenario C:
Same goal: "Start mountain biking weekly."
User 1: small town, trail 15 minutes away, has bike.
User 2: city, no nearby trails, no bike, travel radius 20 minutes.
Expected:
- User 1 gets ride/trail step.
- User 2 gets equipment/location discovery or indoor conditioning step.
- Travel feasibility changes plan.

Scenario D:
Same goal with historical context:
User has prior failed attempt, injury limitation, and older context marked May Need Review.
Expected:
- Plan is more conservative.
- Recovery/confirmation appears.
- Older context is not treated as current fact without review.

Scenario E:
Deleted/paused context:
A fact previously affected recommendations, then user pauses it.
Expected:
- Runtime output changes.
- Receipt records the change.
- Replay explains difference.

## Tests to add/update
- Deterministic tests assert actual plan/recommendation differences.
- Missing context does not crash and degrades gracefully.
- Deleted/paused context is excluded.
- Source/freshness appears in proof.
- Explanations include why context mattered without exposing sensitive details unnecessarily.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B03 TEST=AmbitionsTests
git diff --check
```

## Required proof artifacts
build/reports/life-context/runtime-effect-proof.md

## Accessibility requirements
Classify accessibility as source support unless UI explanation surfaces are touched. If UI is touched, preserve VoiceOver, Dynamic Type, Reduce Motion, Increase Contrast, and non-color-only state.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or hidden sensitive assumptions. Sensitive context must be visible, editable, deletable, and purpose-limited.

## iOS 26 API verification requirements
No new iOS 26 API adoption is required for runtime proof. If touched UI adapters use new APIs, record current source proof and non-claims in the proof artifact.

## Green / Yellow / Red closeout rules
Green: deterministic tests pass, context changes output, missing context does not crash, deleted/paused context excluded, source/freshness appears in proof.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: fake UI-only proof, stereotype language, hidden sensitive use, external AI/backend dependency, release overclaim, or missing truth-file read.

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
