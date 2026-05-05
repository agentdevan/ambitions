# FVQ Visual Excellence Layer Insertion Report
<!-- markdownlint-disable MD013 -->

Result: PASS WITH ACCEPTED YELLOW
Date: 2026-05-05
Scope: Docs / Codex OS / visual quality overlay only

## Task

Upgrade Ambitions' visual execution process so the app cannot keep moving through global batches while simulator output looks prototype-like, scaffolded, dashboard-like, or below FAANG-level flagship visual quality.

This update was requested while the main Codex global train was still running. Therefore, this work uses overlay/source-truth files rather than destructively rewriting live run-state or active local work.

## Live Repo Awareness

Live state was checked before creating the visual excellence layer:

- `current-run-state.md` was fetched from `main`; the connector returned the latest file metadata SHA.
- `GLOBAL_FULL_STACK_COMPLETION_ORDER.md` was fetched from `main`; the live SHA was `a8e94d1b2603613ba67f6f322a6161f6640da8f3` at inspection.
- Existing FVQ/MEG visual excellence files were checked before creation to avoid duplicate files.
- Because the main Codex run is active and may update global-order/run-state concurrently, the new visual system is also represented in `GLOBAL_RENDERED_VISUAL_EXCELLENCE_OVERLAY.md` so Codex can pick it up safely at the next pull.

## Files Created

- `docs/codex/visual-quality/FVQ_VISUAL_EXCELLENCE_TRAIN.md`
- `docs/codex/visual-quality/FVQ02_TOP_LEVEL_SURFACE_VISUAL_SWEEP.md`
- `docs/codex/visual-quality/FVQ03_DRILLDOWN_AND_EXTERNAL_SURFACE_VISUAL_SWEEP.md`
- `docs/codex/visual-quality/FVQ04_RECURRING_UI_BATCH_RENDERED_PROOF_PROTOCOL.md`
- `docs/codex/visual-quality/MEG01_ADVANCED_RENDERING_ELIGIBILITY_GATE.md`
- `docs/codex/batches/FVQ_VISUAL_EXCELLENCE_CONTINUATION_PROMPT.md`
- `docs/codex/GLOBAL_RENDERED_VISUAL_EXCELLENCE_OVERLAY.md`
- `docs/audits/fvq-visual-excellence-layer-insertion-report.md`

## Existing Related Files Preserved

- `docs/codex/visual-quality/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_GATE.md`
- `docs/codex/batches/FVQ01_RENDERED_VISUAL_FRESHNESS_AND_FLAGSHIP_PROMPT.md`
- `.codex/skills/faang-rendered-visual-reviewer.md`

## What This Adds

### FVQ01

Today-specific rendered visual freshness and flagship proof.

### FVQ02

All five top-level tabs must be rendered and scored:

- Today
- Goals
- Capture
- Plan
- You

### FVQ03

Drill-down and external surface visual audit:

- Step Detail
- Step Session
- Goal Detail / Mission Control
- LifeShape details
- Memory Lens
- Receipt Drawer
- Weekly Life Sweep
- Appearance Studio
- widgets
- Live Activities
- App Intents confirmations
- notifications
- App Store screenshots

### FVQ04

Recurring UI-batch rendered proof protocol. Future UI-affecting batches cannot close Green solely on compile/tests/docs.

### MEG01

Metal / advanced rendering eligibility gate.

Decision:

- Do not add Metal by default.
- Use SwiftUI and Canvas first.
- Metal is allowed only for named signature primitives when SwiftUI/Canvas is insufficient and performance, battery, accessibility, Reduce Motion, fallback, screenshot, and boundary requirements are met.

Candidate areas:

- Capture Atmosphere
- LifeShape Contour / Pressure Field
- MissionControlTimeSpine field rendering

Forbidden uses:

- fixing Today hierarchy
- fixing weak copy
- fixing tab/shell layout
- replacing native controls
- business logic
- navigation
- persistence
- trust/source logic

## Visual Hard Red Conditions Added

Visual Hard Red now includes:

- top-level tab looks like dashboard/card pile
- rendered screen looks like prototype/demo/scaffold
- Today looks like component proof screen
- Plan looks like calendar clone or analytics dashboard
- Goals looks like project-management/progress-card board
- Capture looks like inbox/feed
- You looks like generic settings dump
- screenshot cannot be proven fresh
- primary object is unclear
- Codex would need to weaken canon to pass

## Why Overlay Instead Of Direct Run-State Update

The active Codex run is moving. Editing run-state directly from a remote connector could overwrite or conflict with the active worker's latest local batch state. Instead:

- stable source-truth/gate files were added;
- the global visual overlay was added;
- Codex will pick up these files on its next pull;
- the active batch can finish safely before FVQ runs.

## Validation

This update was performed through the GitHub connector. Local shell validation was not available in this session. The following were not run here:

- `git status --short`
- `git diff --check`
- `scripts/run-doc-qa.sh`
- `scripts/batch-train-gate-check.sh`

The update remained docs/skill/overlay-only and did not edit production Swift, route/raw values, persistence/schema, workflows, signing, entitlements, CI, release, sync/cloud, monetization, AI runtime, or LDI runtime files.

## Accepted Yellow

- The active Codex run may already have started a later batch. The overlay instructs it to finish that batch safely and then run FVQ.
- Run-state/context files were not rewritten here to avoid colliding with live active work.
- No durable screenshots are produced by this insertion itself; FVQ must produce them when it runs.

## Next Expected Action

When the active Codex run pulls latest:

1. Finish any active batch safely.
2. Read `docs/codex/GLOBAL_RENDERED_VISUAL_EXCELLENCE_OVERLAY.md`.
3. Run FVQ01.
4. Run FVQ02.
5. Integrate FVQ04 recurring proof.
6. Apply MEG01 before any advanced rendering.
7. Resume global full-stack order only if no Hard Visual Red remains.
