import AmbitionsDesignSystem
import Foundation

extension TodayExecutionViewState {
    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .today,
            firstScreenContent: [
                "Reality Rail",
                "Start here",
                "Now / Next / Later",
                "Hero Decision Panel",
                "Now Layer",
                "Today Plan Layer",
                "Compact timeline",
                "Relevant One-Step Goals",
                "Open-window awareness",
                "Recovery"
            ],
            panels: [.heroDecision, .nowLayer, .todayPlan, .compactTimeline, .oneStepGoals, .schedule, .recovery],
            actions: [.start, .move, .parkNotToday, .markDone, .saveTheDay],
            drillDowns: ["Goal Detail", "Plan", "Receipt", "Review"],
            copySamples: [
                hero.title,
                hero.subtitle,
                dayRail.dateTitle,
                dayRail.heroStep?.primaryAction.title ?? "Start now",
                dayRail.contextSummary,
                todayPlanLayer.title,
                todayPlanLayer.subtitle,
                todayPlanLayer.calendarSourceLabel,
                todayPlanLayer.openWindowLabel,
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
