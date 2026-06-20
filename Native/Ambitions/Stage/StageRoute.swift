import Foundation

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

enum TimeRouteTarget: String, Hashable, Identifiable, Sendable {
    case rituals
    case weeklyReview

    var id: String { rawValue }
}

enum YouRouteTarget: String, Hashable, Identifiable, Sendable {
    case monthlyReview
    case history

    var id: String { rawValue }
}

enum StageSurfaceReselectionAction: Equatable, Sendable {
    case scrollToTop
    case returnToRoot
}
