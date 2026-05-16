# UI Decision Proof Contract

Decision ID: `UID-2026-05-15-bottom-ia-five-tabs`

## Source Installation Status

Source-installed:

- `Sources/Components/NavigationPrimitives.swift`
- `Sources/Previews/RootDestinationIdentityPreviews.swift`
- `Native/AmbitionsTests/App/AppShellChromeTests.swift`

## Proof Added

- `AppShellChromeTests.testAppTabSequenceMatchesBottomNavigationContract()` binds `AppTab.allCases.map(\.title)` to `BottomNavigationContract.requiredTitles`.
- The same test asserts `BottomNavigationContract.requiredTitleSequence` remains `Today / Goals / Capture / Time / You`.

## Required Remaining Evidence

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- local unit-test execution proof for `AppShellChromeTests`

## Boundary

This proof contract confirms source files and a test assertion were installed in the repo. It does not claim release readiness or App Store readiness.
