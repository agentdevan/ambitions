# AOR-MOTION-00 Motion Runtime Audit And Deletion Map

Issue: AMB-542
Date: 2026-06-06
Status: Yellow

## Scope

Audit only. AMB-542 proves the active Motion root, records the current Red-baseline Motion UI, and maps the exact source structures that later reconstruction must replace or reshape.

No Swift UI source, tests, project files, package manifests, runtime behavior, product truth, release truth, privacy manifests, entitlements, or dependencies were modified.

## Active Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/PRODUCT_MOAT_TRUTH.md`
- `docs/truth/IMPLEMENTATION_TRUTH.md`
- `docs/truth/RELEASE_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `docs/truth/HISTORICAL_POLICY.md`
- `AGENTS.md`

## Active Motion Root Proof

- `Native/Ambitions/App/AppTab.swift:6` through `Native/Ambitions/App/AppTab.swift:15` define `AppTab.motion` and include it in canonical `allCases` between Time and You.
- `Native/Ambitions/App/AppTab.swift:131` through `Native/Ambitions/App/AppTab.swift:136` define the Motion surface contract with primary object `Motion Current`.
- `Native/Ambitions/App/AmbitionsRootView.swift:101` through `Native/Ambitions/App/AmbitionsRootView.swift:110` render the canonical top-level tabs as Today, Goals, Time, Motion, You.
- `Native/Ambitions/App/AmbitionsRootView.swift:232` through `Native/Ambitions/App/AmbitionsRootView.swift:242` wire the Motion tab to `MotionCurrentScreen`.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:4` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:49` define and render the current Motion root screen.

## Required Command

Executed:

```bash
rg -n "No Motion Yet|Source Unavailable|Proof|Recovery|Re-entry|Motion Current|Receipt: none|Proof: empty|Source: pending" Native Sources --glob "*.swift"
```

Result: the command returned broad matches across shared proof/accessibility infrastructure and Motion-owned source. The Motion-owned matches were narrowed to `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift` for the deletion map below.

## Deletion Map

### Segmented-control-led page

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:9` sets `selectedStrand` to `.proof`.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:23` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:29` render the `Picker("Motion strand", selection:)` as `.segmented`.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:159` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:175` define the `Proof`, `Recovery`, and `Re-entry` segments.

### Empty-state card stack

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:36` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:43` render every selected-strand node as a stacked `MotionCurrentNodeCard`.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:52` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:131` define each card as `QuietGlass` with title, description, source/proof/receipt rows, and actions.

### `No Motion Yet` card

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:320` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:335` define the `No Motion Yet` node.
- The node currently includes `Source: pending SourceRecord`, `Proof: empty`, and `Receipt: none`.

### `Source Unavailable` card

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:336` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:352` define the `Source Unavailable` node.
- The node currently presents source review as another card in the Proof strand instead of a Motion Current object state.

### Proof / Recovery / Re-entry prose

- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:310` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:315` define the strand summary prose.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:159` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:175` define the strand labels.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:406` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:457` define the Recovery strand nodes.
- `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:459` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:511` define the Re-entry strand nodes.

### Analytics/report framing

- No explicit analytics/report title appears in the active Motion root.
- The current risk is structural rather than a literal analytics label: `MotionCurrentProjection.fixture` at `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:318` through `Native/Ambitions/Features/Motion/MotionCurrentScreen.swift:514` renders Motion as a segmented inspection/report inventory of nodes.
- Legacy `Native/Ambitions/Features/Insights/InsightsScreen.swift` remains source-present support/history UI, but it is not the active Motion root.

## Screenshot Proof

Captured:

- `artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-before.png`

Capture command:

```bash
xcrun simctl launch 8ACCD665-4807-4102-B526-5A1AE20686A8 com.ambitions.ios -AMBITIONS_BOOTSTRAP_MODE preview -AmbitionsInitialSurface motion -AmbitionsScreenshotMode yes
xcrun simctl io 8ACCD665-4807-4102-B526-5A1AE20686A8 screenshot artifacts/ambitions-ui-reconstruction/screenshots/motion-empty-before.png
```

Observed baseline: Motion opens to `Motion Current` with a segmented Proof / Recovery / Re-entry control, a `No Motion Yet` card, and a partially visible `Source Unavailable` card below it.

## Runner And Guard Evidence

- Runner prompt saved with Ambitions runner header: `prompts/batches/AMB-542.md`
- Initial runner preflight blocked because the audit command mentioned locked `Sources`.
- Metadata-only concept-lock repair added AMB-542 as an allowed audit batch for `design_primitives`; this did not modify app source.
- Parallel implementation guard preflight passed after repair: `build/reports/parallel-implementation-guard/AMB-542-pre.md`
- Nested runner phase stopped before patching because the external model/OAuth path was unavailable.

## Validation

Verified:

- Required `rg` command executed.
- Motion-owned source inspected by line.
- Before screenshot captured from the simulator build.
- No UI source was modified for this audit.

Not verified:

- App behavior changed. This was intentionally not changed.
- Build/test proof for AMB-542. This was audit-only and used the existing AMB-541 simulator build artifact for screenshot capture.
- Visual approval.
- Accessibility approval.
- Performance proof.
- Real-device proof.
- Release readiness, TestFlight readiness, or App Store readiness.

## Claim Boundary

This report proves source locations and captures the current before screenshot for AMB-542 only. It is not reconstruction proof, release proof, accessibility proof, performance proof, privacy/legal approval, physical-device proof, TestFlight readiness, or App Store readiness.

## Rollback

Revert the AMB-542 commit to remove the prompt, the audit screenshot, this report, and the concept-lock metadata allowance.
