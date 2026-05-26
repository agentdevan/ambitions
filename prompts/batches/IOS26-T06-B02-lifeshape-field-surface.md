<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T06-B02 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T06-B02`

## Train ID and title
`TRAIN_06` - Time / LifeShape Field final object

## Batch role in train
Batch 2 of 3 in TRAIN_06

## Upstream dependencies
- `TRAIN_02`
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`
- `TRAIN_04C`
- `TRAIN_04D`
- `TRAIN_04K`
- `TRAIN_04L`

## Downstream dependencies
- none recorded

## Objective
Make LifeShape Field the dominant Time object.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, status board, chatbot, AI wrapper, SaaS admin panel, or ranking-based productivity framing.

## Local-first/privacy constraints
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## Accessibility constraints
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `time_root` owns Time / LifeShape under `Native/Ambitions/Features/Time` and `Native/Ambitions/Integrations/CalendarReminders`.
- `Native/Ambitions/Features/Plan` is superseded compatibility only; preserve legacy route compatibility without active Plan UI ownership.

## Allowed files/directories
Time UI/view model, capacity/reality models, tests/previews.

## Forbidden files/directories
No generic calendar grid clone. No KPI dashboard.

## Exact implementation steps
Promote LifeShape Field/capacity field to root; demote depth modules; connect capacity/recovery facts to traces; preserve Today relation.

## Object frontend expansion directives
- Install or infer `LifeShapeFieldSurface` as the Time root object.
- Rename or rebuild `TimeLifeShapeField` where active source evidence shows compatibility drift.
- Remove calendar-grid, agenda, card, dashboard, and equal-panel root architecture.
- Verify Time replaces reasons to open Calendar for life-shaping work without becoming a Calendar clone.
- Run `python3 scripts/ios26-anti-card-check.py --surface time --batch IOS26-T06-B02` and write the resulting frontend-object-purity proof reports.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
python3 scripts/ios26-anti-card-check.py --surface time --batch IOS26-T06-B02
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```

## Proof artifacts to write
build/reports/lifeshape-field/surface.md
build/reports/frontend-object-purity/IOS26-T06-B02-anti-card.md
build/reports/frontend-object-purity/IOS26-T06-B02-anti-card.json
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
- `build/reports/frontend-object-purity/`
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
Green: scoped changes complete, commands/proof recorded, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: forbidden source/runtime/project mutation outside scope, unverified API adoption, privacy/local-first breach, release/readiness overclaim, or missing required truth-file read.

## Rollback behavior
Revert only files touched by this batch. Do not use broad reset or discard unrelated work. Delete malformed generated reports if this is docs/proof only.

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
iOS 26 API verification status:
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
# IOS26-T06-B02 — LifeShape Field surface

## Batch type
Time UI/runtime integration

## Objective
Make LifeShape Field the dominant Time object.

## Why this exists
Time should represent capacity/reality/recovery, not a calendar clone.

## Dependencies
IOS26-T06-B01, Train 3, Train 4.

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
Time feature; Runtime; Services; tests.

## Exact changes allowed
Time UI/view model, capacity/reality models, tests/previews.

## Exact changes forbidden
No generic calendar grid clone. No KPI dashboard.

## Implementation steps
Promote LifeShape Field/capacity field to root; demote depth modules; connect capacity/recovery facts to traces; preserve Today relation.

## Tests to add/update
Time UI/runtime tests.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```

## Required proof artifacts
build/reports/lifeshape-field/surface.md

## Accessibility requirements
Classify source support separately from verified accessibility proof. Do not claim public accessibility verification unless current proof artifacts exist. Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, and Reduce Transparency expectations where UI is touched.

## Privacy/local-first requirements
No required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or silent personal-data mutation. Preserve local-first/on-device-first behavior and privacy manifest honesty.

## iOS 26 API verification requirements
Calendar clone/dashboard pattern is Red.

## Green / Yellow / Red closeout rules
Green: scoped changes complete, commands/proof recorded, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: forbidden source/runtime/project mutation outside scope, unverified API adoption, privacy/local-first breach, release/readiness overclaim, or missing required truth-file read.

## Rollback strategy
Revert only files touched by this batch. Do not use broad reset or discard unrelated work. Delete malformed generated reports if this is docs/proof only.

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
iOS 26 API verification status:
Claims allowed:
Claims forbidden:
Release blockers:
Post-batch gates:
Rollback:
Next eligible batch:
```
----- END ORIGINAL PROMPT -----
