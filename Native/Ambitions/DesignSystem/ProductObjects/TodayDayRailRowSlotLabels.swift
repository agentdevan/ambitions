import AmbitionsDesignSystem
import SwiftUI

extension DayRailRowSlot {
    var mvpSymbol: String {
        switch self {
        case .now:
            return "target"
        case .next:
            return "person.2.fill"
        case .later:
            return "doc.text.fill"
        }
    }

    var mvpTimeLabel: String {
        switch self {
        case .now:
            return "Now"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }

    func mvpTimeLabel(for index: Int) -> String {
        switch self {
        case .now:
            return index == 0 ? "Now" : "Current"
        case .next:
            return "Next"
        case .later:
            return "Later"
        }
    }
}
