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

enum TodayRouteTarget: String, Hashable, Identifiable, Sendable {
    case capturesInbox

    var id: String { rawValue }
}

enum PlanRouteTarget: String, Hashable, Identifiable, Sendable {
    case habits

    var id: String { rawValue }
}

@MainActor
@Observable
final class AppNavigationModel {
    var selectedTab: AppTab
    var todayPath: [TodayRouteTarget]
    var goalsPath: [GoalRouteTarget]
    var planPath: [PlanRouteTarget]
    var lastExternalRoute: AppExternalRoute?
    var lastExternalRouteSource: AppExternalRouteSource?

    init(selectedTab: AppTab) {
        self.selectedTab = selectedTab.canonicalTopLevelTab
        todayPath = selectedTab == .captures ? [.capturesInbox] : []
        goalsPath = []
        planPath = selectedTab == .habits ? [.habits] : []
        lastExternalRoute = nil
        lastExternalRouteSource = nil
    }

    func selectTab(_ tab: AppTab) {
        selectedTab = tab.canonicalTopLevelTab
        if tab == .captures {
            openCapturesInbox()
        } else if tab == .habits {
            openHabits()
        }
    }

    func openGoalDetail(_ target: GoalRouteTarget) {
        guard target.hasAddressableContent else { return }
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

    func openCapturesInbox() {
        selectedTab = .today
        todayPath = [.capturesInbox]
    }

    func openHabits() {
        selectedTab = .plan
        planPath = [.habits]
    }
}
