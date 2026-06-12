# AMB-963 / UIQL-008 Goals Reconstruction Proof

Status: Green for scoped AMB-963 Goals Reconstruction, local commit pending
Date: 2026-06-11
Branch: main
Base commit before AMB-963 work: `fbc3531d49df10376f7a5c57aea214a1e9018e13`
Closeout commit: pending at artifact creation
Push status: not pushed; owner will push manually when GitHub is fixed

## Claim

Goals now presents `Your Direction` as a Constellation Atlas plus Orbital Lens experience for the user job, "What is my life pointed at?"

The scoped AMB-963 repair:

- updates active Goals truth from the transitional `Direction Atlas` wording to `Constellation Atlas + Orbital Lens`;
- keeps the visible root title as `Your Direction`;
- keeps Life Areas equal-weight and manually ordered;
- removes visible `Direction Atlas` from the scoped Goals proof path;
- uses `Thread Focus` as the user-facing Orbital Lens label;
- repairs selected life-area text truncation by using a visible scope icon plus accessibility value instead of a clipped `Selected` label;
- prioritizes the Orbital Lens in proof-available states so `Proof available`, `Source`, and `Why this?` are visible proof, not hidden behind the dock;
- adds a dedicated AMB-963 screenshot matrix covering default, selected life area, proof/source visible, and large Dynamic Type/text-wrap states.

## Touched Files

- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/codex/ambitions_primitive_invention_registry.md`
- `Native/Ambitions/Features/Goals/GoalComponents.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureModels.swift`
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift`
- `Native/Ambitions/Features/Goals/GoalsOverviewProjector.swift`
- `Native/Ambitions/Features/Goals/GoalsScreen.swift`
- `Native/AmbitionsTests/Goals/GoalsObjectStagePrimitiveTests.swift`
- `Native/AmbitionsTests/Goals/GoalsOverviewBoardTests.swift`
- `Native/AmbitionsUITests/AmbitionsUITests.swift`
- UIQL artifacts, proof ledger, screenshots, and script-output logs

## Validation

- `git diff --check`
  - Exit code: `0`
- `bash .agents/skills/uiql-quality-lockdown/scripts/uiql-mini-regression.sh`
  - Exit code: `0`
  - Logs: `artifacts/ui-quality-lockdown/script-output/uiql-banned-copy.log`, `artifacts/ui-quality-lockdown/script-output/uiql-card-anatomy.log`, `artifacts/ui-quality-lockdown/script-output/uiql-shell.log`
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8 -only-testing:AmbitionsUITests/AmbitionsUITests/testAMB963GoalsReconstructionScreenshotMatrix`
  - Exit code: `0`
  - Result bundle: `artifacts/ui-quality-lockdown/script-output/AMB-963-goals-screenshot-matrix-rerun11.xcresult`
  - Log: `artifacts/ui-quality-lockdown/script-output/AMB-963-goals-screenshot-matrix-rerun11.log`
  - Result: 1 UI test executed, 0 failures
- `xcodebuild test -project Ambitions.xcodeproj -scheme Ambitions -destination id=8ACCD665-4807-4102-B526-5A1AE20686A8` with focused Goals selectors:
  - `AmbitionsTests/GoalsObjectStagePrimitiveTests`
  - `AmbitionsTests/GoalsOverviewAtlasTests/testAFI07GoalsConstellationAtlasKeepsThreadsConnectedToTodayWithoutTopLevelMissionControl`
  - `AmbitionsTests/GoalsOverviewAtlasTests/testAFRI024GoalsConstellationAtlasExposesInspectableLocalSourceReceiptAndReplayBasis`
  - Exit code: `0`
  - Result bundle: `artifacts/ui-quality-lockdown/script-output/AMB-963-goals-focused-unit-tests-rerun3.xcresult`
  - Log: `artifacts/ui-quality-lockdown/script-output/AMB-963-goals-focused-unit-tests-rerun3.log`
  - Result: 6 tests executed, 0 failures

## Screenshot Matrix

Final passing screenshots are exported under `artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/`:

- Default Goals: `amb-963-goals-default.png`
- Selected life area: `amb-963-goals-selected-life-area.png`
- Proof/source visible: `amb-963-goals-proof-source-visible.png`
- Large Dynamic Type / text-wrap proof: `amb-963-goals-large-dynamic-type.png`
- Manifest: `manifest.json`

## Visual Evaluation

Current screenshots were visually inspected after export.

Green observations:

- Default and selected-life-area states show `Your Direction`, equal-weight Life Areas, and Thread Focus framing without visible `Direction Atlas`.
- Selected life-area state no longer truncates the selected indicator; the selected state is visible through the scope icon, accent rail, and accessibility value.
- Proof/source state visibly exposes `Proof available`, `Source`, and `Why this?` above the dock, with no header/content collision.
- Large Dynamic Type/text-wrap state keeps `Your Direction`, `Equal-weight areas`, `Career`, `Music`, `Fitness`, `Money`, and the dock labels readable; the previous `Sel...` truncation is gone.
- The visible Goals proof path does not present a KPI dashboard, category-card portfolio, generic list, calendar clone, chatbot wrapper, or admin/spec/debug surface.

## Repair Evidence

Failed/intermediate matrix runs are retained as repair evidence only:

- `AMB-963-goals-focused-unit-tests-rerun1.log`
- `AMB-963-goals-focused-unit-tests-rerun2.log`
- `AMB-963-goals-screenshot-matrix-rerun1.log`
- `AMB-963-goals-screenshot-matrix-rerun2.log`
- `AMB-963-goals-screenshot-matrix-rerun3.log`
- `AMB-963-goals-screenshot-matrix-rerun4.log`
- `AMB-963-goals-screenshot-matrix-rerun5.log`
- `AMB-963-goals-screenshot-matrix-rerun6.log`
- `AMB-963-goals-screenshot-matrix-rerun7.log`
- `AMB-963-goals-screenshot-matrix-rerun8.log`
- `AMB-963-goals-screenshot-matrix-rerun9.log`
- `AMB-963-goals-screenshot-matrix-rerun10.log`

These logs do not support Green claims; they explain the repair path documented in `UIQL-008-AMB-963_REPAIR_REFRAME_REPORT.md`.

## Yellow Tooling Limits

- Accessibility-size launch variants failed to expose the Goals screen reliably in earlier screenshot attempts. AMB-963 closes on large Dynamic Type/text-wrap proof, not full accessibility certification.
- The preview/manual empty state failed as a screenshot harness path and is not used for AMB-963 Green.
- The local repository is ahead of `origin/main` because GitHub push is unavailable; AMB-963 must remain push-pending in Linear until the owner manually pushes.

## No-Claim Boundaries

This proof does not claim:

- owner approval;
- release readiness, TestFlight readiness, or App Store readiness;
- physical-device proof;
- full accessibility certification;
- VoiceOver certification;
- performance proof;
- privacy/legal approval;
- PLOS runtime completeness;
- Time, Motion, You, Capture, or Create Goal reconstruction completion;
- AMB-964 or later UIQL issue completion;
- that AMB-963 is closed in Linear before the local commit is pushed to `main`.

## Linear Closeout Text

Use this for AMB-963 after the commit is pushed:

```text
AMB-963 / UIQL-008 Goals Reconstruction is complete.

Commit: <commit hash>

Scope:
- Reconstructed Goals around Your Direction as Constellation Atlas + Orbital Lens.
- Updated active Goals truth to remove Direction Atlas as active visible UI framing.
- Kept Life Areas equal-weight and manually ordered.
- Kept Thread Focus as the user-facing Orbital Lens label.
- Repaired selected life-area truncation.
- Prioritized proof/source Orbital Lens state so Proof available, Source, and Why this? are visible above the dock.

Validation:
- git diff --check: passed
- UIQL mini-regression: passed
- AMB-963 screenshot matrix UI test: passed, 1 test / 0 failures
- Focused Goals unit tests: passed, 6 tests / 0 failures

Artifacts:
- Proof: artifacts/ui-quality-lockdown/UIQL-008-AMB-963-goals-reconstruction.md
- Repair reframe: artifacts/ui-quality-lockdown/UIQL-008-AMB-963_REPAIR_REFRAME_REPORT.md
- Final screenshot matrix: artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/
- UI test log: artifacts/ui-quality-lockdown/script-output/AMB-963-goals-screenshot-matrix-rerun11.log
- Focused unit log: artifacts/ui-quality-lockdown/script-output/AMB-963-goals-focused-unit-tests-rerun3.log

Red blockers: none for scoped AMB-963.
Yellow: no physical-device proof, no full accessibility certification, no owner approval, no release/TestFlight/App Store readiness claim.
Next dependency: AMB-964 / UIQL-009 Time Reconstruction.
```

If the commit has not been pushed yet, use this manual/push-pending comment instead:

```text
AMB-963 / UIQL-008 Goals Reconstruction is locally complete but not pushed yet.

Local commit: <commit hash>
Push status: pending; owner will push main manually when GitHub is fixed.

Do not move AMB-963 to Done until the commit is visible on main.

Validation:
- git diff --check: passed
- UIQL mini-regression: passed
- AMB-963 screenshot matrix UI test: passed, 1 test / 0 failures
- Focused Goals unit tests: passed, 6 tests / 0 failures

Artifacts:
- Proof: artifacts/ui-quality-lockdown/UIQL-008-AMB-963-goals-reconstruction.md
- Final screenshots: artifacts/ui-quality-lockdown/screenshots/amb-963/rerun11/

Next dependency after push/Linear closeout: AMB-964 / UIQL-009 Time Reconstruction.
```
