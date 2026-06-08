# AMB-566 No-Card Audit

## Verdict

Yellow.

The required read-only scans completed and raw outputs are recorded as audit artifacts. Active Card/Tile/Dashboard and broader container/geometry hit families exist across current source, shared primitives, previews, tests, and feature surfaces. They are classified below, and AMB-607 owns the follow-up review/replacement pass.

This is not Red because the active generic-structure risk has an owner-filed issue:

- AMB-607 - classify and replace active card/container structures.

## Exact Scan Commands And Output Artifacts

### Card / Tile / Dashboard Names

Command:

```bash
rg -n "Card|HeroCard|SurfaceCard|ModuleCard|Tile|Dashboard" Native Sources --glob "*.swift" > artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-card-tile-dashboard.txt || true
```

Output:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-card-tile-dashboard.txt`
- Output lines: `980`
- Pattern counts: `HeroCard 34`, `SurfaceCard 0`, `ModuleCard 0`, `Dashboard 349`, `Tile 28`, `Card 710`

### Panel / Chip / Banner / Container / Box / Section / Pill Names

Command:

```bash
rg -n "Panel|Chip|Banner|Container|Box|Section|Pill" Native Sources --glob "*.swift" > artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-panel-chip-container.txt || true
```

Output:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-panel-chip-container.txt`
- Output lines: `2032`
- Pattern counts: `Panel 856`, `Chip 160`, `Banner 4`, `Container 284`, `Box 0`, `Section 852`, `Pill 388`

### RoundedRectangle / Background / Corner Radius Geometry

Command:

```bash
rg -n "RoundedRectangle|\\.background\\(|\\.cornerRadius\\(" Native Sources --glob "*.swift" > artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-rounded-background-corner.txt || true
```

Output:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-rounded-background-corner.txt`
- Output lines: `727`
- Pattern counts: `RoundedRectangle 454`, `.background( 348`, `.cornerRadius( 8`

### Shadow On Information Blocks

Command:

```bash
rg -n "\\.shadow\\(" Native Sources --glob "*.swift" > artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-shadow.txt || true
```

Output:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-shadow.txt`
- Output lines: `33`
- Pattern count: `.shadow( 33`

### Root ScrollView / LazyVStack / VStack Module Stacks

Command:

```bash
rg -n "ScrollView|LazyVStack|VStack\\(" Native/Ambitions/App Native/Ambitions/Features Sources --glob "*.swift" > artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-root-scroll-stack.txt || true
```

Output:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-root-scroll-stack.txt`
- Output lines: `988`
- Pattern counts: `ScrollView 73`, `LazyVStack 10`, `VStack( 915`

### Generic Material Containers

Command:

```bash
rg -n "Material|\\.thinMaterial|\\.ultraThinMaterial|regularMaterial|background\\(.*Material|AppCard|HeroCard|StateDrivenMaterialPanel|AmbitionRichPanel|QuietGlass|ContainerRelativeShape" Native Sources --glob "*.swift" > artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-material-containers.txt || true
```

Output:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-material-containers.txt`
- Output lines: `302`
- Pattern counts: `Material 92`, `.thinMaterial 2`, `.ultraThinMaterial 2`, `regularMaterial 0`, `AppCard 116`, `HeroCard 34`, `StateDrivenMaterialPanel 20`, `AmbitionRichPanel 50`, `QuietGlass 12`, `ContainerRelativeShape 0`

## Classification Of Active Hit Families

| Hit family | Active classification | Owner |
|---|---|---|
| Card / HeroCard / Tile / Dashboard names | Mixed. Shared primitive definitions and previews are supporting/canonical or preview-only. Active feature and service/model hits remain review-required, especially You, Goals, Time, Insights, Habits, Capture, LaunchGate, and dashboard-named models/services. | AMB-607 |
| Panel / Chip / Banner / Container / Section / Pill names | Mixed. Some names are canonical primitive vocabulary or native SwiftUI structure. Active feature-level repeated containers and root-section composition remain review-required. | AMB-607 |
| RoundedRectangle / background / cornerRadius geometry | Mixed. Some use is low-level primitive implementation. Repeated local shape/background/corner construction in active feature files is review-required for replacement or acceptance under existing primitives. | AMB-607 |
| Shadow use | Mixed. Most hits are visual depth primitives or restrained shell/object depth. Active information-block shadows in feature source remain review-required where they create panel-pile feel. | AMB-607 |
| ScrollView / LazyVStack / VStack root stacks | Mixed. Native layout structure is not automatically a violation, but high active counts in You, Goals, Time, Today, Capture, and Motion require owner review for root module-pile behavior. | AMB-607 |
| Material containers | Mixed. Shared primitive definitions are expected. Active AppCard/HeroCard/material-container use in feature files remains review-required for no-card replacement or explicit acceptance. | AMB-607 |

## Highest-Count Active Files

### Card / Tile / Dashboard

- `Native/Ambitions/Features/You/YouScreen.swift` - 109
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift` - 70
- `Native/Ambitions/Features/Time/TimeScreen.swift` - 67
- `Native/Ambitions/Features/Goals/GoalComponents.swift` - 54
- `Native/Ambitions/Features/Goals/GoalsFeatureService.swift` - 41
- `Native/Ambitions/Features/Insights/InsightsScreen.swift` - 37

### Panel / Chip / Container

- `Native/Ambitions/Features/You/YouScreen.swift` - 194
- `Native/Ambitions/Features/Goals/GoalComponents.swift` - 90
- `Native/Ambitions/Features/Time/TimeScreen.swift` - 81
- `Sources/Components/RichPanelPrimitives.swift` - 70
- `Native/Ambitions/Features/Today/TodayPanels.swift` - 69

### Rounded / Background / Corner Geometry

- `Native/Ambitions/Features/You/YouScreen.swift` - 86
- `Native/Ambitions/Features/Today/TodayPanels.swift` - 63
- `Native/Ambitions/Features/Time/TimeScreen.swift` - 49
- `Native/Ambitions/Features/Goals/GoalComponents.swift` - 49
- `Native/Ambitions/App/AppShellView.swift` - 26

### Root Stack / Scroll Structures

- `Native/Ambitions/Features/You/YouScreen.swift` - 141
- `Native/Ambitions/Features/Goals/GoalComponents.swift` - 98
- `Native/Ambitions/Features/Time/TimeScreen.swift` - 75
- `Native/Ambitions/Features/Goals/GoalDetailScreen.swift` - 71
- `Native/Ambitions/Features/Today/TodayPanels.swift` - 51

## Focused Tests

- `not available` - no matching focused test target exists for this read-only scan/classification audit. The required proof mechanism is the exact `rg` scan output plus classification report.

## Changed Files

Runtime/source changed files:

- none

Audit artifacts added:

- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-no-card-audit.md`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-card-tile-dashboard.txt`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-panel-chip-container.txt`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-rounded-background-corner.txt`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-shadow.txt`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-root-scroll-stack.txt`
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-scan-material-containers.txt`

## Proof Boundaries

This report claims only scan completion and active hit-family classification. It does not claim source remediation, visual approval, accessibility Green, screenshot freshness, device proof, CI proof, privacy/legal approval, TestFlight readiness, App Store readiness, release readiness, or product completion.

## Required Completion Footer

Verdict: Yellow
Artifact paths:
- `artifacts/ambitions-ui-reconstruction/primitive-audit/AMB-566-no-card-audit.md`
Focused tests:
- `not available` - no matching focused test target exists for this read-only scan/classification audit. The required proof mechanism is the exact `rg` scan output plus classification report.
Changed files:
- none
Remaining Yellow debt:
- AMB-607
