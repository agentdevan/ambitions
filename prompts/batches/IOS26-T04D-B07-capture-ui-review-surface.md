<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T04D-B07 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T04D-B07`

## Train ID and title
`TRAIN_04D` - Capture-to-Runtime Factoring & Future Proof Bridge

## Batch role in train
Batch 7 of 7 in TRAIN_04D

## Upstream dependencies
- `TRAIN_03`
- `TRAIN_04`
- `TRAIN_04A`
- `TRAIN_04B`
- `TRAIN_04C`

## Downstream dependencies
- `TRAIN_04E`
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_07`
- `TRAIN_08`

## Objective
Expose capture factoring in the UI without turning Capture into an admin inbox.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
UI must reveal what was detected, what may be used, and what is not used. Sensitive details must be redacted where needed and must not appear in logs/external surfaces.

## Accessibility constraints
VoiceOver must read detected meaning, destination, and approval options. Dynamic Type must preserve controls. Reduce Motion must not remove relationship or approval meaning. Status must not be color-only.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Allowed files/directories
- Add a Capture result sheet or receipt state.
- Show what Ambitions understood, suggested destinations, what it may affect, what needs approval, what can be changed, and safe fallback.
- Support options: Add to Time, Attach to goal, Save as context, Decide later, Change time, Do not use for planning.
- Show compact clarification for "8 AM or 8 PM?" when needed.
- Add VoiceOver, Dynamic Type, Reduce Motion, preview/snapshot proof where available.
- Add `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`.

## Forbidden files/directories
- no cloud dependency
- no LLM dependency
- no AI jargon
- no shame language
- no hidden profiling
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Exact implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect existing Capture top-level object and result/review surfaces.
3. Keep Capture top-level minimal; show depth only after input.
4. Add review/receipt surface with approval, change, decline, and fallback paths.
5. Ensure no forced attachment and no silent schedule mutation.
6. Add VoiceOver order, Dynamic Type, Reduce Motion, and preview/snapshot proof where available.
7. Record screenshot/previews in proof report if available.

## Validation commands
```bash
make xcode-focused-test BATCH=IOS26-T04D-B07 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B07 TEST=AmbitionsUITests
```

## Proof artifacts to write
- `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`
- Screenshot or preview proof when available
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
Green: visible review flow exists; user can approve/change/decline; no forced attachment; no silent schedule mutation; proof report includes screenshot/previews if available.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: Capture becomes an admin dashboard, schedule/goal mutation is silent, user cannot decline, or accessibility path is absent.

## Rollback behavior
Rollback only files touched by IOS26-T04D-B07 and preserve unrelated dirty work.

## Claims allowed
- This batch may claim only source, test, and proof outcomes directly demonstrated by current logs and artifacts.
- Docs-only or tooling-only changes must be described as docs-only or tooling-only.

## Claims forbidden
- No release readiness, TestFlight readiness, App Store readiness, CI proof, device proof, accessibility verification, performance validation, privacy/legal approval, or Private Life Runtime moat completion without matching current proof.

## Final report required fields
```text
Status:
Files changed:
UI proof:
Accessibility proof:
Privacy/local-first proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next eligible train:
```

## STATUS placeholder
STATUS: <GREEN|YELLOW|RED>

## Original prompt intent retained
The original prompt text is retained below for intent preservation. The sealed sections above are the execution boundary.

----- BEGIN ORIGINAL PROMPT -----
# IOS26-T04D-B07 - Capture UI review surface

## Objective
Expose capture factoring in the UI without turning Capture into an admin inbox.

## Why this exists
Capture should stay minimal at the top level, then reveal what Ambitions understood, where it suggests placing the capture, what may be affected, what needs approval, and what the user can change.

## Dependencies
IOS26-T04D-B01, IOS26-T04D-B02, IOS26-T04D-B03, IOS26-T04D-B04, IOS26-T04D-B05, IOS26-T04D-B06, TRAIN_08 Capture surface assumptions, TRAIN_09 You inspection assumptions, and `docs/codex/IOS26_FLAGSHIP_TRAIN_MANIFEST.yml`.

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
- `Native/Ambitions/Features/Capture/`
- `Native/Ambitions/Features/Captures/`
- `Native/Ambitions/Services/SmartAttachmentService.swift`
- `Native/Ambitions/Domain/SmartAttachmentPlacementPreview.swift`
- Runtime
- Goal compiler
- Recommendation engine
- Source Atlas runtime bridge
- Life Context
- Time
- Goals
- Today
- You
- Persistence
- Receipts
- Replay
- `Native/AmbitionsTests`
- `Native/AmbitionsUITests`
- Preview fixtures

## Exact changes allowed
- Add a Capture result sheet or receipt state.
- Show what Ambitions understood, suggested destinations, what it may affect, what needs approval, what can be changed, and safe fallback.
- Support options: Add to Time, Attach to goal, Save as context, Decide later, Change time, Do not use for planning.
- Show compact clarification for "8 AM or 8 PM?" when needed.
- Add VoiceOver, Dynamic Type, Reduce Motion, preview/snapshot proof where available.
- Add `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`.

## Exact changes forbidden
- no cloud dependency
- no LLM dependency
- no AI jargon
- no shame language
- no hidden profiling
- no silent calendar mutation
- no silent goal attachment
- no top-level IA changes
- no generic capture inbox dashboard
- no sensitive logs
- no external analytics dependency
- no App Store/privacy/accessibility overclaims

## Required UI behavior
The Capture result sheet / receipt state must show:
- what Ambitions understood
- where it suggests placing it
- what it may affect
- what needs approval
- what can be changed
- safe fallback

For "play pickleball at 8 next Tuesday," UI should be able to show:
- "Looks like a scheduled activity."
- "Time needs confirmation: 8 AM or 8 PM?"
- "May support: Fitness / Social activity / Sports context."
- "Add to Time"
- "Attach to goal"
- "Save as context"
- "Decide later"

## Implementation steps
1. Re-read active truth files and confirm dependencies.
2. Inspect existing Capture top-level object and result/review surfaces.
3. Keep Capture top-level minimal; show depth only after input.
4. Add review/receipt surface with approval, change, decline, and fallback paths.
5. Ensure no forced attachment and no silent schedule mutation.
6. Add VoiceOver order, Dynamic Type, Reduce Motion, and preview/snapshot proof where available.
7. Record screenshot/previews in proof report if available.

## Tests to add/update
- Visible review flow exists after capture input.
- User can approve, change, decline, or decide later.
- No forced attachment.
- No silent schedule mutation.
- VoiceOver reads detected meaning, destination, and approval options.
- Dynamic Type is supported.
- Reduce Motion is safe.
- Screenshot/previews are included if available.

## Commands to run
```bash
make xcode-focused-test BATCH=IOS26-T04D-B07 TEST=AmbitionsTests
make xcode-focused-test BATCH=IOS26-T04D-B07 TEST=AmbitionsUITests
```

## Required proof artifacts
- `build/reports/capture-runtime-bridge/capture-ui-review-surface.md`
- Screenshot or preview proof when available

## Accessibility requirements
VoiceOver must read detected meaning, destination, and approval options. Dynamic Type must preserve controls. Reduce Motion must not remove relationship or approval meaning. Status must not be color-only.

## Privacy/local-first requirements
UI must reveal what was detected, what may be used, and what is not used. Sensitive details must be redacted where needed and must not appear in logs/external surfaces.

## iOS 26 API verification requirements
Any iOS 26 API use must be verified against the deployment target and recorded in the proof artifact.

## Green / Yellow / Red closeout rules
Green: visible review flow exists; user can approve/change/decline; no forced attachment; no silent schedule mutation; proof report includes screenshot/previews if available.
Yellow: bounded gap with owner, reason, no-claim boundary, and gate.
Red: Capture becomes an admin dashboard, schedule/goal mutation is silent, user cannot decline, or accessibility path is absent.

## Rollback strategy
Rollback only files touched by IOS26-T04D-B07 and preserve unrelated dirty work.

## Final report format
```text
Status:
Files changed:
UI proof:
Accessibility proof:
Privacy/local-first proof:
Tests run:
Validation not run:
Claims allowed:
Claims forbidden:
Yellow/Red items:
Next eligible train:
```
----- END ORIGINAL PROMPT -----
