import Foundation

extension PlanDashboard {
    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .plan,
            firstScreenContent: [
                "Shape Time",
                "LifeShape Field",
                "Open time",
                "Goal time",
                "Protected time",
                "Pressure",
                "Shape week",
                "Review pressure",
                "Manual mode"
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
                pressureRecoveryReview.title,
                pressureRecoveryReview.capacityReviewLabel,
                timelineStrip.title,
                calendarAwareness.sourceLabel,
                calendarBoundary.writeBoundary,
                recoveryEntry.title,
                reflowDecision.title,
                reflowDecision.sourceLabel,
                reflowDecision.trustLabel,
                lifeSuite.shapes.map(\.sourceLabel).joined(separator: " "),
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
