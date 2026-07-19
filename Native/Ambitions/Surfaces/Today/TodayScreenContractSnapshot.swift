import AmbitionsDesignSystem
import Foundation

extension TodayExecutionViewState {
    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .today,
            firstScreenContent: [
                "Reality Meridian",
                "Start here",
                "Now / Next / Later",
                "Reality Meridian",
                "Now Layer",
                "Today Shape Layer",
                "Compact timeline",
                "Relevant One-Step Goals",
                "Open-window awareness",
                "Recovery"
            ],
            panels: [.heroDecision, .nowLayer, .todayPlan, .compactTimeline, .oneStepGoals, .schedule, .recovery],
            actions: [.start, .move, .parkNotToday, .markDone, .saveTheDay],
            drillDowns: ["Goal Detail", "Goal Path", "Receipt", "Review"],
            copySamples: [
                hero.title,
                hero.subtitle,
                dayRail.dateTitle,
                dayRail.heroStep?.primaryAction.title ?? "Start now",
                dayRail.contextSummary,
                todayTimeLayer.title,
                todayTimeLayer.subtitle,
                todayTimeLayer.calendarSourceLabel,
                todayTimeLayer.openWindowLabel,
                oneStepGoalsPanel.title,
                oneStepGoalsPanel.subtitle,
                oneStepGoalsPanel.emptyMessage,
                saveTheDayAction?.title ?? "Save the day"
            ],
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}
