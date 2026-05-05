# FVQ02 Top-Level Surface Visual Sweep Report
<!-- markdownlint-disable MD013 -->

Result: Accepted Yellow
Date: 2026-05-05
Train: FVQ Visual Excellence Train
Batch: FVQ02 Five Top-Level Surface Visual Sweep
Owner: Top-Level Surfaces / Visual Quality

## Summary

FVQ02 captured durable simulator screenshots for all five locked top-level tabs
and repaired the generic `TopLevelSurfaceCompositionBar` explainer-card pattern
from Goals, Capture, Plan, and You. Today had already received the same repair
in FVQ01.

The batch closes Accepted Yellow because all five tabs are now credible enough
to continue visual gating without a known Hard Visual Red, but several surfaces
remain below final flagship bar and require future visual owner batches.

## Files Inspected

- `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md`
- `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md`
- `docs/codex/GLOBAL_RENDERED_VISUAL_EXCELLENCE_OVERLAY.md`
- `.codex/skills/faang-rendered-visual-reviewer.md`
- `Native/Ambitions/Features/Today/TodayScreen.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/Ambitions/App/AppMeridianShell.swift`
- `Native/Ambitions/App/AppExternalRouting.swift`

## Files Changed

- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/Ambitions/Features/Captures/CapturesScreen.swift`
- `Native/Ambitions/Features/Plan/PlanScreen.swift`
- `Native/Ambitions/Features/Profile/ProfileScreen.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- `docs/audits/visual-evidence/fvq02/today-default.png`
- `docs/audits/visual-evidence/fvq02/goals-default.png`
- `docs/audits/visual-evidence/fvq02/capture-default.png`
- `docs/audits/visual-evidence/fvq02/plan-default.png`
- `docs/audits/visual-evidence/fvq02/you-default.png`
- `docs/audits/visual-evidence/fvq02/screenshot-freshness.json`
- `docs/audits/visual-evidence/fvq02/top-level-reduce-motion.md`
- `docs/audits/visual-evidence/fvq02/visual-scorecard.md`
- `docs/audits/fvq02-top-level-surface-visual-sweep-report.md`
- global order, registry, context, and run-state docs

## Repair

FVQ02 found that Goals, Capture, Plan, and You were led by the same generic
top-level composition explainer card. This made the screens feel like a
component proof layer before their real product object appeared.

Repair performed:

- Removed `TopLevelSurfaceCompositionBar(surface: .goals)`.
- Removed `TopLevelSurfaceCompositionBar(surface: .capture, ...)`.
- Removed `TopLevelSurfaceCompositionBar(surface: .plan)`.
- Removed `TopLevelSurfaceCompositionBar(surface: .you)`.
- Updated focused UI smoke expectations so Goals waits for the current primary
  object (`goals.mission-control-lanes` / LifePath) instead of only the legacy
  `goals.hero-card` contract.

No route/raw-value, persistence/schema, sync/account, signing, entitlement,
workflow, legal/privacy, release, AI runtime, AOS runtime, or LDI runtime file
changed.

## Evidence

- `docs/audits/visual-evidence/fvq02/today-default.png`
- `docs/audits/visual-evidence/fvq02/goals-default.png`
- `docs/audits/visual-evidence/fvq02/capture-default.png`
- `docs/audits/visual-evidence/fvq02/plan-default.png`
- `docs/audits/visual-evidence/fvq02/you-default.png`
- `docs/audits/visual-evidence/fvq02/screenshot-freshness.json`
- `docs/audits/visual-evidence/fvq02/visual-scorecard.md`

## Remaining Yellow Items

- App runtime still does not expose build SHA.
- Dynamic Type screenshots were not captured.
- Reduce Motion screenshots were not captured.
- Manual VoiceOver traversal was not performed.
- Measured contrast proof was not performed.
- Physical-device proof was not performed.
- Human design review remains pending.
- Goals still needs LifePath / MissionControlTimeSpine visual strengthening.
- You still needs Personal System Center density and shell-overlap repair.
- The floating global action lane can make direct right-edge tab tapping
  unreliable; You evidence used the canonical `ambitions://tab/profile` route.

## Validation

- `git status --short`: dirty before commit with FVQ02 scoped changes.
- `git fetch origin`: origin/main matched local HEAD before FVQ02 screenshots.
- `git pull --ff-only origin main`: fast-forwarded remote FVQ insertion report.
- `xcodegen generate`: passed.
- `scripts/build-local.sh`: passed; log
  `output/logs/build-local-20260505-141445.log`.
- `build_run_sim CODE_SIGNING_ALLOWED=NO`: simulator build and run passed.
- Focused top-level UI pack:
  `xcodebuild -project Ambitions.xcodeproj -scheme Ambitions -destination
  'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO ...`
  failed with 3 known Yellow items after repair; result bundle
  `/Users/devan/Library/Developer/Xcode/DerivedData/Ambitions-clensfmdeeuxsueugpmolbvkzbxq/Logs/Test/Test-Ambitions-2026.05.05_15-05-10--0400.xcresult`.
  Passing tests: Goals top-level modules, Capture launch URL, Today dominant
  hero/primary action. Remaining failures: Plan deep pressure-scrubber
  accessibility discovery, preview shell Plan deep module discovery, and You
  row discovery after right-edge tab/opening reliability. These are retained
  as Accepted Yellow because they do not invalidate the screenshot-backed
  top-level visual repair.
- `git diff --check`: passed.
- Touched-file trailing whitespace scan: passed.
- `scripts/cqs-product-drift-scan.sh ... || true`: advisory pass on first
  scanned root with `CQS_PRODUCT_DRIFT_HITS=0`.
- `scripts/cqs-accessibility-motion-scan.sh ... || true`: advisory Yellow for
  existing foreground-style/motion scan hits in `GoalsScreen.swift`.
- `scripts/run-doc-qa.sh || true`: advisory backlog only; stale guidance,
  deprecated-language, and markdownlint findings remain pre-existing, lychee
  reported 650 OK / 0 errors.
- `scripts/batch-train-gate-check.sh || true`: advisory Yellow for dirty
  FVQ02 worktree before commit.

## Red Classification

Initial classification: Recoverable Visual Red for generic top-level explainer
cards on Goals, Capture, Plan, and You.

Final classification: Accepted Yellow. No Hard Visual Red remains after the
focused repair, but FVQ02 does not claim final visual signoff, Apple Design
Award readiness, public accessibility conformance, App Store readiness,
TestFlight readiness, legal/privacy compliance, or physical-device proof.

## Rollback Path

Revert the FVQ02 commit to restore the generic top-level composition bars and
remove FVQ02 screenshot/report/state updates.

## Next Eligible Batch

Under `GLOBAL_RENDERED_VISUAL_EXCELLENCE_OVERLAY.md`, FVQ03 Drill-Down And
External Surface Visual Sweep is next after FVQ02 accepted Yellow.
