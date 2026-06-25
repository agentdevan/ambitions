import Foundation

extension Capture {
    var searchFreshness: YouMemoryFreshness {
        switch status {
        case .archived:
            return .basedOnOlderContext
        case .needsTriage, .seed:
            return .mayNeedReview
        case .actionable, .goalBound, .scheduled, .delegated, .waiting, .optionalSomeday:
            return .current
        }
    }

    var searchObjectTypeLabel: String {
        kind.title
    }

    var searchSourceLabel: String {
        sourceType?.title ?? "Typed in Capture"
    }

    var searchPrimaryActionTitles: [String] {
        switch status {
        case .archived:
            return ["Open capture", "Open history"]
        case .needsTriage, .actionable, .seed:
            return ["Open capture", "Change placement", "Attach to goal"]
        case .goalBound:
            return ["Open capture", "Open goal", "Review history"]
        case .scheduled:
            return ["Open capture", "Move to Time", "Open history"]
        case .delegated:
            return ["Open capture", "Review delegation", "Open history"]
        case .waiting:
            return ["Open capture", "Mark waiting", "Open history"]
        case .optionalSomeday:
            return ["Open capture", "Review later", "Open history"]
        }
    }
}
