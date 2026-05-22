<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
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
