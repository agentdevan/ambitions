# Design System Gap Report

Decision ID: `UID-2026-05-15-bottom-ia-five-tabs`

## Primitive Status

- `RootDestinationIdentity` in `Sources/Components/NavigationPrimitives.swift` — source-installed
- `BottomNavigationContract` in `Sources/Components/NavigationPrimitives.swift` — source-installed
- `RootDestinationIdentityRail` in `Sources/Components/NavigationPrimitives.swift` — source-installed

## Preview Fixture

- `Sources/Previews/RootDestinationIdentityPreviews.swift`

## App Source Candidates

- `Native/Ambitions/App/AppTab.swift`
- `Native/Ambitions/App/AmbitionsRootView.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- app tab contract test or source assertion comparing active tab titles to `BottomNavigationContract.requiredTitles`

## Boundary

This report records source installation. It does not claim release readiness.
