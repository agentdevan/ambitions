# Design System Gap Report

Decision ID: `UID-2026-05-15-today-local-ambitions-lockup`

## Primitive Status

- `LocalAmbitionsLockup` in `Sources/Components/ShellChromeTrustPrimitives.swift` — source-installed
- `SourceTrustChrome` in `Sources/Components/ShellChromeTrustPrimitives.swift` — source-installed

## App Usage

- `Native/Ambitions/Features/Today/TodayScreen.swift` now uses `LocalAmbitionsLockup()` as top-right Today chrome.

## Preview Fixture

- `Sources/Previews/ShellChromeTrustPreviews.swift`

## Remaining Proof Needed

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for the new lockup placement

## Boundary

This report records source installation. It does not claim release readiness.
