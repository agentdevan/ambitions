import Foundation

enum StageMotionRoute: Equatable, Sendable {
    case none
    case returnToToday(TodayEntryContext)
    case openGoals
    case openTime
    case openTrust
    case presentOverlay(ShellOverlayState)
}

struct StageMotionCoordination: Equatable, Sendable {
    let projection: StageMotionProjection
    let route: StageMotionRoute
    let reductionPolicy: StageMotionReductionPolicy
}

struct StageMotionCoordinator {
    var reduceMotionEnabled: Bool

    init(reduceMotionEnabled: Bool = false) {
        self.reduceMotionEnabled = reduceMotionEnabled
    }

    func coordinate(
        action: MotionCurrentAction,
        source: String = "motion.current"
    ) -> StageMotionCoordination {
        let reductionPolicy = StageMotionReductionPolicy.current(reduceMotionEnabled: reduceMotionEnabled)
        let projection = StageMotionProjection(
            action: action,
            sourceSurface: source,
            reduceMotion: reductionPolicy.reduceMotionEnabled
        )
        return StageMotionCoordination(
            projection: projection,
            route: route(for: action, reductionPolicy: reductionPolicy),
            reductionPolicy: reductionPolicy
        )
    }

    private func route(
        for action: MotionCurrentAction,
        reductionPolicy: StageMotionReductionPolicy
    ) -> StageMotionRoute {
        switch action {
        case .reviewHistory:
            return memoryLensRoute(label: "review", action: action, reductionPolicy: reductionPolicy)
        case .openHistory:
            return memoryLensRoute(label: "history", action: action, reductionPolicy: reductionPolicy)
        case .returnToThread:
            return memoryLensRoute(label: "thread", action: action, reductionPolicy: reductionPolicy)
        case .openToday:
            return .returnToToday(.standard)
        case .openGoals:
            return .openGoals
        case .openTime:
            return .openTime
        case .openTrust:
            return .openTrust
        }
    }

    private func memoryLensRoute(
        label: String,
        action: MotionCurrentAction,
        reductionPolicy: StageMotionReductionPolicy
    ) -> StageMotionRoute {
        .presentOverlay(.memoryLens(
            intent: .memoryLens,
            entrySource: .shellUtility,
            presentationContext: .recall,
            query: reductionPolicy.motionQuery(label: label, action: action)
        ))
    }
}
