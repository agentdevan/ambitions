# Ambitions 3.0 SwiftUI State Contract Architecture Standard

Path: docs/canon/Ambitions_3_0_SwiftUI_State_Contract_Architecture_Standard.md
Status: Active architecture canon


## Standard
Ambitions SwiftUI features use value-state-first architecture. Domain objects stay in Domain/Services/Persistence. Feature view state is typed, small, deterministic, privacy-aware, and preview-safe. Projectors convert domain/service facts into renderable contracts. Views render state and send typed actions.

## Required Properties
- feature-owned view states with small structs/enums
- deterministic projectors with testable inputs and outputs
- privacy projection types for compact, redacted, external, and full-detail contexts
- accessibility labels, values, hints, and identifiers where state meaning is not obvious
- preview-safe fixtures that do not imply shipped backend/sync/AI behavior
- typed route/action state when available instead of stringly routing

## Prohibited Patterns
No giant feature brain files; no view files containing domain projection logic; no projection files containing large SwiftUI rendering; no compatibility code without migration owner; no user-facing copy scattered without pattern ownership; no raw AI/personalization claims in UI state; no global state leaks between features; no hidden behavior inside compatibility helpers.

## Thresholds
400 lines triggers responsibility review. 700 lines recommends extraction. 1000 lines requires extraction before adding more behavior unless a written exception exists. Five or more top-level state model families in one file recommends extraction. Projection plus rendering plus compatibility plus tests-inferred copy in one file requires extraction.

## Recommended Families
Today: `TodayExecutionViewState.swift`, `DayRailViewState.swift`, `DayRailProjection.swift`, `DayRailStepDetailState.swift`, `TodayStepDetailPanel.swift`, `TodayExecutionProjector.swift`, `TodayExecutionCompatibility.swift`, `TodayScreenContractSnapshot.swift`.

Every feature: `FeatureViewState.swift`, `FeatureProjector.swift`, `FeatureScreen.swift`, `FeaturePanels.swift`, `FeatureActions.swift`, `FeaturePreviewScenarios.swift`, `FeatureTests.swift`.
