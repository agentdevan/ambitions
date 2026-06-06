# AOR-CHROME-00 Report - Header and Ribbon Demotion

Status: Green for scoped shell chrome consolidation; remaining feature-surface composition drift is assigned forward.
Issue: AMB-535
Date: 2026-06-06
Base commit: `f84d5bf37e2ab58122a6933e4403b3d71acb5dab`

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
- `artifacts/ambitions-ui-reconstruction/reports/AOR-TODAY-04-report.md`

## Scope

AMB-535 demoted the active shared shell chrome after AMB-534 accepted Today as no-hard-red Yellow. The patch removes the default shell continuity ribbon from active top-level tab chrome, removes the top-level shell avatar badge, and makes non-Today shell orientation a compact one-line context crown. It does not change the five-tab IA, Capture routing, tab bar ownership, runtime data, persistence, or feature-local surface object design.

## Changed Source

- `Native/Ambitions/App/AppShellView.swift`
  - `AppShellHeaderRail` now renders only `headerRow` plus the divider.
  - Removed the default `AmbitionContinuityRibbon` from active shell chrome.
  - Removed the top-level non-back-route avatar badge from the shell rail.
  - Demoted title/subtitle to a compact one-line context crown.
  - Keeps continuity language in the accessibility summary instead of a visible ribbon.
  - Keeps detail/back-route shell material and shadow behavior only where `onBack` exists.
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
  - Updated the canonical shell UI test to the current shell contract:
    - `shell.header.rail` exists.
    - `shell.continuity-ribbon` does not exist by default.
    - `shell.today.capture-button` and `shell.today.memory-lens-button` exist.
    - Motion uses the current `motion.current.screen` identifier.
    - Removed obsolete You section-title expectation while keeping current Memory and Trust Center row checks.
- `prompts/batches/AMB-535.md`
  - Runner header and AMB-535 issue contract are installed.

## Chrome Rules Documented

- The shared shell rail is a compact orientation/capability crown, not a page header, prose banner, status ribbon, or feature summary.
- Continuity/status language must not appear as a default top-level shell ribbon.
- Feature-owned primary objects may still have their own composition/object framing until the owning surface issue reconstructs that surface.
- Capture remains a global contextual action through toolbar access and the activated bottom composer seam. Capture is not a tab, persistent FAB, feed, or chatbot.
- The top-level IA remains exactly `Today / Goals / Time / Motion / You`.

## Remaining Drift / Owner Assignment

The shared shell chrome is consolidated in AMB-535. Remaining large feature-owned chrome is intentionally not broadened into this shell patch:

| Surface | Remaining drift | Owner path |
|---|---|---|
| Goals | `TopLevelSurfaceCompositionBar(surface: .goals)` remains a large feature-owned composition band above Constellation Atlas. | Next Goals reconstruction issue in the active AMB-536+ sequence. |
| Time | `TopLevelSurfaceCompositionBar(surface: .time)` remains above LifeShape Field. | Next Time reconstruction issue in the active AMB-536+ sequence. |
| You | `TopLevelSurfaceCompositionBar(surface: .you)` remains above User System Profile. | Next You reconstruction issue in the active AMB-536+ sequence. |
| Capture support route | Capture still has `TopLevelSurfaceCompositionBar(surface: .capture)` plus `ContextCrownHeader`; AOR-012 classified this as highest-risk support-route chrome clutter. | Capture reconstruction issue in the active AMB-536+ sequence. |
| Motion | Motion no longer gets a large shared shell ribbon, but feature-local proof/current composition still needs visual review under Motion owner. | Motion reconstruction issue in the active AMB-536+ sequence. |

## Screenshot Evidence

All screenshots were captured from the booted `iPhone 17e` simulator at 1170 x 2532 after the final AMB-535 build, using `SIMCTL_CHILD_AMBITIONS_BOOTSTRAP_MODE=preview`, `-AmbitionsInitialSurface <surface>`, and `-AmbitionsScreenshotMode YES`.

- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-today-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-goals-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-time-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-motion-after-final.png`
- `artifacts/ambitions-ui-reconstruction/screenshots/chrome-you-after-final.png`

Before evidence for the removed ribbon is retained in prior AMB-534 screenshots such as `today-source-unavailable-manual-after-final.png`, where the shell continuity message occupied the top chrome. AMB-535 after-screenshots show that the shared continuity ribbon is no longer active.

## Validation

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-535 prompts/batches/AMB-535.md`
  - Champion coverage Green.
  - Parallel implementation guard pre Green.
  - Nested Phase 01 stopped before source patch due runner model usage limit: retry after `2026-06-11 00:31`.
- `git diff --check`
  - Passed.
- `make xcode-build-for-testing BATCH=AMB-535`
  - Passed.
- `make xcode-focused-test BATCH=AMB-535 TEST=AmbitionsUITests/AmbitionsUITests/testPreviewBootstrapExposesCanonicalFiveTabShellAndSecondarySurfaces`
  - Passed after stale shell/UI selectors were repaired.
- Simulator screenshot capture for Today, Goals, Time, Motion, and You.
  - Passed; all AMB-535 after-screenshots are 1170 x 2532.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-535 --prompt prompts/batches/AMB-535.md --changed-from f84d5bf37e2ab58122a6933e4403b3d71acb5dab --batch-type source-changing`
  - Green.
  - Report: `build/reports/parallel-implementation-guard/AMB-535-post.md`.

## Proof Boundaries

- This proves scoped shared shell chrome consolidation, local build success, the focused shell UI contract, and simulator screenshot evidence.
- This does not prove final visual approval for Goals, Time, Motion, You, or Capture.
- This does not prove human accessibility review, full VoiceOver traversal, real-device behavior, performance, privacy/legal approval, CI proof, release readiness, TestFlight readiness, or App Store readiness.

## Rollback

Revert the AMB-535 commit, or remove the source/test/report/prompt/screenshot changes listed above and rebuild from `f84d5bf37e2ab58122a6933e4403b3d71acb5dab`.
