import Foundation

enum StageMotionRoute: Equatable, Sendable {
    case none
    case returnToToday(TodayEntryContext)
    case openGoals
    case openTime
    case openTrust
    case presentOverlay(ShellOverlayState)
}

@MainActor
@Observable
final class StageOwner {
    private(set) var lastMotionProjection: StageMotionProjection?

    var reduceMotionEnabled: Bool

    init(reduceMotionEnabled: Bool = false) {
        self.reduceMotionEnabled = reduceMotionEnabled
    }

    func setReduceMotionEnabled(_ isEnabled: Bool) {
        reduceMotionEnabled = isEnabled
    }

    func route(for action: MotionCurrentAction, source: String = "motion.current") -> StageMotionRoute {
        lastMotionProjection = StageMotionProjection(
            action: action,
            sourceSurface: source,
            reduceMotion: reduceMotionEnabled
        )

        switch action {
        case .inspectProof:
            return .presentOverlay(.memoryLens(
                intent: .memoryLens,
                entrySource: .shellUtility,
                presentationContext: .recall,
                query: motionQuery(label: "proof", action: action)
            ))
        case .openReceipt:
            return .presentOverlay(.memoryLens(
                intent: .memoryLens,
                entrySource: .shellUtility,
                presentationContext: .recall,
                query: motionQuery(label: "receipt", action: action)
            ))
        case .openThread:
            return .presentOverlay(.memoryLens(
                intent: .memoryLens,
                entrySource: .shellUtility,
                presentationContext: .recall,
                query: motionQuery(label: "thread", action: action)
            ))
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

    private func motionQuery(label: String, action: MotionCurrentAction) -> String {
        guard let id = action.identifier else {
            return reduceMotionEnabled ? label : "\(label) continuity"
        }
        return "\(label):\(id)"
    }
}
