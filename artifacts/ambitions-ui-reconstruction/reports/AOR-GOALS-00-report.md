# AOR-GOALS-00 Report

Issue: AMB-546
Status: Green for audit scope
Date: 2026-06-06

## Scope

AMB-546 is an audit and deletion map only. It proves the active Goals runtime root, captures the before screenshot, and maps the exact source that produces the Red-baseline Goals structures. No Goals UI source was modified and no reconstruction started.

Changed artifacts:

- `prompts/batches/AMB-546.md`
- `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-before.png`
- `artifacts/ambitions-ui-reconstruction/reports/AOR-GOALS-00-report.md`

## Active Goals Root

The active Goals root is:

```text
AmbitionsRootView.shellTabView
  -> Goals tab
  -> goalsNavigation()
  -> AppShellScaffold(title: "Goals", subtitle: "Direction")
  -> GoalsScreen(showsNavigationChrome: false)
```

Source evidence:

- `Native/Ambitions/App/AppTab.swift:13-15` keeps canonical top-level tabs as `Today / Goals / Time / Motion / You`.
- `Native/Ambitions/App/AppTab.swift:131-136` registers Goals with primary object title `Direction Atlas`.
- `Native/Ambitions/App/AmbitionsRootView.swift:91-112` renders the SwiftUI `TabView`; Goals is the second canonical tab.
- `Native/Ambitions/App/AmbitionsRootView.swift:156-172` constructs `goalsNavigation()` and injects `GoalsScreen(showsNavigationChrome: false)`.
- `Native/Ambitions/Features/Goals/GoalsScreen.swift:35-121` renders the active Goals scroll root and `goals.screen` accessibility identifier.
- `Native/Ambitions/App/AppBootstrapper.swift:153-177` supports `-AmbitionsInitialSurface goals`, used for the before screenshot.

## Screenshot Evidence

Captured:

- `artifacts/ambitions-ui-reconstruction/screenshots/goals-default-before.png`

Capture command shape:

```bash
xcrun simctl launch 81485ACD-AF10-4B92-8C03-9BB8805A4A23 com.ambitions.ios \
  -AMBITIONS_BOOTSTRAP_MODE preview \
  -AmbitionsInitialSurface goals \
  -AmbitionsScreenshotMode yes
xcrun simctl io 81485ACD-AF10-4B92-8C03-9BB8805A4A23 screenshot artifacts/ambitions-ui-reconstruction/screenshots/goals-default-before.png
```

Visual classification from current screenshot:

- Top shell header shows `Goals` / `Direction - Focus` and a generic Capture toolbar icon.
- First content object is a rounded `Constellation Atlas` intro panel with `Orbital Lens`, `Life Path`, and `Proof` chips.
- Second content object is a large rounded `Your Direction` panel.
- Proof lane shows a `Not yet` placeholder and clipped lower action/content inside the viewport.
- The default root reads as stacked rounded modules and chips rather than one Direction Atlas object.

## Deletion Map

| Red-baseline structure | Classification | Source evidence | Notes for reconstruction |
|---|---|---|---|
| Top explanation banner / Constellation Atlas intro panel | Migration target | `GoalsScreen.swift:36-39`; `TopLevelSurfaceCompositionPrimitives.swift:23-31`, `63-69`, `93-99`, `200-226`, `318-326` | `TopLevelSurfaceCompositionBar(surface: .goals)` renders the rounded intro panel, `Constellation Atlas`, orientation prose, mode pill, and supporting chips. Active truth now says Goals primary object is Direction Atlas; Constellation Atlas is compatibility/source evidence only. |
| Your Direction card | Migration target | `GoalsScreen.swift:51-56`; `GoalComponents.swift:73-108` | `GoalMissionControlLanes` wraps `Your Direction` in `AdaptiveModuleChrome`, producing the dominant rounded module visible after the intro panel. This should not remain a card-like top-level replacement for Direction Atlas. |
| Proof placeholder card/block | Migration target | `GoalComponents.swift:26-42`; `GoalComponents.swift:84-95` | When proof count is zero, the proof lane uses `Not yet` and `Proof will appear after progress is saved.` The screenshot shows this as a nested placeholder block inside `Your Direction`. |
| Stacked rounded module containers | Migration target | `GoalsScreen.swift:72-115`; `GoalComponents.swift:285-328`, `332-390`, `394-424`, `436-458`, `462-548`, `613-647`, `697-728`, `788-818`, `959-1015`, `1018-1070` | Goals root composes a vertical stack of `AppCard`, `AdaptiveModuleChrome`, `StateDrivenMaterialPanel`, and nested rounded rectangles. Later reconstruction should collapse the top-level stack into one Direction Atlas object with subordinate drill-downs. |
| Generic toolbar action | Supporting shell source, review required | `AmbitionsRootView.swift:285-297`; `AppShellView.swift:221-247`; `ShellCommandModels.swift:253` | The top-right square-pencil button is the global Capture toolbar fallback. It is canon-compatible as a quiet escape hatch but visually reads generic in the Goals baseline and should be reviewed in Goals polish work. |
| Clipped proof/status blocks | Migration target | `GoalComponents.swift:84-95`; `GoalComponents.swift:858-921`; screenshot `goals-default-before.png` | The screenshot shows the lower proof lane and action content partially clipped by the first viewport. Root reconstruction must make proof/status inspection legible without relying on clipped nested blocks. |
| Chips as primary state | Migration target | `TopLevelSurfaceCompositionPrimitives.swift:93-99`, `286-290`; `GoalComponents.swift:116-136`, `223-239`, `303`, `436-458`, `535-557`, `677-680`, `751-764`, `831-834`, `990`, `1083-1091` | Chips/pills currently carry root meaning: module list, Ready state, lifecycle/weather, counts, timing, archive states. Reconstruction should demote chips to secondary labels after Direction Atlas state is readable from object structure and text. |
| Constellation/Orbital compatibility naming | Stale source evidence / migration target | `TopLevelSurfaceCompositionPrimitives.swift:23-31`, `93-99`; `GoalComponents.swift:148-152`; `Sources/Theme/AmbitionsFrontendAuthority.generated.swift:67-85` | Active product truth prefers Direction Atlas; Constellation Atlas and Orbital Lens are source-compatibility names until a scoped migration changes them. |

## Validation

- `AUTO_BRANCH=0 ALLOW_DIRTY=1 scripts/ambitions-codex-train.sh AMB-546 prompts/batches/AMB-546.md`
  - Champion coverage: Green.
  - Parallel guard pre: Green, `build/reports/parallel-implementation-guard/AMB-546-pre.md`.
  - Nested phase stopped Red due Codex usage limit before source work. No app source changed.
- `make xcode-build-for-testing BATCH=AMB-546`
  - Passed: `.codex/xcode-summaries/AMB-546/20260607T030348Z-validate-70683-10946/validate-summary.json`
  - Build-for-testing summary: `.codex/xcode-summaries/AMB-546/20260607T030352Z-bft-70848-5804/build-for-testing-summary.json`

## Proof Boundaries

- This report proves current source routing, current screenshot capture, and deletion-map classification only.
- No Goals UI source was modified.
- No reconstruction, accessibility claim, performance claim, device claim, privacy/legal claim, signed archive claim, TestFlight/App Store claim, release readiness claim, or CI claim is made.

## Next Reconstruction Notes

- Remove or replace the top intro panel as a root-level card in the scoped Goals reconstruction issue.
- Replace `Your Direction` card posture with a single Direction Atlas object.
- Demote chips from primary state to secondary labels.
- Make proof/source/status readable without clipped nested blocks.
- Preserve Goals as direction, ambition paths, proof, simulations, and goal timelines; do not turn it into a score, KPI, dashboard, astrology map, or ranked life-area surface.

## Rollback

Revert the AMB-546 commit to remove the prompt, screenshot, and this report. No app source rollback is required because no app source changed.
