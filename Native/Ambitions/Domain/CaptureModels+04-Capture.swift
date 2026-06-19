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
            return ["Open capture", "Inspect receipt"]
        case .needsTriage, .actionable, .seed:
            return ["Open capture", "Change route", "Attach to goal"]
        case .goalBound:
            return ["Open capture", "Open goal", "Inspect proof"]
        case .scheduled:
            return ["Open capture", "Move to Time", "Inspect receipt"]
        case .delegated:
            return ["Open capture", "Review delegation", "Inspect receipt"]
        case .waiting:
            return ["Open capture", "Mark waiting", "Inspect receipt"]
        case .optionalSomeday:
            return ["Open capture", "Review later", "Inspect receipt"]
        }
    }
}
