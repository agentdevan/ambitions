#if canImport(SwiftUI)
import SwiftUI

enum ComponentPreviewFilter: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
}

enum ComponentPreviewRootSurface: String, CaseIterable {
    case today = "Today"
    case goals = "Goals"
    case time = "Time"
    case you = "You"

    var iconName: String {
        switch self {
        case .today: "sun.max.fill"
        case .goals: "target"
        case .time: "clock"
        case .you: "person.crop.circle"
        }
    }
}

extension AmbitionPanelVisibility {
    var previewTitle: String {
        switch self {
        case .full: "Full"
        case .summarized: "Summary"
        case .collapsedSignal: "Signal"
        case .hidden: "Hidden"
        }
    }

    var previewAccessibilityText: String {
        switch self {
        case .full: "Extra detail is shown."
        case .summarized: "Extra detail is summarized."
        case .collapsedSignal: "Extra detail uses a signal."
        case .hidden: "Extra detail is hidden."
        }
    }
}
#endif
