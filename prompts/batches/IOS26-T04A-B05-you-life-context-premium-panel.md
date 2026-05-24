<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04A-B05 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04A-B05`

## Train ID and title
`TRAIN_04A` - Life Context & Historical Catch-Up Runtime Inputs

## Batch role in train
Batch 5 of 6 in TRAIN_04A

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
Install a first-class premium You surface for Life Context so users have an obvious, polished place to tell Ambitions what it should know about real life before planning from reality.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
- No required cloud AI/LLM, hosted personal-data backend, analytics SDK, tracking SDK, or sensitive logs.
- Life Context is local-first and user-owned.
- Sensitive fields must explain why they matter before use.
- Sensitive pathway context is only used when explicitly allowed.
- Capture-suggested sensitive context must route to review before runtime use.
- External surfaces must not expose sensitive Life Context values.

## Accessibility constraints
- VoiceOver must read panel purpose, section names, source, freshness, runtime use status, and available controls.
- No color-only freshness or runtime-use state.
- Dynamic Type must preserve the hero CTAs and section affordances.
- Reduce Motion must preserve state and disclosure meaning.
- Edit, pause, delete, and confirm/review controls must be reachable without custom gestures.
- Do not claim verified accessibility unless current proof artifacts exist.

## Performance constraints when relevant
Add measured performance evidence for any changed hot path, launch path, persistence path, or visual effect. If no measurement is possible, close Yellow with owner, reason, no-claim boundary, and follow-up gate.

## Allowed files/directories
- You Life Context UI
- Life Context panel view models
- Life Context persistence hooks
- Life Context runtime projection display
- Catch Me Up route entry
- tests/previews/proof artifacts

## Forbidden files/directories
- No top-level IA changes.
- No new sixth tab.
- No cloud dependency.
- No LLM dependency.
- No hidden demographic profiling.
- No sensitive data in logs.
- No generic admin/settings wall.
- No blocking onboarding requirement.
- No unverified App Store, privacy, accessibility, performance, device, TestFlight, or release claims.

## Exact implementation steps
1. Inspect existing You, Life Context, Catch Me Up, receipt, persistence, runtime projection, and Today explanation seams.
2. Add a first-class `You -> Life Context` panel that is impossible to miss without adding a new top-level destination.
3. Build a premium first viewport with:
   - title: `Life Context`
   - primary line: `Help Ambitions plan from your real life.`
   - supporting line: `Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.`
   - primary CTA: `Catch me up`
   - secondary CTA: `Review what Ambitions knows`
4. Add progressive, grouped native iOS sections for Basics, Schedule & Availability, Travel & Access, Facilities & Equipment, Eligibility & Pathways, History, Constraints, and Review Needed.
5. Ensure every fact row shows source, freshness, runtime used/not-used state, where it affects recommendations, and edit/pause/delete/confirm-review controls.
6. Wire the panel to existing Life Context projection and receipts so it is not decorative.
7. Preserve optional setup: users can skip without blocking app use and add context later from You.
8. Add tests/previews/proof artifact without claiming app implementation beyond current evidence.

## Validation commands
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B05 TEST=AmbitionsUITests
git diff --check
```

## Proof artifacts to write
build/reports/life-context/you-life-context-premium-panel.md
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
Green: first-class You Life Context panel exists, required hero/sections/fact rows/controls are implemented, runtime connection tests prove non-decorative behavior, commands/proof recorded, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: top-level IA change, sixth tab, cloud/LLM dependency, hidden demographic profiling, sensitive data in logs, generic admin/settings wall, blocking onboarding, fake runtime connection, release overclaim, or missing truth-file read.

## Rollback behavior
Revert only files touched by this batch. Preserve unrelated dirty work. Do not broad reset. Remove malformed proof artifacts if the batch does not complete.

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
# IOS26-T04A-B05 - You Life Context Premium Personalization Panel

## Batch type
You premium personalization surface and Life Context control panel

## Objective
Install a first-class premium You surface for Life Context so users have an obvious, polished place to tell Ambitions what it should know about real life before planning from reality.

## Why this exists
Life Context cannot live only as backend runtime data or buried memory controls. Users need a clear, premium place to fill out the information Ambitions needs to plan from reality.

This surface is a moat object:

```text
You -> Life Context
```

It answers:

```text
What should Ambitions know about my real life so it can plan better?
```

## Dependencies
IOS26-T04A-B01, IOS26-T04A-B02, IOS26-T04A-B03, and IOS26-T04A-B04.

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
- `Native/Ambitions/Features/You/`
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Goals/`
- `Native/Ambitions/Features/Today/`
- Runtime
- Persistence
- Services
- `Sources/Theme/`
- `Native/AmbitionsTests/`
- `Native/AmbitionsUITests/`

## Exact changes allowed
- You Life Context UI
- Life Context panel view models
- Life Context persistence hooks
- Life Context runtime projection display
- Catch Me Up route entry
- tests/previews/proof artifacts

## Exact changes forbidden
- No top-level IA changes.
- No new sixth tab.
- No cloud dependency.
- No LLM dependency.
- No hidden demographic profiling.
- No sensitive data in logs.
- No generic admin/settings wall.
- No blocking onboarding requirement.
- No unverified App Store, privacy, accessibility, performance, device, TestFlight, or release claims.

## Implementation steps
1. Inspect existing You, Life Context, Catch Me Up, receipt, persistence, runtime projection, and Today explanation seams.
2. Add a first-class `You -> Life Context` panel that is impossible to miss without adding a new top-level destination.
3. Build a premium first viewport with:
   - title: `Life Context`
   - primary line: `Help Ambitions plan from your real life.`
   - supporting line: `Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.`
   - primary CTA: `Catch me up`
   - secondary CTA: `Review what Ambitions knows`
4. Add progressive, grouped native iOS sections for Basics, Schedule & Availability, Travel & Access, Facilities & Equipment, Eligibility & Pathways, History, Constraints, and Review Needed.
5. Ensure every fact row shows source, freshness, runtime used/not-used state, where it affects recommendations, and edit/pause/delete/confirm-review controls.
6. Wire the panel to existing Life Context projection and receipts so it is not decorative.
7. Preserve optional setup: users can skip without blocking app use and add context later from You.
8. Add tests/previews/proof artifact without claiming app implementation beyond current evidence.

## Required product outcome
After this batch eventually runs, You must contain a first-class Life Context panel with:

Hero:
- title: `Life Context`
- primary line: `Help Ambitions plan from your real life.`
- supporting line: `Age, schedule, travel, access, history, and constraints help Ambitions make plans that actually fit.`
- primary CTA: `Catch me up`
- secondary CTA: `Review what Ambitions knows`

Required visible sections:
1. Basics
   - age / birthday
   - life stage
   - timezone
   - general location
   - school/work context
2. Schedule & Availability
   - work/school anchors
   - recurring commitments
   - protected time
   - flexible windows
   - recovery defaults
3. Travel & Access
   - transportation access
   - travel radius
   - commute tolerance
   - parent/guardian dependency where relevant
   - mobility constraints where relevant
4. Facilities & Equipment
   - gyms
   - YMCA
   - fields/courts/trails/studios/libraries
   - equipment owned
   - equipment needed
   - seasonal/access limits
5. Eligibility & Pathways
   - sport pathway
   - school pathway
   - career pathway
   - creative pathway
   - age/grade/league constraints
   - sex/eligibility context only where materially relevant and user-controlled
6. History
   - prior experience
   - prior attempts
   - past achievements
   - old progress
   - injuries/limitations
   - already-tried approaches
   - older facts needing review
7. Constraints
   - budget
   - energy
   - family/caregiver dependencies
   - accessibility needs
   - recovery needs
   - `do not assume` notes
8. Review Needed
   - stale facts
   - imported facts
   - inferred facts
   - sensitive facts awaiting confirmation

Each fact row must show:
- source
- freshness
- used/not used in runtime
- where it affects recommendations
- edit
- pause
- delete
- confirm/review

## UX rules
- This must not look like a generic settings form.
- This must not become a dense admin panel.
- Use progressive disclosure.
- Use grouped native iOS structure where appropriate.
- Preserve premium Ambitions visual language.
- Keep first viewport simple and obvious.
- Sensitive fields must explain why they matter.
- Missing context must feel like optional setup, not failure.
- User can skip without blocking the app.
- User can add context later from You.
- Capture can suggest saving life context facts, but runtime use requires review where sensitive.

## Required runtime connection
This panel must not be decorative.

The eventual implementation must prove:
- changing age/life stage can change generated plans
- changing travel radius can change recommended steps
- adding/removing facility access can change opportunity-aware steps
- pausing historical context removes it from recommendation inputs
- older context appears as `Needs Review` before being trusted
- sensitive pathway context is only used when explicitly allowed

## Tests to add/update
- You shows a first-class Life Context panel and hero CTAs.
- Required sections render without a dense admin/settings wall.
- Fact rows expose source, freshness, runtime used/not-used state, recommendation impact, and edit/pause/delete/confirm-review controls.
- Missing context is optional and does not block app use.
- Catch Me Up route entry opens from the panel.
- Review what Ambitions knows opens inspectable Life Context facts.
- Capture-suggested context routes to review before sensitive runtime use.
- Runtime proof tests assert age/life stage, travel radius, facility access, paused history, older context, and sensitive pathway permission affect or withhold recommendation inputs as required.

## Commands to run
```bash
xcodegen generate
scripts/build-local.sh
make xcode-focused-test BATCH=IOS26-T04A-B05 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04A-B05 TEST=AmbitionsUITests
git diff --check
```

## Required proof artifacts
build/reports/life-context/you-life-context-premium-panel.md

## Accessibility requirements
- VoiceOver must read panel purpose, section names, source, freshness, runtime use status, and available controls.
- No color-only freshness or runtime-use state.
- Dynamic Type must preserve the hero CTAs and section affordances.
- Reduce Motion must preserve state and disclosure meaning.
- Edit, pause, delete, and confirm/review controls must be reachable without custom gestures.
- Do not claim verified accessibility unless current proof artifacts exist.

## Privacy/local-first requirements
- No required cloud AI/LLM, hosted personal-data backend, analytics SDK, tracking SDK, or sensitive logs.
- Life Context is local-first and user-owned.
- Sensitive fields must explain why they matter before use.
- Sensitive pathway context is only used when explicitly allowed.
- Capture-suggested sensitive context must route to review before runtime use.
- External surfaces must not expose sensitive Life Context values.

## iOS 26 API verification requirements
Use native SwiftUI and iOS accessibility APIs already present in the app where possible. If new iOS 26 APIs are adopted, record current source proof, fallback posture, and non-claims in the proof artifact.

## Green / Yellow / Red closeout rules
Green: first-class You Life Context panel exists, required hero/sections/fact rows/controls are implemented, runtime connection tests prove non-decorative behavior, commands/proof recorded, no forbidden edits or overclaims.
Yellow: environment/proof gaps are explicit, owner/gate recorded, no release/privacy/accessibility/performance/device/App Store claim is made.
Red: top-level IA change, sixth tab, cloud/LLM dependency, hidden demographic profiling, sensitive data in logs, generic admin/settings wall, blocking onboarding, fake runtime connection, release overclaim, or missing truth-file read.

## Rollback strategy
Revert only files touched by this batch. Preserve unrelated dirty work. Do not broad reset. Remove malformed proof artifacts if the batch does not complete.

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
