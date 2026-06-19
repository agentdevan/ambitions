import AmbitionsDesignSystem
import Foundation

enum DegradedStateOrchestrator {
    static func accessibilitySummary(for presentation: DegradedStatePresentation) -> String {
        presentation.accessibilitySummary
    }

    static func todayEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .today)
        return DegradedStatePresentation(
            id: "degraded.today.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .selected,
            icon: rule.icon
        )
    }

    static func goalsEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .goals)
        return DegradedStatePresentation(
            id: "degraded.goals.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .selected,
            icon: rule.icon
        )
    }

    static func timeEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.time.empty",
            kind: .empty,
            title: "The LifeShape Field is open",
            explanation: FlagshipObjectStateOwner.lifeShapeContourMap.emptyExplanation,
            primaryAction: DegradedStateAction(title: "Create a goal", systemImage: AppTab.goals.systemImage, routingHint: .createGoal),
            secondaryAction: DegradedStateAction(title: "Capture", systemImage: AppShellCaptureAccessModel.systemImage, routingHint: .quickCapture),
            tone: .selected,
            icon: FlagshipObjectStateOwner.lifeShapeContourMap.icon
        )
    }

    static func captureComposerEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.capture-composer.empty",
            kind: .empty,
            title: "Capture is ready",
            explanation: "The global composer can hold one real thing locally, then route it to Start here, a goal, Time, closure proof, or inspection when the user chooses.",
            primaryAction: DegradedStateAction(title: "Start here", systemImage: AppTab.today.systemImage, routingHint: .today),
            secondaryAction: DegradedStateAction(title: "Create goal", systemImage: AppTab.goals.systemImage, routingHint: .createGoal),
            tone: .default,
            icon: AppShellCaptureAccessModel.systemImage
        )
    }

    static func youEmpty() -> DegradedStatePresentation {
        let rule = ActivationContract.emptyStateRule(for: .you)
        return DegradedStatePresentation(
            id: "degraded.you.empty",
            kind: .empty,
            title: rule.title,
            explanation: rule.explanation,
            primaryAction: rule.primaryAction,
            secondaryAction: rule.secondaryAction,
            tone: .default,
            icon: rule.icon
        )
    }

    static func habitsEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.habits.empty",
            kind: .empty,
            title: "No routines are shaping the week yet",
            explanation: "Rituals stay quiet until a repeatable loop is useful enough to support the week.",
            primaryAction: DegradedStateAction(title: "Return to Time", systemImage: AppTab.time.systemImage, routingHint: .time),
            tone: .default,
            icon: "repeat"
        )
    }

    static func weeklyReviewEmpty() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.weekly-review.empty",
            kind: .lowHistory,
            title: "The review has little to carry forward",
            explanation: "A few goals, captures, or completed steps will give Weekly Review enough signal to shape the next week.",
            primaryAction: DegradedStateAction(title: "Return to Time", systemImage: AppTab.time.systemImage, routingHint: .time),
            tone: .default,
            icon: "arrow.triangle.branch"
        )
    }

    static func insightsLowHistory() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.insights.low-history",
            kind: .lowHistory,
            title: "Reflection needs a little history",
            explanation: "Ambitions will not pretend there is a pattern yet. A few completions, skips, or smaller versions will make this read useful.",
            primaryAction: DegradedStateAction(title: "Open Today", systemImage: AppTab.today.systemImage, routingHint: .today),
            secondaryAction: DegradedStateAction(title: "Open Time", systemImage: AppTab.time.systemImage, routingHint: .time),
            tone: .default,
            icon: "chart.line.uptrend.xyaxis"
        )
    }

    static func permissionDeniedNotifications() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.permission.notifications.denied",
            kind: .permissionDenied,
            title: "Notifications are off",
            explanation: "Ambitions can still run locally. Time-sensitive reminders will stay inside the app unless you re-enable notifications in Settings.",
            primaryAction: DegradedStateAction(title: "Review Trust Center", systemImage: "checkmark.shield", routingHint: .profileTrust),
            secondaryAction: DegradedStateAction(title: "Open Settings", systemImage: "gearshape", routingHint: .systemSettings),
            tone: .warning,
            icon: "bell.slash"
        )
    }

    static func permissionNeededNotifications() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.permission.notifications.needed",
            kind: .permissionNeeded,
            title: "Notifications are optional",
            explanation: "Turn them on when local reminders would help. The app stays useful without asking for everything up front.",
            primaryAction: DegradedStateAction(title: "Enable notifications", systemImage: "bell.badge", routingHint: .profileTrust),
            secondaryAction: DegradedStateAction(title: "Keep off for now", systemImage: "xmark.circle", routingHint: nil),
            tone: .selected,
            icon: "bell.badge"
        )
    }

    static func unavailable(surface: String, retryHint: DegradedStateRoutingHint? = nil) -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.\(surface.lowercased()).unavailable",
            kind: .unavailable,
            title: "\(surface) is unavailable",
            explanation: "This looks temporary. Retry once, and Ambitions will keep the rest of the system usable.",
            primaryAction: DegradedStateAction(title: "Retry", systemImage: "arrow.clockwise", routingHint: retryHint),
            tone: .warning,
            icon: "exclamationmark.triangle"
        )
    }

    static func loading(surface: String) -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.\(surface.lowercased()).loading",
            kind: .loading,
            title: "\(surface) is getting ready",
            explanation: "Ambitions is assembling the local picture before it decides what deserves attention.",
            primaryAction: DegradedStateAction(title: "Loading", systemImage: "hourglass", routingHint: nil),
            tone: .default,
            icon: "hourglass"
        )
    }

    static func objectLoading(_ owner: FlagshipObjectStateOwner) -> DegradedStatePresentation {
        let entry = FlagshipObjectStateMatrix.entry(for: owner)
        return DegradedStatePresentation(
            id: "degraded.\(owner.rawValue).loading",
            kind: .loading,
            title: "\(owner.title) is getting ready",
            explanation: "\(owner.loadingExplanation) \(entry.boundary)",
            primaryAction: DegradedStateAction(title: entry.loadingState.action.title, systemImage: owner.icon),
            tone: .default,
            icon: owner.icon,
            statusRole: entry.loadingState.statusSymbolRole
        )
    }

    static func objectUnavailable(
        _ owner: FlagshipObjectStateOwner,
        retryHint: DegradedStateRoutingHint? = nil
    ) -> DegradedStatePresentation {
        let entry = FlagshipObjectStateMatrix.entry(for: owner)
        return DegradedStatePresentation(
            id: "degraded.\(owner.rawValue).unavailable",
            kind: .unavailable,
            title: "\(owner.title) needs review",
            explanation: "\(owner.degradedExplanation) \(entry.boundary)",
            primaryAction: DegradedStateAction(title: "Retry", systemImage: "arrow.clockwise", routingHint: retryHint),
            tone: .warning,
            icon: owner.icon,
            statusRole: entry.degradedState.statusSymbolRole
        )
    }

    static func cannotExplainYet() -> DegradedStatePresentation {
        DegradedStatePresentation(
            id: "degraded.explainability.cannot-explain-yet",
            kind: .cannotExplainYet,
            title: "Not enough signal to explain this yet",
            explanation: "Ambitions will wait for clearer local evidence before it gives a confident reason.",
            primaryAction: DegradedStateAction(title: "Keep moving", systemImage: "arrow.right", routingHint: .today),
            tone: .default,
            icon: "questionmark.circle"
        )
    }
}
