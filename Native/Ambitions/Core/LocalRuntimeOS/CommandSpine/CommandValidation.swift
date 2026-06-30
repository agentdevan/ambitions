import Foundation

enum AmbitionsCommandValidationState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case valid
    case invalid
    case needsConfirmation = "needs_confirmation"
    case needsMissingTarget = "needs_missing_target"
    case unsupportedInThisBuild = "unsupported_in_this_build"
    case blockedByMissingFoundation = "blocked_by_missing_foundation"
}

struct AmbitionsCommandValidator: Sendable {
    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        switch command.kind {
        case .quickCapture:
            return command.payload.primaryText == nil ? .invalid : .valid
        case .openDestination:
            return command.target.destination == nil ? .needsMissingTarget : .valid
        case .createGoal:
            return command.payload.primaryText == nil ? .needsConfirmation : .valid
        case .updateGoal:
            return command.target.goalID == nil ? .needsMissingTarget : .valid
        case .attachToGoal:
            return command.target.goalID == nil || command.target.captureID == nil ? .needsMissingTarget : .valid
        case .createTimeItem:
            return command.payload.primaryText == nil ? .needsConfirmation : .valid
        case .scheduleItem:
            if command.payload.metadata["calendarWriteIntent"] == "true",
               command.payload.metadata["userConfirmed"] != "true" {
                return .needsConfirmation
            }
            return command.target.captureID == nil && command.target.timeID == nil && command.payload.primaryText == nil
                ? .needsMissingTarget
                : .valid
        case .placeStepInTime:
            return command.target.stepID == nil || command.target.timeID == nil ? .needsMissingTarget : .valid
        case .protectTimeWindow:
            return command.target.timeID == nil ? .needsMissingTarget : .valid
        case .correctTimeWindow:
            guard let correctionKind = command.payload.metadata["correctionKind"],
                  let timeCorrection = TimeMutationActionKind(rawValue: correctionKind),
                  TimeMutationActionKind.correctionKinds.contains(timeCorrection) else {
                return .invalid
            }
            return command.target.timeID == nil ? .needsMissingTarget : .valid
        case .startStepSession, .completeAction, .delayAction, .splitAction:
            return command.target.goalID == nil || command.target.stepID == nil ? .needsMissingTarget : .valid
        case .recoverAction:
            return command.target.goalID == nil && command.target.captureID == nil && command.target.timeID == nil
                ? .needsMissingTarget
                : .valid
        case .markWaiting, .archiveItem:
            return command.target.captureID == nil && command.target.goalID == nil && command.target.timeID == nil
                ? .needsMissingTarget
                : .valid
        case .setPriority:
            return command.payload.priorityHints.hasAnySignal == false ? .invalid : targetBacked(command)
        case .setUrgency:
            return command.payload.priorityHints.urgency == nil ? .invalid : targetBacked(command)
        case .prepareExport, .performExport:
            return .valid
        case .deleteObject, .forgetMemory:
            return command.target.goalID == nil && command.target.captureID == nil &&
                command.target.timeID == nil && command.target.reviewID == nil ? .needsMissingTarget : .valid
        case .setDeadline:
            return command.payload.deadlineText == nil && command.payload.priorityHints.deadline == nil
                ? .invalid
                : targetBacked(command)
        case .setContextLens:
            return command.payload.contextLens == nil ? .invalid : .valid
        case .clearContextLensOverride:
            return .valid
        case .routeCommitment:
            return command.payload.primaryText == nil && command.target.captureID == nil ? .invalid : .valid
        case .addDeliverable:
            return command.target.goalID == nil || command.payload.title == nil ? .needsMissingTarget : .valid
        case .removeDeliverable:
            return command.target.goalID == nil || command.target.deliverableID == nil ? .needsMissingTarget : .valid
        case .addGoalScopeItem:
            return command.target.goalID == nil || command.payload.title == nil ? .needsMissingTarget : .valid
        case .removeGoalScopeItem:
            return command.target.goalID == nil || command.target.scopeItemID == nil ? .needsMissingTarget : .valid
        case .askWhy:
            return command.target.explanationID == nil && command.target.destination == nil ? .needsMissingTarget : .valid
        case .dismissRecommendation:
            return command.target.recommendationID == nil && command.target.explanationID == nil
                ? .needsMissingTarget
                : .valid
        }
    }

    private func targetBacked(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        command.target.goalID == nil && command.target.captureID == nil && command.target.timeID == nil
            ? .needsMissingTarget
            : .valid
    }
}
