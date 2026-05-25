<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B04 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04A-B04`

## Train ID and title
`TRAIN_04A` - Life Context & Historical Catch-Up Runtime Inputs

## Batch role in train
Batch 4 of 6 in TRAIN_04A

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
Make Life Context inspectable and controllable in You, install receipt types, and close TRAIN_04A with honest proof boundaries.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
- Sensitive values hidden by default in external surfaces.
- Widgets/Live Activities/App Intents must not show sensitive context.
- No sensitive facts in logs.
- No analytics SDK.
- No cloud requirement.

## Accessibility constraints
- VoiceOver reads source/freshness/control status.
- No color-only freshness.
- Dynamic Type supported.
- Reduce Motion safe.
- Delete/disable controls are reachable without gestures.
- Do not claim verified accessibility unless current proof exists.

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
You -> What Ambitions Knows -> Life Context sections and fact rows, receipt types, Today explanation inputs for used/needs-review/not-used context summaries, tests, privacy guards for external surfaces, `build/reports/life-context/you-controls-receipts.md`, and `build/reports/life-context/TRAIN_04A_CLOSEOUT.md`.

## Forbidden files/directories
No new top-level destination. No generic admin data console. No sensitive values in external surfaces, logs, widgets, Live Activities, or App Intents. No analytics SDK. No cloud requirement.

## Exact implementation steps
1. Inspect existing You settings/profile, Life Context projection, receipt, Today explanation, and external surface privacy seams.
2. Add Life Context sections and fact rows under You -> What Ambitions Knows -> Life Context.
3. Add receipt types and replayable state changes for add/correct/pause/delete/use/import/confirm/older/pathway/travel/facility changes.
4. Add Today explanation summaries for used, needs-review, and not-used context.
5. Add external-surface privacy guards for sensitive context.
6. Add tests and write both required proof artifacts, including the train closeout.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B04 TEST=AmbitionsUITests
git diff --check
```

## Proof artifacts to write
- build/reports/life-context/you-controls-receipts.md
- build/reports/life-context/TRAIN_04A_CLOSEOUT.md
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
Green: controls, receipts, tests, proof artifacts, and train closeout complete with no forbidden claims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: hidden sensitive use, external sensitive leak, analytics/cloud dependency, top-level IA change, release overclaim, or missing truth-file read.

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
# IOS26-T04A-B04 - You controls and receipts

## Batch type
You controls, receipts, privacy, and train closeout

## Objective
Make Life Context inspectable and controllable in You, install receipt types, and close TRAIN_04A with honest proof boundaries.

## Why this exists
Life Context can only affect recommendations safely if users can inspect what Ambitions knows, see source/freshness/use, pause or delete facts, and understand why recommendations changed.

## Dependencies
IOS26-T04A-B01, IOS26-T04A-B02, and IOS26-T04A-B03.

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
Native/Ambitions/Features/You/; Life Context domain/repository/projection; receipt models; Today Start Here explanations; widgets/live activities/app intents/share extension privacy boundaries; You tests; UI tests.

## Exact changes allowed
You -> What Ambitions Knows -> Life Context sections and fact rows, receipt types, Today explanation inputs for used/needs-review/not-used context summaries, tests, privacy guards for external surfaces, `build/reports/life-context/you-controls-receipts.md`, and `build/reports/life-context/TRAIN_04A_CLOSEOUT.md`.

## Exact changes forbidden
No new top-level destination. No generic admin data console. No sensitive values in external surfaces, logs, widgets, Live Activities, or App Intents. No analytics SDK. No cloud requirement.

## Implementation steps
1. Inspect existing You settings/profile, Life Context projection, receipt, Today explanation, and external surface privacy seams.
2. Add Life Context sections and fact rows under You -> What Ambitions Knows -> Life Context.
3. Add receipt types and replayable state changes for add/correct/pause/delete/use/import/confirm/older/pathway/travel/facility changes.
4. Add Today explanation summaries for used, needs-review, and not-used context.
5. Add external-surface privacy guards for sensitive context.
6. Add tests and write both required proof artifacts, including the train closeout.

## You sections
- Basics
- Schedule & Availability
- Travel & Access
- Facilities & Equipment
- Eligibility Pathways
- Historical Context
- Needs Review
- Paused / Not Used
- Receipts

## Each fact row must show
- fact title
- source
- freshness
- whether it affects runtime
- where it is used
- edit
- pause
- delete
- review/confirm

## Receipt types to add
- lifeContextAdded
- lifeContextCorrected
- lifeContextPaused
- lifeContextDeleted
- lifeContextUsedInRecommendation
- historicalContextImported
- historicalContextConfirmed
- historicalContextMarkedOlder
- eligibilityPathwayChanged
- travelConstraintChanged
- facilityAccessChanged

## Start Here / Today explanation support
Start Here / Today explanation must be able to say:
- "Used: travel radius, available facility, tryout date."
- "Needs review: older training history."
- "Not used: paused injury note."

## Tests to add/update
- Fact rows expose source, freshness, runtime-use state, and controls.
- Edit/pause/delete/review actions update projection and receipts.
- Receipt types are created and replayable.
- Sensitive values are hidden by default in external surfaces.
- Widgets/Live Activities/App Intents do not show sensitive context.
- VoiceOver reads source/freshness/control status.
- Delete/disable controls are reachable without gestures.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B04 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B04 TEST=AmbitionsUITests
git diff --check
```

## Required proof artifacts
- build/reports/life-context/you-controls-receipts.md
- build/reports/life-context/TRAIN_04A_CLOSEOUT.md

## Privacy/local-first requirements
- Sensitive values hidden by default in external surfaces.
- Widgets/Live Activities/App Intents must not show sensitive context.
- No sensitive facts in logs.
- No analytics SDK.
- No cloud requirement.

## Accessibility requirements
- VoiceOver reads source/freshness/control status.
- No color-only freshness.
- Dynamic Type supported.
- Reduce Motion safe.
- Delete/disable controls are reachable without gestures.
- Do not claim verified accessibility unless current proof exists.

## iOS 26 API verification requirements
Use native SwiftUI controls and platform accessibility APIs already present in the app. If new iOS 26 APIs are adopted, record current source proof and non-claims in the proof artifacts.

## Train-level closeout requirements
`build/reports/life-context/TRAIN_04A_CLOSEOUT.md` must include:
- Status: Green / Yellow / Red
- Batches completed
- Files changed
- Runtime models added
- Persistence proof
- Catch-up flow proof
- Scenario proof
- You controls proof
- Privacy/local-first proof
- Accessibility support status
- Known gaps
- Claims allowed
- Claims forbidden
- Next train eligibility

## Claims allowed only if Green
- "Ambitions has a local-first Life Context layer."
- "Life Context can affect runtime recommendations."
- "Historical context can be captured, reviewed, corrected, and excluded."
- "The same goal can produce different plans for different life contexts."

## Claims forbidden unless proven
- "Perfect plans"
- "Verified accessibility"
- "Production-ready App Store context system"
- "Fully accurate local opportunity discovery"
- "Medical, legal, recruiting, or professional advice"
- "Automatic demographic optimization"

## Green / Yellow / Red closeout rules
Green: controls, receipts, tests, proof artifacts, and train closeout complete with no forbidden claims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: hidden sensitive use, external sensitive leak, analytics/cloud dependency, top-level IA change, release overclaim, or missing truth-file read.

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
