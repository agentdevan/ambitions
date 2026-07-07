import Foundation

extension ActionReceiptSourceDomain {
    init(commandSource: AmbitionsCommandSource) {
        switch commandSource {
        case .today:
            self = .today
        case .goals:
            self = .goals
        case .capture:
            self = .capture
        case .time:
            self = .time
        case .you:
            self = .you
        case .reviews:
            self = .reviews
        case .goalDetail:
            self = .goalDetail
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            self = .externalSurface
        case .system:
            self = .system
        }
    }
}

extension AmbitionsCommandSource {
    var allowsSilentLocalPolicyConsideration: Bool {
        switch self {
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            return false
        case .today, .goals, .capture, .time, .you, .reviews, .goalDetail, .system:
            return true
        }
    }
}

extension LifeGraphObjectReference {
    static func commandTargets(_ command: AmbitionsCommand) -> [LifeGraphObjectReference] {
        var targets: [LifeGraphObjectReference] = []
        if let goalID = command.target.goalID {
            targets.append(LifeGraphObjectReference(kind: .goal, id: goalID, sourceDomain: .goals))
        }
        if let captureID = command.target.captureID {
            targets.append(LifeGraphObjectReference(kind: .capture, id: captureID, sourceDomain: .capture))
        }
        if let timeID = command.target.timeID {
            targets.append(LifeGraphObjectReference(kind: .action, id: timeID, sourceDomain: .time))
        }
        if let stepID = command.target.stepID {
            targets.append(LifeGraphObjectReference(kind: .step, id: stepID, parentContextID: command.target.goalID, sourceDomain: .goalEngine))
        }
        if let reviewID = command.target.reviewID {
            targets.append(LifeGraphObjectReference(kind: .decision, id: reviewID, sourceDomain: .you))
        }
        if let recommendationID = command.target.recommendationID {
            targets.append(LifeGraphObjectReference(kind: .correction, id: recommendationID, sourceDomain: .system))
        }
        if let explanationID = command.target.explanationID {
            targets.append(LifeGraphObjectReference(kind: .decision, id: explanationID, sourceDomain: .system))
        }
        return targets
    }
}
