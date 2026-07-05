import Foundation

enum CaptureMaturityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case raw
    case clarified
    case attached
    case scheduled
    case parked
}

extension Capture {
    var maturityState: CaptureMaturityState {
        if route == .timeSeed || status == .scheduled {
            return .scheduled
        }

        if linkedGoalID != nil ||
            goalRelationship?.goalID != nil ||
            route == .goalAttachment ||
            route == .proofItem {
            return .attached
        }

        if route == .waiting ||
            route == .optionalSomeday ||
            route == .archive ||
            status == .waiting ||
            status == .optionalSomeday ||
            status == .archived {
            return .parked
        }

        if route != .captureInbox ||
            kind != .raw ||
            triageStatus == .assumedRoute ||
            triageStatus == .userCorrected ||
            triageStatus == .routed {
            return .clarified
        }

        return .raw
    }
}
