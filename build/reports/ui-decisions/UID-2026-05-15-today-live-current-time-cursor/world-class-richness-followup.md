# World-Class Richness Follow-Up

Decision ID: `UID-2026-05-15-today-live-current-time-cursor`

Status: source primitive installed; active wiring follow-up required

## Installed

- `Sources/Components/RealityMeridianTimeBand.swift`
- `Native/Ambitions/Features/Today/TodayMasthead.swift`

## Intended active wiring

Use the already-active `DayTimelineRail(...).fusedCurrentTimeCursor()` seam.

In `Native/Ambitions/Features/Today/TodayDayRailCurrentTimeFusion.swift`, change the modifier body from a pure overlay to a stacked composition:

```swift
func body(content: Content) -> some View {
    VStack(alignment: .leading, spacing: theme.spacing.lg) {
        RealityMeridianTimeBand()
            .accessibilityIdentifier("TodayRealityMeridianTimeBand")

        content
            .overlay(alignment: .topLeading) {
                RealityMeridianCurrentTimeCursor(presentation: .railOverlay)
                    .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.lg)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("TodayRealityMeridianCurrentTimeCursor")
            }
    }
    .accessibilityElement(children: .contain)
}
```

## Optional masthead wiring

In `TodayScreen`, add `TodayMasthead(contextSummary: mastheadContextSummary)` above the loaded-state content and remove the free-floating `LocalAmbitionsLockup()` overlay to avoid duplicate trust chrome.

Add:

```swift
private var mastheadContextSummary: String? {
    guard case let .loaded(experience) = viewModel.state else { return nil }
    return experience.execution.dayRail.contextSummary
}
```

## Guardrails

- Do not add score-based UI.
- Do not change bottom IA.
- Do not add Timeline / Projects / More tabs.
- Do not claim release readiness.
- Keep Today / Goals / Capture / Time / You.

## Required validation

- `make ui-decision-all`
- `git diff --check`
- Swift/Xcode compile
- Today preview screenshot
- Dynamic Type check
- VoiceOver check
