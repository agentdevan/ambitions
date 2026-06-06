# AOR-TIME-00 Report - Time Runtime Audit and Deletion Map

Status: Green
Issue: AMB-538
Date: 2026-06-06
Base commit: `97988643758ed3b8aff3ae2f083b44523809b821`

## Truth Files Inspected

- `docs/truth/README.md`
- `docs/truth/PRODUCT_DESIGN_TRUTH.md`
- `docs/truth/CODEX_PROCESS_TRUTH.md`
- `AGENTS.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-001-report.md`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-CHROME-02-report.md`

## Scope

AMB-538 is an audit and deletion-map issue. No Time UI source, shared primitive source, routing source, test source, project file, or runtime behavior was modified.

Active Time canon remains LifeShape Field / Time Texture: capacity, pressure, protected time, recovery need, source state, and goal load. Time must not become a calendar grid, free/busy calendar, schedule optimizer, productivity score, or resource-allocation UI.

## Active Time Root Proof

- `Native/Ambitions/App/AmbitionsRootView.swift:101-103` owns the Time tab in the active root `TabView`.
- `Native/Ambitions/App/AmbitionsRootView.swift:179-187` routes the Time tab through `timeNavigation()` into `TimeScreen(showsNavigationChrome: false)`.
- `Native/Ambitions/Features/Time/TimeScreen.swift:21-90` is the active Time root body.
- `Native/Ambitions/Features/Time/TimeScreen.swift:43-82` renders the loaded Time state in this order:
  - `TimeLifeShapeField`
  - `TimeHeroCard`
  - `TimeScopeChipStrip`
  - `TimeCapacityEnvelopeCard`
  - optional empty state
  - `TimeShapeDepthDisclosure`

## Before Screenshot

Required artifact captured:

- `artifacts/ambitions-ui-reconstruction/screenshots/time-default-before.png`
  - PNG, 1170 x 2532.

Capture command:

```bash
xcrun simctl launch booted com.ambitions.ios -AMBITIONS_BOOTSTRAP_MODE preview -AmbitionsInitialSurface time -AmbitionsScreenshotMode yes
xcrun simctl io booted screenshot artifacts/ambitions-ui-reconstruction/screenshots/time-default-before.png
```

Screenshot observation:

- The first viewport repeats LifeShape framing through the surface composition bar and the primary LifeShape panel.
- The Calendar pill is truncated as `Calendar stays optio...`.
- Day / Week / Life mini-cards dominate the first viewport and push detail below the fold.
- Capacity labels are low contrast at the bottom of the mini-cards.
- Time still avoids a literal calendar grid, but the root reads as stacked cards/chips rather than one primary LifeShape object.

## Deletion Map

| Structure | Owner / lines | Classification | Reason |
|---|---|---|---|
| Active root card stack | `TimeScreen.swift:43-82` | Absorb into LifeShape Field | Time currently renders LifeShape plus hero, chip strip, capacity card, and depth disclosure as separate top-level modules. Reconstruction should collapse root meaning into one LifeShape object before exposing detail. |
| Surface composition bar | `TimeScreen.swift:28`; `TopLevelSurfaceCompositionPrimitives.swift:23-29`, `63-69`, `101-103` | Keep with reason, then visually demote | It preserves cross-surface grammar and the Time primary object, but the screenshot shows it creates duplicate first-viewport LifeShape framing. |
| LifeShape Field wrapper | `TimeLifeShapeField.swift:222-269` | Keep and reconstruct | This is the canonical Time primary object owner. It should remain the reconstruction center. |
| Calendar optional pill | `TimeLifeShapeField.swift:272-287` | Move behind Trust Seam or compact source row | It is source/boundary evidence, but as a right-aligned chip it truncates in the first viewport and competes with the primary object title. |
| Day / Week / Life mini-card buttons | `TimeLifeShapeField.swift:290-320`, `329-373` | Absorb into LifeShape Field | They encode useful horizon contours but currently behave like three separate cards. They should become a unified field/texture with selectable contours, not three equal card columns. |
| Local contour drawing | `TimeLifeShapeField.swift:387-407`, `428-457`, `468-478` | Absorb into LifeShape Field | Capsule contour, milestone ridge, pressure field, and pocket row are meaningful Time Texture elements, but should be part of one object canvas instead of per-card decorations. |
| Capacity prose on mini-cards | `TimeLifeShapeField.swift:115-123`, `350-361` | Absorb into LifeShape Field | `Day can hold`, `Week has room`, and `Life direction visible` are useful qualitative labels, but current placement is low-contrast and partially buried in card bottoms. |
| Selected contour prose band | `TimeLifeShapeField.swift:481-531` | Move behind Trust Seam | It contains source, privacy, pressure, proof opportunity, and boundary detail. That belongs in inspectable depth after the primary object is understood, not always visible as a prose stack. |
| LifeShape drill-down panel | `TimeLifeShapeField.swift:246`; `TimeLifeShapeDrillDownPanel.swift:10-28`, `42-87`, `90-126` | Move behind Trust Seam / detail | The drill-down grid and long summary label stack are valuable inspection content, but they add card-grid density to the primary root. |
| Pressure toggle | `TimeLifeShapeField.swift:248-256` | Keep with reason | Revealing pressure is a legitimate Time interaction. It should remain as an object-level control after the field is reconstructed. |
| Evidence label | `TimeLifeShapeField.swift:258-264`; `TimeFoundationCards.swift:100-106` | Absorb into LifeShape Field / Trust Seam | Source evidence is required, but repeated labels create extra chrome. Use one consistent source/receipt affordance. |
| Time scope chip strip | `TimeScreen.swift:48`, `339-366` | Delete as top-level module | Day/Week/Month chips duplicate horizon meaning already present in LifeShape. Horizon control should live inside the primary object. |
| Capacity envelope card | `TimeScreen.swift:50`; `TimeFoundationCards.swift:83-117` | Absorb into LifeShape Field | Capacity is the heart of Time. It should not sit as a separate dashboard card below the field. |
| Depth disclosure stack | `TimeScreen.swift:68-82`, `244-336` | Move behind Trust Seam / detail | The disclosure contains many valid Time subsurfaces, but as an expanded card stack it risks dashboard behavior. |
| Calendar awareness card | `TimeScreen.swift:286`; `TimeScreen.swift:369-413` | Move behind Trust Seam | Calendar remains optional source state, not the root. Keep as source/boundary detail. |
| Opportunity windows and decision cards | `TimeScreen.swift:287-308`, `427-487`, `490-520` | Move behind detail | Useful Time decisions should appear after the primary field establishes capacity and fit. |
| Legacy `TimeLifeSuiteCard` | `TimeLifeSuiteCard.swift:4-41`, `44-95` | Preview-only / stale owner candidate | It wraps `TimeLifeShapeField` in `AppCard` and adds a second LifeSuite tile grid; not used by active `TimeScreen` scan, but should not be revived for root reconstruction. |

## Local Styling Overrides

- `TimeLifeShapeField.swift:222-269` uses shared `StateDrivenMaterialPanel`, but nested `RoundedRectangle` backgrounds and overlays at `365-372`, `525-528`, and drill-down lines `20-24`, `115-124` create local card/chip chrome inside the primary object.
- `Sources/Components/AmbitionsPremiumMaterials.swift:150-216` defines shared `QuietGlass` / `GraphiteRecess` primitives.
- `Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift:272-281` records the Time accessibility strategy: preserve schedule intent with compact rows, reduce decorative LifeShape density at accessibility sizes, protect window chips with expanded controls, and keep structured text before texture-like motion visuals.

## Validation

- `ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-538 prompts/batches/AMB-538.md`
  - Champion coverage Green.
  - Source-changing pre-guard Red because this audit prompt names locked `time_plan_lifeshape` and `design_primitives` owners.
  - No app source patch was produced by the runner.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase pre --batch AMB-538 --prompt prompts/batches/AMB-538.md --batch-type audit-only`
  - Green.
- Source/line reads:
  - `nl -ba Native/Ambitions/Features/Time/TimeScreen.swift`
  - `nl -ba Native/Ambitions/Features/Time/TimeLifeShapeField.swift`
  - `nl -ba Native/Ambitions/Features/Time/TimeLifeShapeDrillDownPanel.swift`
  - `nl -ba Native/Ambitions/Features/Time/TimeFoundationCards.swift`
  - `nl -ba Native/Ambitions/Features/Time/TimeLifeSuiteCard.swift`
  - `nl -ba Sources/Components/TopLevelSurfaceCompositionPrimitives.swift`
  - `nl -ba Sources/Components/AmbitionsPremiumMaterials.swift`
  - `nl -ba Sources/Components/AccessibilityAdaptiveInterfacePrimitives.swift`
- XcodeBuildMCP `build_run_sim`
  - Timed out after 120 seconds before returning build/run proof.
- Simulator screenshot path:
  - Used already installed preview app on booted iPhone 17e.
  - `xcrun simctl launch booted com.ambitions.ios -AMBITIONS_BOOTSTRAP_MODE preview -AmbitionsInitialSurface time -AmbitionsScreenshotMode yes`
  - `xcrun simctl io booted screenshot artifacts/ambitions-ui-reconstruction/screenshots/time-default-before.png`
  - Captured PNG 1170 x 2532.
- `git diff --check`
  - Passed.
- `python3 scripts/ambitions-parallel-implementation-guard.py --phase post --batch AMB-538 --prompt prompts/batches/AMB-538.md --changed-from 97988643758ed3b8aff3ae2f083b44523809b821 --batch-type audit-only`
  - Green.

## Proof Boundaries

- This proves the current source audit, deletion map, and current before screenshot artifact.
- This does not prove Time reconstruction, build success, test success, visual approval, accessibility conformance, performance, real-device behavior, privacy/legal approval, CI proof, TestFlight readiness, App Store readiness, or release readiness.

## Rollback

Remove this report, `prompts/batches/AMB-538.md`, and `artifacts/ambitions-ui-reconstruction/screenshots/time-default-before.png` to return to the prior AMB-537 closeout state.
