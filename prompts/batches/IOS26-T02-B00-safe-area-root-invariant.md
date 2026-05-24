<!-- AMBITIONS_RUNNER_REQUIRED: true -->
<!-- RUN_WITH: scripts/ambitions-codex-train.sh -->
<!-- DIRECT_CODEX_EXECUTION: forbidden_unless_user_explicitly_bypasses_runner -->
# IOS26-T02-B00 - Sealed IOS26 Work Order

## Batch ID
`IOS26-T02-B00`

## Train ID and title
`TRAIN_02` - Design system and Liquid Glass-era shell modernization

## Batch role in train
Batch 1 of 4 in TRAIN_02

## Upstream dependencies
- `TRAIN_01`

## Downstream dependencies
- `TRAIN_05`
- `TRAIN_06`
- `TRAIN_12`
- `TRAIN_14`

## Objective
Eliminate Ambitions' app-wide safe-area drift before shell, surface, visual, and screenshot work continues.

## Product/canon constraints
- Active top-level IA remains `Today / Goals / Capture / Time / You`.
- Use `Start here`, `Recommended step`, `step`, `Start now`, and `Open step` where user-facing language is touched.
- Do not reintroduce `Plan` as a user-facing top-level destination.
- Do not convert Ambitions into a task app, calendar clone, habit tracker, dashboard, chatbot, AI wrapper, SaaS admin panel, or score-based productivity app.

## Local-first/privacy constraints
No personal data leaves the device. Do not add required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or privacy-manifest weakening.

## Accessibility constraints
Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, Reduce Transparency, and tap target expectations where UI is touched. Do not claim accessibility verification without current proof artifacts.

## Performance constraints when relevant
Do not regress launch, scrolling, persistence, or runtime responsiveness. Do not claim performance validation without measured proof.

## Champion Merge source boundary
- Champion Merge final status is accepted Yellow, not Red; IOS26 work may proceed only inside the no-claim boundaries below.
- Before source edits, inspect `docs/codex/canonical-owner-map.yml`, `docs/codex/concept-lock-registry.yml`, and `build/reports/intelligence-consolidation/TRAIN_04L_CLOSEOUT.md`.
- Extend the canonical owner for any touched concept. Do not create a new parallel owner or revive retired duplicate object names as active source/UI terms.
- Keep unresolved Yellow concepts locked against ordinary feature claims until their follow-up gate is Green or owner-accepted.
- `design_system` owns design tokens/materials/primitives under `Sources`, `AppUI/Sources`, and `Native/Ambitions/UI`.
- Champion Merge Yellow: focused Xcode/preview/accessibility proof is not claimed until the skipped design-system lanes run.

## Allowed files/directories
Root and shared UI geometry fixes required to enforce safe-area ownership and collision-free top-level feature layout.
Feature-surface edits only where a top-level foreground layout invents screen offsets, ignores safe area, collides with shell chrome, or bypasses root safe-area ownership.
UI test or screenshot proof helper updates only where needed to prove the invariant.
Create `build/reports/ios26-shell/safe-area-root-invariant.md`.

## Forbidden files/directories
No generic visual redesign.
No new top-level destinations.
No runtime/compiler/persistence changes unless required by an existing UI test fixture compile repair and documented as Yellow.
No required cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.
No foreground `.ignoresSafeArea()` or `edgesIgnoringSafeArea()` without a specific documented product exception.
No new magic padding constants used to hide collisions with Dynamic Island, status bar, home indicator, tab bar, or keyboard.
No feature-specific safe-area workaround that bypasses root shell ownership.

## Exact implementation steps
1. Run the required grep audit before changes and save the output in the proof report:
   ```bash
   rg -n "ignoresSafeArea|edgesIgnoringSafeArea|safeAreaInset|safeAreaPadding|GeometryReader|UIScreen.main|safeAreaInsets|overlay|zIndex|keyboard" Native Sources
   ```
2. Identify the app root safe-area and shell chrome owner.
3. Enforce this law: backgrounds may ignore safe area; foreground content may not ignore safe area unless documented with a specific product reason.
4. Ensure the app root owns safe-area and chrome geometry.
5. Ensure top-level feature surfaces consume safe content bounds instead of inventing screen offsets.
6. Ensure custom tab bar or shell chrome reserves bottom content space.
7. Ensure floating controls attach through `safeAreaInset` or equivalent safe-aware placement.
8. Ensure keyboard-open states do not collide with composer fields, primary CTAs, or tab chrome.
9. Remove magic constants used to dodge Dynamic Island, status bar, home indicator, or tab bar.
10. Run the grep audit after changes and include before/after output in the proof report.

## Validation commands
```bash
rg -n "ignoresSafeArea|edgesIgnoringSafeArea|safeAreaInset|safeAreaPadding|GeometryReader|UIScreen.main|safeAreaInsets|overlay|zIndex|keyboard" Native Sources
xcodegen generate
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```
Run UI/screenshot tests if available, and record the exact command names and logs in the proof report.

## Proof artifacts to write
build/reports/ios26-shell/safe-area-root-invariant.md

The report must include:
- files inspected
- grep audit before/after
- root safe-area owner
- top inset behavior
- bottom inset behavior
- keyboard avoidance behavior
- tab bar avoidance behavior
- floating command behavior
- screenshots or screenshot command logs
- remaining Yellow items, if any
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
Green: No foreground content collides with status bar, Dynamic Island, tab bar, home indicator, or keyboard in tested states; no child feature relies on screen-height hacks for core layout; command logs and proof report are complete; no visual, release, accessibility, or device overclaim is made.
Yellow: Simulator/device screenshot proof is unavailable, but the source invariant and command logs are complete. A post-batch gate must be registered before Train 05.
Red: Any foreground `.ignoresSafeArea()` without documented exception; any new magic padding used to hide collision; any feature-specific safe-area workaround that bypasses root shell ownership; any claim that visual quality, accessibility, device behavior, or App Store readiness is fully proven without proof; missing required truth-file read.

## Rollback behavior
Revert only files touched by this batch. Preserve unrelated dirty work. Remove only malformed proof artifacts created by this batch if the batch fails before a usable report exists.

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
Safe-area root owner:
Top inset behavior:
Bottom inset behavior:
Keyboard avoidance behavior:
Tab bar avoidance behavior:
Floating command behavior:
Screenshot proof status:
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
# IOS26-T02-B00 — Safe Area Root Invariant

## Batch type
Flagship pre-shell geometry invariant

## Objective
Eliminate Ambitions' app-wide safe-area drift before shell, surface, visual, and screenshot work continues.

## Why this exists
The iOS 26 flagship train needs root-owned safe-area and chrome geometry before native shell modernization and screenshot work. Without this invariant, later visual changes can hide status bar, Dynamic Island, home indicator, keyboard, or tab chrome collisions with one-off offsets.

## Dependencies
IOS26-T01-B03 Green, or accepted Yellow with owner, no-claim boundary, and post-batch gate.

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
Native/Ambitions/App/AmbitionsRootView.swift
Native/Ambitions/App/AppTab.swift
Native/Ambitions/App/AppNavigationModel.swift
Native/Ambitions/UI/
Sources/Theme/
Native/Ambitions/Features/Today/
Native/Ambitions/Features/Goals/
Native/Ambitions/Features/Capture/
Native/Ambitions/Features/Time/
Native/Ambitions/Features/You/
Native/AmbitionsUITests/
scripts/ only for proof helpers

## Exact changes allowed
Root and shared UI geometry fixes required to enforce safe-area ownership and collision-free top-level feature layout.
Feature-surface edits only where a top-level foreground layout invents screen offsets, ignores safe area, collides with shell chrome, or bypasses root safe-area ownership.
UI test or screenshot proof helper updates only where needed to prove the invariant.
Create `build/reports/ios26-shell/safe-area-root-invariant.md`.

## Exact changes forbidden
No generic visual redesign.
No new top-level destinations.
No runtime/compiler/persistence changes unless required by an existing UI test fixture compile repair and documented as Yellow.
No required cloud AI/LLM, hosted backend, analytics/tracking SDK, or privacy manifest weakening.
No foreground `.ignoresSafeArea()` or `edgesIgnoringSafeArea()` without a specific documented product exception.
No new magic padding constants used to hide collisions with Dynamic Island, status bar, home indicator, tab bar, or keyboard.
No feature-specific safe-area workaround that bypasses root shell ownership.

## Implementation steps
1. Run the required grep audit before changes and save the output in the proof report:
   ```bash
   rg -n "ignoresSafeArea|edgesIgnoringSafeArea|safeAreaInset|safeAreaPadding|GeometryReader|UIScreen.main|safeAreaInsets|overlay|zIndex|keyboard" Native Sources
   ```
2. Identify the app root safe-area and shell chrome owner.
3. Enforce this law: backgrounds may ignore safe area; foreground content may not ignore safe area unless documented with a specific product reason.
4. Ensure the app root owns safe-area and chrome geometry.
5. Ensure top-level feature surfaces consume safe content bounds instead of inventing screen offsets.
6. Ensure custom tab bar or shell chrome reserves bottom content space.
7. Ensure floating controls attach through `safeAreaInset` or equivalent safe-aware placement.
8. Ensure keyboard-open states do not collide with composer fields, primary CTAs, or tab chrome.
9. Remove magic constants used to dodge Dynamic Island, status bar, home indicator, or tab bar.
10. Run the grep audit after changes and include before/after output in the proof report.

## Tests to add/update
Add or update focused unit/UI/screenshot tests only where existing test infrastructure can prove the safe-area invariant without broad redesign.
If simulator screenshot proof is unavailable, record the exact command attempts or blocker and register Yellow before Train 05.

## Commands to run
```bash
rg -n "ignoresSafeArea|edgesIgnoringSafeArea|safeAreaInset|safeAreaPadding|GeometryReader|UIScreen.main|safeAreaInsets|overlay|zIndex|keyboard" Native Sources
xcodegen generate
scripts/build-local.sh
xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination "platform=iOS Simulator,name=<available simulator>" -only-testing:AmbitionsTests test
```
Run UI/screenshot tests if available, and record the exact command names and logs in the proof report.

## Required proof artifacts
build/reports/ios26-shell/safe-area-root-invariant.md

The report must include:
- files inspected
- grep audit before/after
- root safe-area owner
- top inset behavior
- bottom inset behavior
- keyboard avoidance behavior
- tab bar avoidance behavior
- floating command behavior
- screenshots or screenshot command logs
- remaining Yellow items, if any

## Accessibility requirements
Preserve Dynamic Type, VoiceOver order, Reduce Motion, Increase Contrast, Reduce Transparency, and tap target expectations where UI is touched. Do not claim accessibility verification without current proof artifacts.

## Privacy/local-first requirements
No personal data leaves the device. Do not add required cloud AI/LLM, hosted personal-data backend, tracking SDK, sensitive logs, or privacy-manifest weakening.

## iOS 26 API verification requirements
Use only locally verified APIs. If an iOS 26 API is adopted, record the SDK verification path and command output in the proof report. Preserve Today / Goals / Capture / Time / You.

## Green / Yellow / Red closeout rules
Green: No foreground content collides with status bar, Dynamic Island, tab bar, home indicator, or keyboard in tested states; no child feature relies on screen-height hacks for core layout; command logs and proof report are complete; no visual, release, accessibility, or device overclaim is made.
Yellow: Simulator/device screenshot proof is unavailable, but the source invariant and command logs are complete. A post-batch gate must be registered before Train 05.
Red: Any foreground `.ignoresSafeArea()` without documented exception; any new magic padding used to hide collision; any feature-specific safe-area workaround that bypasses root shell ownership; any claim that visual quality, accessibility, device behavior, or App Store readiness is fully proven without proof; missing required truth-file read.

## Rollback strategy
Revert only files touched by this batch. Preserve unrelated dirty work. Remove only malformed proof artifacts created by this batch if the batch fails before a usable report exists.

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
Safe-area root owner:
Top inset behavior:
Bottom inset behavior:
Keyboard avoidance behavior:
Tab bar avoidance behavior:
Floating command behavior:
Screenshot proof status:
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
