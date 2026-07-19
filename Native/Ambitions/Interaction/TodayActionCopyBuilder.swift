import Foundation

struct TodayActionCopyBuilder: Sendable {
    static let replayLine = "Already recorded. No duplicate change was made."

    static func blockedActionResponse(for validation: AmbitionsCommandValidationState) -> TodayActionResponse {
        TodayActionResponse(
            message: TodayInlineMessage(
                title: "Action not available",
                body: blockedActionBody(for: validation),
                state: .warning
            )
        )
    }

    static func replayedActionResponse(for action: TodayInlineAction) -> TodayActionResponse {
        let copy = replayedActionCopy(for: action.kind)
        return TodayActionResponse(
            message: TodayInlineMessage(
                title: copy.title,
                body: copy.body,
                state: copy.state
            )
        )
    }

    private static func blockedActionBody(for validation: AmbitionsCommandValidationState) -> String {
        switch validation {
        case .valid:
            return "This action is ready."
        case .invalid:
            return "This action needs a clearer request before Ambitions can change anything."
        case .needsConfirmation:
            return "Review this action before Ambitions changes anything."
        case .needsMissingTarget:
            return "This action needs a real Step or source object before Ambitions can change anything."
        case .unsupportedInThisBuild:
            return "This action is not available in this build."
        case .blockedByMissingFoundation:
            return "This action is waiting on required foundation work before it can run."
        }
    }

    private static func replayedActionCopy(for kind: TodayActionKind) -> TodayInlineMessage {
        switch kind {
        case .complete:
            return TodayInlineMessage(
                title: "Completion recorded",
                body: "Still counts. \(replayLine)",
                state: .success
            )
        case .reschedule:
            return TodayInlineMessage(
                title: "What changed?",
                body: "Move it without blame. \(replayLine)",
                state: .warning
            )
        case .defer:
            return TodayInlineMessage(
                title: "Pressure softened",
                body: "Move it without blame. \(replayLine)",
                state: .selected
            )
        case .split:
            return TodayInlineMessage(
                title: "Smaller step kept",
                body: "A smaller version is kept. \(replayLine)",
                state: .selected
            )
        case .askForHelp:
            return TodayInlineMessage(
                title: "Support context captured",
                body: "Support context is kept. \(replayLine)",
                state: .warning
            )
        case .askWhyThisMatters:
            return TodayInlineMessage(
                title: "Why this matters",
                body: replayLine,
                state: .selected
            )
        case .quickLog:
            return TodayInlineMessage(
                title: "Capture saved",
                body: replayLine,
                state: .success
            )
        default:
            return TodayInlineMessage(
                title: "Action already recorded",
                body: replayLine,
                state: .selected
            )
        }
    }
}
