import Foundation

extension CaptureRuntimeReceiptKind {
    var recognitionOrder: Int {
        switch self {
        case .captureExtracted:
            return 0
        case .captureNeedsClarification:
            return 1
        case .captureMatchedGoal:
            return 2
        case .captureWeakMatchRejected:
            return 3
        case .captureSavedAsFutureContext:
            return 4
        case .captureProposedForTime:
            return 5
        case .captureAddedToTime:
            return 6
        case .captureAttachedToGoal:
            return 7
        case .captureSavedAsProof:
            return 8
        case .captureRuntimeUsePaused:
            return 9
        case .captureCorrectionApplied:
            return 10
        case .captureReplayGenerated:
            return 11
        }
    }
}

extension CaptureRuntimeCorrectionKind {
    var userFacingSummary: String {
        switch self {
        case .wrongActivity:
            return "Wrong activity"
        case .wrongTime:
            return "Wrong time"
        case .wrongGoal:
            return "Wrong goal"
        case .doNotUseForPlanning:
            return "Do not use for planning"
        case .saveOnlyAsNote:
            return "Save only as note"
        case .attachToDifferentGoal:
            return "Attach to different goal"
        case .deleteContext:
            return "Delete context"
        }
    }
}
