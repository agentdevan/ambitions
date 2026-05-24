<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B02 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04A-B02`

## Train ID and title
`TRAIN_04A` - Life Context & Historical Catch-Up Runtime Inputs

## Batch role in train
Batch 2 of 6 in TRAIN_04A

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
Add a guided, non-chat, premium `Catch Me Up` flow so Ambitions can learn Life Context before planning without framing the user as a demographic profile.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent sensitive assumptions. Sensitive values must be hidden by default in external surfaces.

## Accessibility constraints
VoiceOver labels must expose source/freshness/control status where rows are visible. Dynamic Type must not collapse primary actions. Delete/pause/edit controls must be reachable without gestures. Do not claim verified accessibility unless current proof exists.

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
You-owned Life Context/Catch Me Up surfaces, optional onboarding entry after first goal creation, Capture Needs Review routing for background facts, tests, fixtures, and `build/reports/life-context/historical-catchup-intake.md`.

## Forbidden files/directories
No new top-level destination. No chat transcript UI. No generic admin data console. No silent runtime use of sensitive facts. No cloud AI, hosted backend, analytics SDK, or tracking dependency.

## Exact implementation steps
1. Inspect existing You, Capture, onboarding, receipt, and Life Context seams.
2. Add a You-owned `Catch Me Up` progressive disclosure flow under What Ambitions Knows -> Life Context.
3. Add optional first-goal/onboarding entry only if it preserves skip-without-blocking behavior.
4. Route Capture background facts to Needs Review context rather than silent runtime use.
5. Ensure every saved fact references or creates a receipt and can be edited, deleted, or paused.
6. Add unit/UI tests and write `build/reports/life-context/historical-catchup-intake.md`.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B02 TEST=AmbitionsUITests
git diff --check
```

## Proof artifacts to write
build/reports/life-context/historical-catchup-intake.md
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
Green: scoped flow/source/tests complete, commands/proof recorded, skip path works, sensitive runtime use requires explicit permission, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: profiling framing, hidden sensitive use, external AI/backend dependency, top-level IA change, release overclaim, or missing truth-file read.

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
# IOS26-T04A-B02 - Historical catch-up intake

## Batch type
You-owned intake and context review flow

## Objective
Add a guided, non-chat, premium `Catch Me Up` flow so Ambitions can learn Life Context before planning without framing the user as a demographic profile.

## Why this exists
Ambitions needs a calm way to get caught up on life history, constraints, opportunities, and older facts before the Private Life Runtime uses them.

## Dependencies
IOS26-T04A-B01.

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
Native/Ambitions/Features/You/; Native/Ambitions/Features/Captures/; Native/Ambitions/Features/Goals/; Life Context domain/repository from IOS26-T04A-B01; receipt models; You tests; Capture routing tests.

## Exact changes allowed
You-owned Life Context/Catch Me Up surfaces, optional onboarding entry after first goal creation, Capture Needs Review routing for background facts, tests, fixtures, and `build/reports/life-context/historical-catchup-intake.md`.

## Exact changes forbidden
No new top-level destination. No chat transcript UI. No generic admin data console. No silent runtime use of sensitive facts. No cloud AI, hosted backend, analytics SDK, or tracking dependency.

## Implementation steps
1. Inspect existing You, Capture, onboarding, receipt, and Life Context seams.
2. Add a You-owned `Catch Me Up` progressive disclosure flow under What Ambitions Knows -> Life Context.
3. Add optional first-goal/onboarding entry only if it preserves skip-without-blocking behavior.
4. Route Capture background facts to Needs Review context rather than silent runtime use.
5. Ensure every saved fact references or creates a receipt and can be edited, deleted, or paused.
6. Add unit/UI tests and write `build/reports/life-context/historical-catchup-intake.md`.

## Placement
- You -> What Ambitions Knows -> Life Context.
- Optional onboarding entry after first goal creation.
- Capture may route relevant background facts into Needs Review context, not silently into runtime.

## Flow name
Catch Me Up

## Flow must collect
- birthday or exact age
- life stage
- school/work status
- general location / timezone
- transportation access
- travel comfort/radius
- facilities available
- equipment available
- prior experience
- prior attempts
- blockers/injuries/limitations
- important deadlines/windows
- local opportunities
- things Ambitions should not assume
- things that are old and may need review

## UX rules
- Progressive disclosure.
- No dense form wall.
- No "demographic profile" framing.
- Use "Life Context," "What Ambitions Knows," "Catch Me Up," and "Used to plan better."
- Sensitive fields explain why they matter.
- Sex/eligibility context appears only when a goal/pathway makes it materially relevant or the user chooses to add it.
- For minors, include dependency/guardian/travel constraints without legal overclaiming.
- Every saved fact produces or references a receipt.
- Every fact can be edited, deleted, or paused.

## Required copy examples
- "Ambitions uses this to fit steps to your real life."
- "This can change timelines, travel assumptions, and opportunity paths."
- "You can edit or remove this anytime."
- "Older context may need review before it shapes recommendations."

## Tests to add/update
- Catch-up answers become HistoricalContextFacts.
- Sensitive facts require explicit runtimeUseAllowed true.
- Deleted/paused facts do not affect projection.
- Older facts get freshness labels.
- Flow can be skipped without blocking app use.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B02 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B02 TEST=AmbitionsUITests
git diff --check
```

## Required proof artifacts
build/reports/life-context/historical-catchup-intake.md

## Accessibility requirements
VoiceOver labels must expose source/freshness/control status where rows are visible. Dynamic Type must not collapse primary actions. Delete/pause/edit controls must be reachable without gestures. Do not claim verified accessibility unless current proof exists.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent sensitive assumptions. Sensitive values must be hidden by default in external surfaces.

## iOS 26 API verification requirements
Use native SwiftUI controls and platform accessibility APIs already present in the app. If new iOS 26 APIs are adopted, record current source proof and non-claims in the proof artifact.

## Green / Yellow / Red closeout rules
Green: scoped flow/source/tests complete, commands/proof recorded, skip path works, sensitive runtime use requires explicit permission, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: profiling framing, hidden sensitive use, external AI/backend dependency, top-level IA change, release overclaim, or missing truth-file read.

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
