# Design Truth Refraction Trains 6-13 Goal Mode Plan

## Summary

Execute autonomous Design Truth Refraction work from Train 6 through final maturity closeout.

Baseline policy: the user selected **Assume Green** for Trains 0-5. Goal Mode starts at Train 6, but must not make unsupported proof claims. If Train 6+ validation exposes a dependency failure from earlier trains, Codex may create a repair train such as `6.1`, `6.2`, or `7.5` before advancing.

## Goal Mode Bootstrap

Use this as the Goal Mode objective:

```text
From /Users/devan/Documents/GitHub/ambitions on main, execute docs/superpowers/plans/2026-06-18-design-truth-refraction-trains-6-completion.md autonomously from Train 6 through Train 13. Preserve Ambitions canon: Today / Goals / Time / You, Capture as global composer, Motion as behavior, Trust as inspection. You may edit source, tests, scripts, validation docs, project.yml, and delete obsolete files. Do not edit docs/truth canon files. Create bounded repair subtrains when required, but stop and ask for input after repeated same-root-cause failures. Commit and push each Green or honestly Yellow train-sized slice to main with evidence-backed closeout.
```

## Required Skills

At each Goal Mode start, load and follow:

- `ambitions-source-truth-authority`
- `ambitions-release-proof-honesty`
- `ambitions-ios-quality-gate`
- `superpowers:executing-plans` or `superpowers:subagent-driven-development`

## Operating Contract

- Work on `main`; preserve XcodeGen; never commit `Ambitions.xcodeproj`, `.codex/`, `artifacts/`, raw logs, or unrelated dirt.
- Canon files under `docs/truth/` are read-only unless the user explicitly changes canon.
- Tracked validation docs may be added only when compact, current, and materially useful; noisy output stays ignored under `.codex/`.
- Codex may delete obsolete Motion/Capture/root-tab/diagnostic files once replacement source, routes, tests, and proof are present.
- Use active repo truth, current source ownership, focused tests, and evidence-backed validation over stale issue wording or historical docs.
- Do not claim release, TestFlight, App Store, device, privacy/legal, account, R2, accessibility, or performance readiness without current proof.

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

## Tooling Preflight

- Run `git status --short --branch`, `git rev-parse HEAD`, and `git ls-remote origin refs/heads/main`; stop if `main` is dirty from unrelated work.
- Repair local Codex config before MCP-dependent work: if `codex mcp list` fails with `service_tier = "default"` or another invalid value, update `/Users/devan/.codex/config.toml` to `service_tier = "fast"`, then rerun `codex mcp list`.
- Verify `xcodebuild -version`, `xcode-select -p`, `xcodegen --version`, `which gtimeout`, and `mcp__xcodebuildmcp.session_show_defaults`.
- Current discovered defaults: XcodeBuildMCP profile `ambitions-ios`, scheme `Ambitions`, project `Ambitions.xcodeproj`, simulator `iPhone 17`; CLI Xcode currently reports 26.3 at `/Applications/Xcode.app`.
- Use bounded wrappers for long Xcode work: `scripts/ambitions-xcode-build-for-testing.sh --batch <BATCH>`, `scripts/ambitions-xcode-test-focused.sh --batch <BATCH> --test <TEST_ID>`, and screenshot helpers through `scripts/ambitions-bounded-xcodebuild.sh`.

## Train 6 - Closure Refraction

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

## Train 7 - Capture Composer Refraction

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

## Train 8 - Goals Refraction

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

## Train 9 - Time Refraction

Mature LifeShape Field around capacity, fixed points, protected windows, pressure, and horizon modes.

Primary scope:

- Add explicit day/week/month/year alternatives to gestures.
- Remove top-level Plan/reflow/debug wording.
- Route Capture support through the global composer.
- Validate live-time behavior through `AmbitionsClock`.

Primary owners:

- `TimeScreen`
- `TimeLifeShapeField`
- `TimeViewModel`
- `TimeFeatureService`
- focused Time tests

Exit evidence:

- Time reads as LifeShape Field, not a calendar clone.
- Horizon alternatives are accessible without relying on gestures.
- Live time behavior is clock-injected and testable.
- Capture entry goes through the global composer.

## Train 10 - You Refraction

Rebuild You as native User System Profile.

Primary scope:

- Replace sheet-only detail behavior with full-screen drilldowns where needed.
- Keep preference/permission saves real.
- Compress verbose runtime/control-center copy.
- Expose account/R2/local data as actionable settings without claiming readiness.

Primary owners:

- `YouScreen`
- `YouRootSurface`
- `YouFeatureService`
- You settings/detail components
- focused You tests

Exit evidence:

- You reads as User System Profile, not a dashboard/admin/control center.
- Preferences and permissions save through real services.
- Account/R2/local data copy remains honest and non-readiness-claiming.
- Focused You tests cover touched behavior.

## Train 11 - Motion Behavior Refraction

Remove any remaining Motion destination assumptions.

Primary scope:

- Move useful `MotionCurrent*` behavior into `Native/Ambitions/Stage/Motion/` or equivalent stage-owned behavior files.
- Add or mature `StageMotionState`, `StageMotionEvent`, coordinator/renderer/accessibility/reduce-motion policy.
- Delete or migrate obsolete `Features/Motion` only after routes/tests prove no root dependency remains.

Primary owners:

- `Stage/Motion/*`
- `Features/Motion/*`
- navigation route tests
- accessibility/reduce-motion policy tests

Exit evidence:

- Motion is behavior, not a tab or destination.
- Stage-owned Motion events have accessible and Reduce Motion-aware rendering.
- No root route depends on obsolete Motion feature surfaces.

## Train 12 - Trust Inspection Refraction

Move Source/Proof/Privacy/History/Receipts out of first-layer UI into contextual inspection.

Primary scope:

- Add or mature `InspectionLens` and inspection scenes.
- Use plain-language trust copy.
- Add accessible detail routes.
- Provide proof/history receipt lookup without debug-console language.

Primary owners:

- Trust/inspection source
- receipt/proof history source
- route surfaces that currently expose first-layer trust diagnostics
- focused inspection tests

Exit evidence:

- Trust remains inspectable without becoming a top-level dashboard.
- Source/Proof/Privacy/History/Receipts are contextual and accessible.
- Debug-console language is absent from user-facing first-layer UI.

## Train 13 - Full Maturity Pass

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

## Repair And Loop Rules

- Codex may create subtrains such as `6.1`, `6.2`, or `7.5` for compile failures, visual/accessibility failures, missing proof harnesses, or prerequisite source seams.
- Maximum two automatic repair attempts for the same root cause.
- Maximum three subtrains between numbered trains.
- After either limit is reached, stop and ask the user with concrete options.
- AMB-962/screenshot timeout policy: one timeout retry only; if retry fails or times out, close the train Yellow/Red with artifacts and stop rerunning.
- Do not broaden a train to hide failure.
- If a failing validator is stale, repair the validator only after proving current truth/source disagree with it.
- Raw logs over 25 MB must be summarized with command, counts, sampled findings, and local ignored artifact path.

## Validation And Closeout

Every train closeout must include:

- Status
- Branch
- Commit SHA
- Files changed/created/deleted
- Validation run/not run
- Screenshots visually reviewed or explicit not-run reason
- Accessibility notes
- Mutation proof
- Forbidden-language result
- Known risks
- Rollback plan

Minimum source-train validation:

- `xcodegen generate`
- bounded build-for-testing
- focused unit/UI tests for touched owners
- `git diff --check`
- canon/copy/release claim scans
- screenshot/accessibility proof when UI changed

Green requires current proof for the train's claims. Otherwise close Yellow or Red honestly. Do not claim release, TestFlight, App Store, device, privacy/legal, account, R2, accessibility, or performance readiness without current evidence.

Commit each completed train-sized slice on `main`; push after commit if validation and closeout are evidence-backed. Keep unrelated local changes out of staging.
