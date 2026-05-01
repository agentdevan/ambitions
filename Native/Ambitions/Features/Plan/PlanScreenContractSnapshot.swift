import Foundation

extension PlanDashboard {
    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .plan,
            firstScreenContent: [
                "Day Shape",
                "Week fit",
                "Week Shape",
                "Life Shape",
                "Weekly Plan Strip",
                "Rich Timeline Widget",
                "Rituals",
                "Scheduling",
                "Open windows"
            ],
            panels: [.heroDecision, .schedule, .timeline, .weeklyPlanStrip, .recovery, .trust],
            actions: [.makeCalendarAware, .findWindows, .move, .protect, .saveTheWeek],
            drillDowns: ["Calendar mode", "Rituals", "Review archive", "Receipts"],
            copySamples: [
                hero.title,
                hero.subtitle,
                lifeSuite.title,
                lifeSuite.subtitle,
                lifeSuite.trustLabel,
                treaty.title,
                capacityEnvelope.title,
                timelineStrip.title,
                calendarAwareness.sourceLabel,
                calendarBoundary.writeBoundary,
                recoveryEntry.title,
                reflowDecision.title,
                reflowDecision.sourceLabel,
                reflowDecision.trustLabel,
                saveTheDay.title,
                recoveryMaturity.title,
                recoveryMaturity.confirmationBoundary
            ] + timelineStrip.items.map(\.sourceLabel),
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}
