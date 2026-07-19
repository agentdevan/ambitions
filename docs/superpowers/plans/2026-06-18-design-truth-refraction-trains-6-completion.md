# Design Truth Refraction Trains 6-13 Goal Mode Plan

## Summary

Execute Design Truth Refraction work from Train 6 through final maturity closeout, but do **not** execute the remaining work as one open-ended autonomous run.

Baseline policy:

- Trains 0-5 were previously accepted under the user's **Assume Green** policy.
- Trains 6-8 are user-reported complete and should not be re-run unless current validation exposes a regression or dependency failure.
- Train 9 is the active train. It has expanded because strict quality gates were added during execution; that is intentional and should remain strict.
- Trains 10-13 remain in scope and must not be dropped, but each must execute as bounded slices.
- Codex must not make unsupported proof claims. Green requires current validation evidence.

If Train 9+ validation exposes a dependency failure from earlier trains, Codex may create a bounded repair subtrain such as `9.1`, `9.2`, `10.1`, or `11.1`. Do not use repair subtrains as permission to run indefinitely.

## Current Train Status

| Train | Status | Operating instruction |
| --- | --- | --- |
| Train 6 - Closure Refraction | Complete by user report | Do not re-run unless regression is found. Preserve closure mutation/proof/state-coherence gates. |
| Train 7 - Capture Composer Refraction | Complete by user report | Do not re-run unless regression is found. Preserve global composer ownership and keyboard/dock gates. |
| Train 8 - Goals Refraction | Complete by user report | Do not re-run unless regression is found. Preserve Constellation Atlas direction and drilldown/action gates. |
| Train 9 - Time Refraction | Active | Continue bounded slices. Strict gates are expected to keep Train 9 Red/Yellow until architecture, extraction, state, and quality debt are resolved. |
| Train 10 - You Refraction | Pending | Execute only after Train 9 closes Green or honestly Yellow with explicit remaining debt. |
| Train 11 - Motion Behavior Refraction | Pending / partially touched by gate repair | Verify no Motion destination assumptions remain when Train 11 executes. Do not reintroduce Motion as a surface. |
| Train 12 - Trust Inspection Refraction | Pending | Move first-layer trust diagnostics into contextual inspection. |
| Train 13 - Full Maturity Pass | Pending | Final audit/proof pass only; do not use Train 13 to hide earlier unresolved architecture failures. |

## Goal Mode Bootstrap

Use this as the Goal Mode objective:

```text
From /Users/devan/Documents/GitHub/ambitions on main, execute the next bounded slice of docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md.

Do not execute Train 6 through Train 13 in one continuous turn.

Current status: Trains 6-8 are complete by user report. Train 9 is active and strict gates are intentionally blocking it until the rebuild is fully canonical, extracted, state-coherent, and quality-proven.

Preserve Ambitions canon:
- Today / Goals / Time / You are the only persistent root surfaces.
- Capture is the global composer.
- Motion is Stage behavior, not a destination.
- Trust is inspection, not primary UI.
- Offline local core must remain usable.
- No hosted AI/core cloud dependency is allowed.

Work one bounded train-sized slice only. Prefer the smallest slice that removes real Red architecture debt. Stop after the slice reaches a compile/gate checkpoint, a repeated same-root-cause failure, or a clear Green/Yellow/Red closeout.

You may edit source, tests, scripts, validation docs, project.yml, and delete obsolete files. Do not edit docs/truth canon files.

Do not use subagents unless explicitly approved. Do not run broad autonomous repair loops. Do not folder-launder old feature screens into canonical folders. Split touched production Swift files over 400 LOC unless justified. Treat every production Swift file over 600 LOC as Red until decomposed.

Commit and push only Green or honestly Yellow bounded slices to main with evidence-backed closeout.
```

## Required Skills

At each Goal Mode start, load and follow:

- `ambitions-source-truth-authority`
- `ambitions-release-proof-honesty`
- `ambitions-ios-quality-gate`
- `superpowers:executing-plans`

Use `superpowers:subagent-driven-development` only when the user explicitly authorizes subagents for that invocation.

## Operating Contract

- Work on `main`; preserve XcodeGen; never commit `Ambitions.xcodeproj`, `.codex/`, `artifacts/`, raw logs, or unrelated dirt.
- Canon files under `docs/truth/` are read-only unless the user explicitly changes canon.
- Tracked validation docs may be added only when compact, current, and materially useful; noisy output stays ignored under `.codex/`.
- Codex may delete obsolete Motion/Capture/root-tab/diagnostic files once replacement source, routes, tests, and proof are present.
- Use active repo truth, current source ownership, focused tests, and evidence-backed validation over stale issue wording or historical docs.
- Do not claim release, TestFlight, App Store, device, privacy/legal, account, R2, accessibility, or performance readiness without current proof.
- Do not broaden a train to make progress look larger. A smaller Green slice is better than a wide Yellow/Red sprawl.
- Do not start the next train after a successful slice. Close out and name the next recommended bounded slice.

## Global Execution Policy - Bounded Rebuild Mode

This plan must be executed as bounded train-sized slices, not as one continuous autonomous run.

### 1. Bounded autonomy

Each invocation may execute only one coherent slice:

- one migration group,
- one oversized-file extraction family,
- one quality-gate bucket,
- one surface/detail route family,
- one compile/gate repair pass,
- or one focused state-coherence repair.

Do not continue into the next group after a checkpoint. Close out and name the next recommended slice.

### 2. Usage discipline

Default execution must minimize agentic burn:

- no subagents unless explicitly approved,
- no broad repo-wide exploration after targeted inventory,
- no repeated build polling narration,
- no speculative cleanup outside touched scope,
- no open-ended repair loops,
- no “continue until done” behavior.

Allowed validation cadence per slice:

- targeted search/inventory as needed,
- one strict quality-gate run before closeout,
- one build-for-testing after a coherent source slice,
- reruns only for failures introduced by the current slice.

If a build is already running when the prior session ends, the next invocation must verify or rerun that build before making further source moves.

### 3. Strict gate posture

Strict gates are intentional. Do not weaken them to get Green.

Mandatory gates include:

- architecture drift,
- file-size,
- forbidden language,
- design tokens,
- shell chrome,
- safe area,
- Dynamic Type,
- motion reduction,
- accessibility,
- performance budget,
- visual regression,
- state coherence.

If a scanner finding is a false positive, narrow the scanner rule while preserving the product requirement. Do not delete, suppress, or dilute a gate because it is inconvenient.

### 4. Features quarantine

`Native/Ambitions/Features/` is legacy quarantine.

Before editing any `Features` file, classify it as:

- `move` — already matches a canonical owner and can be moved with minimal semantic change,
- `delete` — obsolete, dead, duplicate, or old-canon-only,
- `replace` — contains useful intent but must be rebuilt into canonical architecture,
- `shim` — temporary empty compatibility only, with removal target and no canonical behavior.

Rules:

- no new canonical behavior in `Features`,
- no folder-laundering old feature screens into canonical folders,
- no compatibility aliases that revive Capture, Motion, Plan, Habits, Insights, Reviews, or external surfaces as root destinations,
- no `Surfaces/Motion`,
- no `Surfaces/Capture`,
- no `RootTab` product model,
- no `TabView` as root product architecture.

### 5. Extraction law

This plan must reduce mega-files during rebuild.

Rules:

- no new mega-view, mega-reducer, mega-model, mega-contract, or mega-component files,
- every touched production Swift file over 400 LOC must be split unless explicitly justified,
- every production Swift file over 600 LOC is Red until decomposed,
- closeout must list largest touched production Swift files with LOC,
- every extracted file must have one clear reason to exist and one canonical owner.

Canonical extraction targets:

- domain/runtime truth -> `Core/Domain`, `Core/Runtime`, `Core/Time`
- persistence -> `Core/Persistence`
- permissions -> `Core/Permissions`
- runtime-to-UI translation -> `Projection/SurfaceLenses`, `Projection/StageScenes`, `Projection/OverlayLenses`, `Projection/OverlayScenes`
- commands/mutations -> `Projection/Commands`, `Projection/Mutations`
- shell/chrome/route/focus/safe area -> `Stage`, `Stage/Chrome`
- Motion behavior -> `Stage/Motion`
- canvas/render primitives -> `Rendering/CanvasPrimitives`
- semantic mirrors -> `Rendering/SemanticMirrors`
- visual primitives/product objects -> `DesignSystem`
- thin surface ownership -> `Surfaces/<Surface>`
- global Capture composer -> `Composer/Capture`
- inspection/explanation/proof/source/privacy/history/receipts -> `Trust`
- copy/vocabulary/budgets -> `Language`
- gestures/keyboard/haptics -> `Interaction`
- previews/scenarios -> `Scenarios`
- audits and proof harnesses -> `Quality`
- diagnostics -> `Diagnostics`

### 6. Fully developed rebuild requirement

A moved file is not automatically rebuilt.

A train is folder-laundering if it only changes paths while preserving:

- generic card-stack primary composition,
- static feature-screen body,
- local fixture truth,
- root-surface Capture/Motion/Plan/Habits/Insights assumptions,
- exposed runtime/debug terminology,
- impossible visible actions,
- no mutation proof,
- no accessibility mirror,
- no scenario coverage,
- no quality proof.

A rebuilt slice must prove:

- correct canonical owner,
- object/state/action contract,
- runtime or projection source of truth,
- visible mutation for meaningful action,
- accessibility summary/action path,
- reduced-motion fallback where motion exists,
- safe-area/chrome correctness where UI is touched,
- no forbidden top-level language,
- no root-surface drift.

### 7. State-coherence law

Do not render all possible controls by default. Visible actions must come from current state.

Rules:

- no active Step -> no Done / Still counts / Move it / Blocked / Not needed / Closure action,
- no `closureNeed` -> no Closure overlay,
- no `recommendedStep` -> no Start Here Token,
- no source/trust need -> no source/proof/receipt UI on root surfaces,
- no detail route -> no detail-only controls on root surfaces,
- failed runtime validation -> no success animation and no proof artifact.

Every surface action contract must declare preconditions.

### 8. Quality-now implementation requirements

Quality infrastructure must be installed and preserved during the rebuild, not deferred to Train 13.

Required now:

1. Executable architecture, file-size, forbidden-language, design-token, shell-chrome, safe-area, Dynamic Type, motion-reduction, performance-budget, and visual-regression gates.
2. Architecture drift checks for `Features/`, RootTab, TabView-as-root, Motion/Capture root surfaces, forbidden strings, oversized files, and raw design literals.
3. ScenarioCatalog/ScenarioMatrix before finalizing surfaces; no ad hoc fixture data inside views.
4. Preview matrices for empty, normal, dense, broken-source, offline, permission-denied, recovery, post-mutation, Dynamic Type XXXL, Reduce Motion, Reduce Transparency, High Contrast, small/large iPhone, and keyboard states.
5. Runtime mutation -> visible stage mutation -> accessibility announcement -> proof artifact for every meaningful action.
6. Semantic accessibility mirrors for every rendered/canvas/spatial object.
7. Centralized design tokens; no raw colors, fonts, corner radii, shadows, glass, animation constants, or haptics in surface files unless narrowly justified.
8. Centralized user-facing strings through Language; no forbidden top-level runtime terms.
9. Shell chrome, keyboard choreography, dock behavior, crown behavior, route restoration, overlays, drilldowns, safe areas, and focus restoration handled as Stage/Interaction systems, not per-screen hacks.
10. Surface contract snapshots before heavy UI: primary object, primary action, empty/dense/broken-source/recovery states, disclosure behavior, search behavior, motion behavior, accessibility behavior, and safe-area behavior.
11. Failure states as first-class state, not afterthought copy.
12. No placeholder folders. Every new file must have a functional contract.

Reject any train that compiles but does not prove object, state, action, mutation, accessibility, native shell behavior, route discipline, performance budget, and no old-canon drift.

## Architecture Tree Gate

Every train must explicitly check the final architecture tree from `docs/truth/PRODUCT_DESIGN_TRUTH.md` before closeout. Passing tests is not enough.

Required gate:

- Persistent surfaces remain Today / Goals / Time / You only.
- Capture work lives as composer/overlay behavior, never a persistent root surface.
- Motion work lives under Stage/Motion behavior, never a destination.
- Trust, Source, Proof, Privacy, History, and Receipts remain contextual inspection, not first-layer root UI.
- Runtime logic belongs in runtime/domain ownership such as `Core/Runtime` or existing repo runtime seams, not in view-only feature files.
- Projection logic belongs in `Projection` ownership: lenses, scenes, commands, and mutations translate runtime/domain state into user-facing stage state.
- Every meaningful mutation must define runtime mutation id, before snapshot, after snapshot, target surface, affected object ids, visible user-facing change, motion event, accessibility announcement or no-announcement reason, haptic intent, undo availability, proof artifact, and safe fallback.
- Feature files may compose and render their owned surface, but they must not become the authority for runtime policy, mutation proof, cross-surface motion, or trust inspection.
- If the current repo structure has compatibility seams that do not yet match the final tree, the train must either move the touched source toward the tree or close Yellow with an explicit architecture-debt note and next repair train.
- If strict quality gates require moving code from a later numbered train during Train 9, that is allowed only as a bounded repair slice and must not claim the later train is complete unless its exit evidence is satisfied.

## Tooling Preflight

Use a light preflight for every bounded slice:

- `git status --short --branch`
- `git rev-parse HEAD`
- confirm no unrelated dirty work will be staged

Use the full preflight only at the start of a fresh Goal Mode session, after environment changes, or when tooling fails:

- `git ls-remote origin refs/heads/main`
- repair local Codex config if `codex mcp list` fails with `service_tier = "default"` or another invalid value; update `/Users/devan/.codex/config.toml` to `service_tier = "fast"`, then rerun `codex mcp list`
- verify `xcodebuild -version`, `xcode-select -p`, `xcodegen --version`, `which gtimeout`, and `mcp__xcodebuildmcp.session_show_defaults`

Current discovered defaults:

- XcodeBuildMCP profile `ambitions-ios`
- scheme `Ambitions`
- project `Ambitions.xcodeproj`
- simulator `iPhone 17`
- CLI Xcode currently reports 26.6 build 17F113 at `/Applications/Xcode.app`

Use bounded wrappers for long Xcode work:

- `scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>`
- `scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>`
- `scripts/ambitions-bounded-xcodebuild.sh`

## Train 6 - Closure Refraction

**Status:** Complete by user report. Do not re-run unless current validation exposes regression or dependency failure.

Replace diagnostic `TodayActionClosureSheet` anatomy with a real closure stage.

Primary scope:

- Add or mature `ClosureEngine`, closure consequence policy, `StageMutation`, proof receipt save, undo/failure state, and Today visible mutation.
- Replace debug/diagnostic sheet language with user-facing closure decisions and visible consequences.
- Keep proof receipts inspectable, not first-layer diagnostic output.
- Preserve closure outcomes and canonical language: `Done`, `Still counts`, `Move it`, `Blocked`, `Not needed`, `Review`, `Undo`, `Start here`, `Recommended step`, `Start now`, `Open step`.

Primary owners:

- `TodayActionClosureSheet*`
- `TodayClosureRecord`
- `TodayFeatureService`
- `TodayViewModel`
- `TodayScreen`
- `ActionClosureReceiptModels`
- focused Today tests

Exit evidence:

- Today closure saves a receipt when storage is available.
- Closure produces a visible Today-stage mutation, not only a transient message.
- Failure and local-only save states are explicit and honest.
- Undo/review affordances are present where supported, or unsupported controls are hidden.
- Focused Today tests cover closure projection and receipt persistence.

Regression guard:

- no active Step -> no closure action,
- no `closureNeed` -> no Closure overlay,
- saving closure must visibly mutate Today or close Yellow/Red.

## Train 7 - Capture Composer Refraction

**Status:** Complete by user report. Do not re-run unless current validation exposes regression or dependency failure.

Mature global Capture, not a root tab.

Primary scope:

- Extract `AppShellActivatedCaptureSeam` from `AppShellView`.
- Unify the shell capture seam with `CaptureAtmosphereComposer`.
- Fix keyboard/dock geometry.
- Persist route correction or hide unsupported controls.
- Keep dictation as keyboard-focus only unless real voice support is implemented.
- Prove offline local save.

Primary owners:

- `AppShellView`
- `AppShellActivatedCaptureSeam`
- `CaptureAtmosphereComposer`
- `CaptureScreen`
- `CaptureViewModel`
- navigation route tests
- focused Capture tests

Exit evidence:

- Capture remains a global composer and is not reintroduced as a root tab.
- Unsupported voice/route controls are either real or hidden.
- Offline local save has current focused test proof.
- Root dock and keyboard geometry remain legible.

Regression guard:

- Capture stays under `Composer/Capture`.
- Capture must not appear in `AmbitionsSurface`.
- Capture keyboard state must not trap composer between dock and keyboard.
- Capture action must create visible mutation, accessibility announcement, and proof when meaningful.

## Train 8 - Goals Refraction

**Status:** Complete by user report. Do not re-run unless current validation exposes regression or dependency failure.

Make Goals first viewport a Constellation Atlas with real thread depth.

Primary scope:

- Preserve existing service/runtime depth.
- Split large Goals files where needed.
- Reduce card-stack/proof-console anatomy.
- Surface the Today relationship.
- Hide root dock in detail when appropriate.
- Make step chain and proof history actionable.

Primary owners:

- `GoalsScreen`
- `GoalDetailScreen`
- `GoalsViewModels`
- `GoalsFeatureService`
- Goal components and focused Goals tests

Exit evidence:

- Goals reads as Constellation Atlas, not a list manager or dashboard stack.
- Goal details support meaningful drilldown and action.
- Today relationship is visible and user-facing.
- Focused Goals tests cover touched behavior.

Regression guard:

- Goals remains a root surface only as `Goals`.
- Goal details hide the root dock.
- Goal relationship/proof details do not become top-level proof-console UI.
- Any remaining `Features/Goals` files must be classified and migrated/deleted/replaced/shimmed before final Green.

## Train 9 - Time Refraction

**Status:** Active.

Mature LifeShape Field around capacity, fixed points, protected windows, pressure, and horizon modes.

Primary scope:

- Add explicit day/week/month/year alternatives to gestures.
- Remove top-level Plan/reflow/debug wording.
- Route Capture support through the global composer.
- Validate live-time behavior through `AmbitionsClock`.
- Absorb strict gate repair needed to keep Time canonical: remaining `Features/` ownership, oversized touched files, raw design literals, shell/safe-area findings, state-coherence failures, and Time-owned drilldowns such as ritual/detail behavior.
- If Habits-like functionality is still live, migrate it as Time-owned ritual/detail behavior. Do not expose Habits as a product surface or root destination.
- Do not use Train 9 to complete Train 10-13 work unless strict gates require a bounded repair touching those owners. If that happens, close with an explicit “touched but not completed” note.

Primary owners:

- `Surfaces/Time/TimeSurface`
- `Surfaces/Time/TimeViewModel`
- `DesignSystem/ProductObjects/LifeShapeFieldView`
- `Projection/SurfaceLenses/TimeLens`
- `Projection/SurfaceLenses/TimeProjectionService`
- `Core/Time/AmbitionsClock`
- Time-owned drilldown/detail owners when needed
- focused Time tests

Exit evidence:

- Time reads as LifeShape Field, not a calendar clone.
- Horizon alternatives are accessible without relying on gestures.
- Live time behavior is clock-injected and testable.
- Capture entry goes through the global composer.
- Any Time-owned ritual/detail path is not a Habits root surface.
- No top-level Plan/reflow/debug wording remains in first-layer Time UI.
- Touched production Swift files over 400 LOC are split or justified.
- Production Swift files over 600 LOC touched during Train 9 are decomposed.
- Strict gate result is Green or honestly Yellow/Red with exact remaining blockers.

Suggested bounded subtrains for Train 9:

- `9.1` Verify current build result and strict gate shape.
- `9.2` Finish TimeRituals/Time detail migration and compile.
- `9.3` Remove remaining Time-adjacent `Features/` ownership.
- `9.4` Split touched oversized Time/Projection/DesignSystem files.
- `9.5` Repair Time state-coherence and impossible-action cases.
- `9.6` Clean design-token findings only inside touched Time owners.
- `9.7` Close Train 9 with focused Time proof and remaining-debt ledger.

## Train 10 - You Refraction

**Status:** Pending.

Rebuild You as native User System Profile.

Primary scope:

- Replace sheet-only detail behavior with full-screen drilldowns where needed.
- Keep preference/permission saves real.
- Compress verbose runtime/control-center copy.
- Expose account/R2/local data as actionable settings without claiming readiness.
- Move Trust/Privacy/History/Receipts detail out of first-layer You where it belongs to Trust inspection.
- Remove any `Features/You` ownership that acts as runtime manual, admin console, dashboard, or settings dump.

Primary owners:

- `YouScreen`
- `YouRootSurface`
- `YouFeatureService`
- `Surfaces/You/*`
- `DesignSystem/ProductObjects/UserSystemProfileView`
- `DesignSystem/ProductObjects/NativeSettingsGroup`
- `DesignSystem/ProductObjects/NativeSettingsRow`
- You settings/detail components
- focused You tests

Exit evidence:

- You reads as User System Profile, not a dashboard/admin/control center.
- Preferences and permissions save through real services.
- Account/R2/local data copy remains honest and non-readiness-claiming.
- Root You has a profile/settings hierarchy with minimal top-level scrolling.
- Details hide the root dock and use native back behavior.
- Focused You tests cover touched behavior.

## Train 11 - Motion Behavior Refraction

**Status:** Pending. Some Motion cleanup may already have happened as strict-gate repair; do not claim complete until exit evidence is proven.

Remove any remaining Motion destination assumptions.

Primary scope:

- Move useful `MotionCurrent*` behavior into `Native/Ambitions/Stage/Motion/` or equivalent stage-owned behavior files.
- Add or mature `StageMotionState`, `StageMotionEvent`, coordinator/renderer/accessibility/reduce-motion policy.
- Delete or migrate obsolete `Features/Motion` only after routes/tests prove no root dependency remains.
- Ensure Motion appears as consequence of change, proof, recovery, re-entry, blockage, completion, and undo; not as root UI.

Primary owners:

- `Stage/Motion/*`
- `Rendering/CanvasPrimitives/*` when rendering behavior is extracted
- `Rendering/SemanticMirrors/*` for nonvisual meaning
- `DesignSystem/ProductObjects/*` only for product-owned rendered pieces
- navigation route tests
- accessibility/reduce-motion policy tests

Exit evidence:

- Motion is behavior, not a tab or destination.
- Stage-owned Motion events have accessible and Reduce Motion-aware rendering.
- No root route depends on obsolete Motion feature surfaces.
- No `Features/Motion` canonical ownership remains.
- No Motion root surface appears in `AmbitionsSurface`, root dock, route enum, previews, tests, or screenshots.

## Train 12 - Trust Inspection Refraction

**Status:** Pending.

Move Source/Proof/Privacy/History/Receipts out of first-layer UI into contextual inspection.

Primary scope:

- Add or mature `InspectionLens` and inspection scenes.
- Use plain-language trust copy.
- Add accessible detail routes.
- Provide proof/history receipt lookup without debug-console language.
- Remove source/proof/receipt rows from top-level surfaces unless they are quiet status or explicitly required by the current action.

Primary owners:

- `Trust/*`
- `Projection/OverlayLenses/InspectionLens`
- `Projection/OverlayScenes/InspectionStageScene`
- receipt/proof history source
- route surfaces that currently expose first-layer trust diagnostics
- focused inspection tests

Exit evidence:

- Trust remains inspectable without becoming a top-level dashboard.
- Source/Proof/Privacy/History/Receipts are contextual and accessible.
- Debug-console language is absent from user-facing first-layer UI.
- Root surfaces remain understandable before inspection language appears.

## Train 13 - Full Maturity Pass

**Status:** Pending.

Run final maturity audits and closeout.

Primary scope:

- Re-run file ledger.
- Re-run large-file audit.
- Re-run stub/adapter audit.
- Re-run forbidden-language scan.
- Re-run architecture conformance.
- Re-run build, focused tests, screenshot/accessibility matrix, and proof reports.
- Split or justify oversized files.
- Remove production stubs/no-op controls.
- Isolate previews/fixtures.
- Close with exact Green/Yellow/Red evidence.

Exit evidence:

- Final train status is evidence-backed.
- Oversized files are split, scheduled with explicit rationale, or proven acceptable.
- Production stubs/no-op controls are removed or made honest.
- Screenshots and accessibility evidence are either current and reviewed or explicitly not claimed.
- No canonical code remains under `Features/` unless explicitly documented as temporary empty shim with removal target.
- Quality gates are Green or final Yellow/Red is honest with exact blocker list.
- Final proof does not claim release/TestFlight/App Store/device/privacy/account/R2 readiness without evidence.

## Repair And Loop Rules

- Codex may create subtrains such as `9.1`, `9.2`, `10.1`, or `11.1` for compile failures, visual/accessibility failures, missing proof harnesses, or prerequisite source seams.
- Maximum two automatic repair attempts for the same root cause.
- Maximum one bounded subtrain per invocation unless the user explicitly asks for more.
- Maximum three subtrains between numbered trains.
- After either limit is reached, stop and ask the user with concrete options.
- AMB-962/screenshot timeout policy: one timeout retry only; if retry fails or times out, close the train Yellow/Red with artifacts and stop rerunning.
- Do not broaden a train to hide failure.
- If a failing validator is stale, repair the validator only after proving current truth/source disagree with it.
- Raw logs over 25 MB must be summarized with command, counts, sampled findings, and local ignored artifact path.
- If usage pressure is high, prefer closeout over another repair loop.

## Validation And Closeout

Every bounded slice closeout must include:

- Status: Green / Yellow / Red
- Branch
- Commit SHA
- Scope completed
- Files changed/created/deleted
- Build result
- Quality-gate result
- Validation run/not run
- Screenshots visually reviewed or explicit not-run reason
- Accessibility notes
- Mutation proof
- State-coherence proof if actions were touched
- Forbidden-language result
- Design-token result if UI/design files were touched
- Shell/safe-area result if shell/overlay/drilldown/keyboard files were touched
- Remaining `Features/` count and classification if relevant
- Largest touched production Swift files with LOC
- Files left over 400/600 LOC and why
- Root-surface proof if Capture/Motion/Plan/Habits/Insights/Reviews were touched
- Known risks
- Rollback plan
- Exact next recommended bounded slice

Minimum source-slice validation:

- `git diff --check`
- `xcodegen generate` when project membership or file paths changed
- bounded build-for-testing after coherent source movement or compile-sensitive extraction
- focused unit/UI tests for touched owners when available
- `scripts/ambitions-quality-gate.sh --max-per-gate 20` at least once before closeout unless impossible
- canon/copy/release claim scans where relevant
- screenshot/accessibility proof when UI changed and tooling/time permits; otherwise explicitly do not claim visual/accessibility readiness

Green requires current proof for the slice's claims. Compilation alone is not Green. Otherwise close Yellow or Red honestly. Do not claim release, TestFlight, App Store, device, privacy/legal, account, R2, accessibility, or performance readiness without current evidence.

Commit each completed bounded slice on `main`; push after commit if validation and closeout are evidence-backed. Keep unrelated local changes out of staging.

## Next Recommended Invocation Pattern

Use this pattern for the next Goal Mode run while Train 9 remains active:

```text
From /Users/devan/Documents/GitHub/ambitions on main, execute the next bounded Train 9 slice from docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md.

Do not run beyond one slice. Do not use subagents. First verify or rerun the latest TimeRituals build if its result is not already known. Then run the strict quality gate once, pick the smallest remaining Train 9 architecture/extraction blocker, fix it without folder-laundering, validate, close out, commit/push only if Green or honestly Yellow.
```
