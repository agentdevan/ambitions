# UI Decision Implementation Receipt

Decision ID: `UID-2026-05-15-today-local-ambitions-lockup`

Status: source-installed, validation still required

## Changed Source Files

- `Sources/Components/ShellChromeTrustPrimitives.swift`
- `Sources/Previews/ShellChromeTrustPreviews.swift`
- `Native/Ambitions/Features/Today/TodayScreen.swift`

## What Changed

- Added `SourceTrustChrome` as a reusable AmbitionsDesignSystem primitive for compact trust/source chrome.
- Added `LocalAmbitionsLockup` as the canonical `Local · Ambitions` lockup.
- Added a design-system preview fixture for the lockup.
- Wired `LocalAmbitionsLockup()` into the Today surface as top-right chrome.

## Proof Collected

- Source files are installed in the repo.
- Decision file and design-system matrix now mark the primitives as existing.
- Gap report and proof contract were updated to reflect source installation.

## Proof Still Required

- local Swift/Xcode compile proof
- rendered preview or simulator screenshot proof
- accessibility review for VoiceOver order, contrast, and Dynamic Type behavior

## Boundary

This receipt does not claim release readiness, device proof, hosted CI proof, or App Store readiness.
