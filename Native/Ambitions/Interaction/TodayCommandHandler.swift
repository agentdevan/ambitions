import Foundation

struct TodayCommandHandler {
    typealias FeedbackActionHandler = (TodayInlineAction, Date) async throws -> TodayActionResponse
    typealias CommandActionHandler = (TodayInlineAction, AmbitionsCommand, Date) async throws -> TodayActionResponse

    private let feedbackActionHandler: FeedbackActionHandler
    private let commandActionHandler: CommandActionHandler

    init(feedbackActionHandler: @escaping FeedbackActionHandler) {
        self.feedbackActionHandler = feedbackActionHandler
        self.commandActionHandler = { action, _, now in
            try await feedbackActionHandler(action, now)
        }
    }

    init(
        feedbackActionHandler: @escaping FeedbackActionHandler,
        commandActionHandler: @escaping CommandActionHandler
    ) {
        self.feedbackActionHandler = feedbackActionHandler
        self.commandActionHandler = commandActionHandler
    }

    private static let commandCapableKinds = SurfaceGestureMap.todayCommandCapableKinds

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        switch action.kind {
        case .startStepSession, .pauseStepSession, .stopStepSession, .openTime, .protectLater, .dismissCelebration:
            return TodayActionResponse(message: nil)
        case .askForHelp:
            if action.target.goalID == nil || action.target.stepID == nil {
                return TodayActionResponse(
                    message: TodayInlineMessage(
                        title: "Support context captured",
                        body: "Ambitions will keep the blocked or heavy step visible so the next pass can shrink it, explain it, or route you into the fuller goal context.",
                        state: .warning
                    )
                )
            }
            return try await commandActionHandler(action, command(for: action, now: now), now)
        case .openDetail:
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Opening Goal context",
                    body: "Today is handing off to the same goal context used for replanning, evidence, and support decisions.",
                    state: .selected
                )
            )
        default:
            if Self.commandCapableKinds.contains(action.kind) {
                return try await commandActionHandler(action, command(for: action, now: now), now)
            }
            return try await feedbackActionHandler(action, now)
        }
    }

    private func command(for action: TodayInlineAction, now: Date) -> AmbitionsCommand {
        let createdAt = DomainTimestamp.string(from: Date(timeIntervalSince1970: 0))
        if action.kind == .quickLog {
            let target = AmbitionsCommandTarget(goalID: action.target.goalID, stepID: action.target.stepID)
            let content = AmbitionsCommandPayload(title: action.title)
            return AmbitionsCommand(
                id: "command.today2.\(action.id).\(AmbitionsCommandKind.quickCapture.rawValue)",
                source: .today,
                typedPayload: .capture(CaptureCommand(
                    action: .quickCapture(externalCreation: nil),
                    target: target,
                    content: RuntimeCommandContent(content)
                )),
                createdAt: createdAt,
                sourceSurface: "today"
            )
        }
        return TodayExecutionViewState.command(
            for: action,
            explanations: [],
            recoveryOptionID: nil
        ) ?? AmbitionsCommand(
            id: "command.today2.\(action.id).unsupported",
            source: .today,
            typedPayload: .history(HistoryCommand(
                action: .openDestination,
                target: AmbitionsCommandTarget(goalID: action.target.goalID, stepID: action.target.stepID, destination: nil),
                content: RuntimeCommandContent()
            )),
            createdAt: DomainTimestamp.string(from: now)
        )
    }
}
