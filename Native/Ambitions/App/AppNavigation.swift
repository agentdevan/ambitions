import Foundation
import Observation

enum GoalDetailLaunchContext: String, Hashable, Sendable {
    case standard
    case help
}

struct GoalRouteTarget: Hashable, Identifiable, Sendable {
    let goalID: String?
    let draftID: String?
    let launchContext: GoalDetailLaunchContext

    init(goalID: String? = nil, draftID: String? = nil, launchContext: GoalDetailLaunchContext = .standard) {
        self.goalID = goalID
        self.draftID = draftID
        self.launchContext = launchContext
    }

    var id: String {
        "\(goalID ?? "goal:none")|\(draftID ?? "draft:none")|\(launchContext.rawValue)"
    }

    var canonicalGoalID: String? { goalID }

    var hasAddressableContent: Bool { goalID != nil || draftID != nil }
}

enum PlanRouteTarget: String, Hashable, Identifiable, Sendable {
    case capturesInbox
    case habits
    case weeklyReview

    var id: String { rawValue }
}

enum InsightsRouteTarget: String, Hashable, Identifiable, Sendable {
    case monthlyReview
    case history

    var id: String { rawValue }
}

@MainActor
@Observable
final class AppNavigationModel {
    var selectedTab: AppTab
    var goalsPath: [GoalRouteTarget]
    var planPath: [PlanRouteTarget]
    var insightsPath: [InsightsRouteTarget]
    var activeOverlay: ShellOverlayState?
    var lastExternalRoute: AppExternalRoute?
    var lastExternalRouteSource: AppExternalRouteSource?

    init(selectedTab: AppTab) {
        self.selectedTab = selectedTab.canonicalTopLevelTab
        goalsPath = []
        planPath = []
        insightsPath = []
        activeOverlay = nil
        lastExternalRoute = nil
        lastExternalRouteSource = nil

        switch selectedTab {
        case .captures:
            planPath = [.capturesInbox]
        case .habits:
            planPath = [.habits]
        case .today, .goals, .plan, .insights, .profile:
            break
        }
    }

    func selectTab(_ tab: AppTab) {
        dismissOverlay()
        selectedTab = tab.canonicalTopLevelTab
        if tab == .captures {
            openCapturesInbox()
        } else if tab == .habits {
            openHabits()
        }
    }

    func openGoalDetail(_ target: GoalRouteTarget) {
        guard target.hasAddressableContent else { return }
        dismissOverlay()
        selectedTab = .goals
        goalsPath = [target]
    }

    func openGoalDetail(
        goalID: String? = nil,
        draftID: String? = nil,
        launchContext: GoalDetailLaunchContext = .standard
    ) {
        openGoalDetail(GoalRouteTarget(goalID: goalID, draftID: draftID, launchContext: launchContext))
    }

    func resetGoalsPath() {
        goalsPath = []
    }

    func openPlanRoute(_ target: PlanRouteTarget) {
        dismissOverlay()
        selectedTab = .plan
        planPath = [target]
    }

    func resetPlanPath() {
        planPath = []
    }

    func openInsightsRoute(_ target: InsightsRouteTarget) {
        dismissOverlay()
        selectedTab = .insights
        insightsPath = [target]
    }

    func resetInsightsPath() {
        insightsPath = []
    }

    func openCapturesInbox() {
        openPlanRoute(.capturesInbox)
    }

    func openHabits() {
        openPlanRoute(.habits)
    }

    func openWeeklyReview() {
        openPlanRoute(.weeklyReview)
    }

    func openMonthlyReview() {
        openInsightsRoute(.monthlyReview)
    }

    func openHistory() {
        openInsightsRoute(.history)
    }

    func presentOverlay(_ route: ShellOverlayState) {
        activeOverlay = route
    }

    func presentCommandSheet(
        intent: ShellCommandIntent? = nil,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral
    ) {
        activeOverlay = .commandSheet(
            intent: intent,
            entrySource: source,
            presentationContext: presentationContext
        )
    }

    func presentMemoryLens(
        intent: ShellCommandIntent? = .memoryLens,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .recall,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) {
        activeOverlay = .memoryLens(
            intent: intent,
            entrySource: source,
            presentationContext: presentationContext,
            query: query,
            goalID: goalID,
            captureID: captureID
        )
    }

    func presentCreateGoal(source: ShellCommandEntrySource) {
        activeOverlay = .createGoal(entrySource: source)
    }

    func dismissOverlay() {
        activeOverlay = nil
    }

    func fallbackExternalLanding() {
        dismissOverlay()
        selectedTab = .today
    }
}
