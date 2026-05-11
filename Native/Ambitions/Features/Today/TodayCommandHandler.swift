import Foundation

struct TodayCommandHandler {
    typealias FeedbackActionHandler = (TodayInlineAction, Date) async throws -> TodayActionResponse

    private let feedbackActionHandler: FeedbackActionHandler

    init(feedbackActionHandler: @escaping FeedbackActionHandler) {
        self.feedbackActionHandler = feedbackActionHandler
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        switch action.kind {
        case .startStepSession, .pauseStepSession, .stopStepSession:
            return TodayActionResponse(message: nil)
        case .openDetail:
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Opening plan context",
                    body: "Today is handing off to the same goal context used for replanning, evidence, and support decisions.",
                    state: .selected
                )
            )
        case .openPlan, .protectLater:
            return TodayActionResponse(message: nil)
        case .askForHelp:
            if action.target.goalID != nil, action.target.stepID != nil {
                return try await feedbackActionHandler(action, now)
            }
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Support context captured",
                    body: "Ambitions will keep the blocked or heavy step visible so the next pass can shrink it, explain it, or route you into the fuller goal context.",
                    state: .warning
                )
            )
        case .dismissCelebration:
            return TodayActionResponse(message: nil)
        default:
            return try await feedbackActionHandler(action, now)
        }
    }
}
