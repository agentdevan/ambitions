import Foundation

enum TimeInteractionIntent: String, Sendable {
    case chooseDay
    case chooseWeek
    case chooseMonth
    case chooseYear
    case reviewPressure
    case protectWindow
    case openGlobalCapture

    var accessibilityAnnouncement: String {
        switch self {
        case .chooseDay:
            "Time changed to day horizon."
        case .chooseWeek:
            "Time changed to week horizon."
        case .chooseMonth:
            "Time changed to month horizon."
        case .chooseYear:
            "Time changed to year horizon."
        case .reviewPressure:
            "Pressure review opened."
        case .protectWindow:
            "Protected window review opened."
        case .openGlobalCapture:
            "Capture composer opened from Time."
        }
    }
}
