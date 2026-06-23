import Foundation

enum TodayInteractionIntent: Sendable, Equatable {
    case startStep
    case pauseStep
    case stopStep
    case closeStep
    case openDetail
    case openCapture
    case shapeTime
    case protectWindow
    case runtimeMutation
}

enum TodayInteractions {
    static func intent(for action: TodayInlineAction) -> TodayInteractionIntent {
        switch action.kind {
        case .startStepSession:
            .startStep
        case .pauseStepSession:
            .pauseStep
        case .stopStepSession:
            .stopStep
        case .closeActionClosure:
            .closeStep
        case .openDetail, .askForHelp:
            .openDetail
        case .quickLog:
            .openCapture
        case .openTime:
            .shapeTime
        case .protectLater:
            .protectWindow
        default:
            .runtimeMutation
        }
    }

    static func accessibilityAnnouncement(for intent: TodayInteractionIntent) -> String {
        switch intent {
        case .startStep:
            "Step session started."
        case .pauseStep:
            "Step session paused."
        case .stopStep:
            "Returned to Today."
        case .closeStep:
            "Closure review opened."
        case .openDetail:
            "Step detail opened."
        case .openCapture:
            "Capture composer opened."
        case .shapeTime:
            "Time shaping review opened."
        case .protectWindow:
            "Window protection review opened."
        case .runtimeMutation:
            "Today updated."
        }
    }
}
