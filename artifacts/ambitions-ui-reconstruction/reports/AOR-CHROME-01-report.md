# AOR-CHROME-01 Report - Toolbar Action Reduction

Status: Green
Issue: AMB-536
Date: 2026-06-06
Base commit: `cfb0ce6348e81bbaf7e64c02ea18cb99bf989615`

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-012-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-00-report.md`

## Scope

AMB-536 reduced the active top-level shell utility cluster so root surfaces no longer present generic search or shell-level plus/create controls. The shared shell now exposes one quiet Capture fallback per canonical tab. Surface-specific actions remain owned by the active surface/object state.

## Changed Files

- `Native/Ambitions/App/AmbitionsRootView.swift`
  - Removed the default root memory-lens/search button from `shellUtilityButtons(for:)`.
  - Removed the shell-injected Goals `Create Goal` plus button.
  - Kept the quiet Capture fallback using `square.and.pencil` and the existing contextual Capture route.
  - Removed the now-unused root-level `presentMemoryLens(from:)` helper.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Updated the canonical shell UI test to prove:
    - `shell.today.capture-button` exists.
    - `shell.today.memory-lens-button` does not exist by default.
    - `shell.goals.create-button` does not exist.
    - `shell.goals.capture-button` exists.
- `prompts/batches/AMB-536.md`
  - Runner header and AMB-536 issue contract are installed.

## Removed / Demoted Controls

| Previous control | AMB-536 result | Reason |
|---|---|---|
| Default root search / memory-lens button | Removed from top-level shell chrome | Search must not be a default root affordance unless a surface-specific need proves it. |
| Shell-level Goals plus / Create Goal | Removed from shell chrome | Goal creation belongs to Goals object state and feature-owned flows, not generic app chrome. |
| Capture fallback | Preserved as one quiet toolbar action | Canon allows global Capture as contextual fallback; icon is `square.and.pencil`, not plus/FAB. |

## Screenshot Evidence

All screenshots were captured from the booted `iPhone 17e` simulator at 1170 x 2532 after the final AMB-536 build, using `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=preview`, `-AmbitionsInitialSurface <surface>`, and `-AmbitionsScreenshotMode YES`.

- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-actions-today-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-actions-goals-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-actions-time-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-actions-motion-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-actions-you-after-final.png`

The Goals screenshot is the clearest before/after check against AMB-535: AMB-535 still showed Capture, search, and plus in the shell; AMB-536 shows only the Capture fallback.

## Remaining Owner Issues

- Memory Lens / search remains available through command-router infrastructure, but it is no longer exposed as default top-level shell chrome. Future surface-specific recall access must be justified by that surface owner.
- Goals still owns create-goal actions in its feature root/previews and empty/object flows.
- Feature-owned composition bands remain on Goals, Time, You, Motion, and Capture from AMB-535's owner map; they are not broadened into this toolbar patch.

## Validation

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-536 prompts/batches/AMB-536.md`
  - Champion coverage Green.
  - Parallel implementation guard pre Green.
  - Nested Phase 01 stopped before source patch due runner model usage limit: retry after `2026-06-11 00:31`.
- `git diff --check`
  - Passed.
- `make xcode-build-for-testing BATCH=AMB-536`
  - Passed.
- `make xcode-focused-test BATCH=AMB-536 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - Passed.
- Simulator screenshot capture for Today, Goals, Time, Motion, and You.
  - Passed; all AMB-536 after-screenshots are 1170 x 2532.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-536 --prompt prompts/batches/AMB-536.md --changed-from cfb0ce6348e81bbaf7e64c02ea18cb99bf989615 --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-536-post.md`.

## Proof Boundaries

- This proves scoped root toolbar reduction, local build success, focused shell UI test success, and simulator screenshot evidence.
- This does not prove final visual approval for feature-owned surface composition, full accessibility review, VoiceOver traversal, real-device behavior, performance, privacy/legal approval, CI proof, release readiness, TestFlight readiness, or App Store readiness.

## Rollback

Revert the AMB-536 commit, or remove the source/test/report/prompt/screenshot changes listed above and rebuild from `cfb0ce6348e81bbaf7e64c02ea18cb99bf989615`.
