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
        switch command.typedPayload {
        case let .capture(capture):
            switch capture.action {
            case .quickCapture: return capture.content.primaryText == nil ? .invalid : .valid
            case .routeCommitment: return capture.content.primaryText == nil && capture.target.captureID == nil ? .invalid : .valid
            case .attachToGoal: return capture.target.goalID == nil || capture.target.captureID == nil ? .needsMissingTarget : .valid
            case .markWaiting, .archive:
                return hasAnyObjectTarget(capture.target) ? .valid : .needsMissingTarget
            }
        case let .goal(goal):
            switch goal.action {
            case .create: return goal.content.primaryText == nil ? .needsConfirmation : .valid
            case .update: return goal.target.goalID == nil ? .needsMissingTarget : .valid
            case .setPriority: return goal.content.priorityHints.hasAnySignal ? targetBacked(goal.target) : .invalid
            case .setUrgency: return goal.content.priorityHints.urgency == nil ? .invalid : targetBacked(goal.target)
            case .setDeadline:
                return goal.content.deadlineText == nil && goal.content.priorityHints.deadline == nil ? .invalid : targetBacked(goal.target)
            case .setContextLens: return goal.content.contextLens == nil ? .invalid : .valid
            case .clearContextLens: return .valid
            case .addDeliverable: return goal.target.goalID == nil || goal.content.title == nil ? .needsMissingTarget : .valid
            case .removeDeliverable: return goal.target.goalID == nil || goal.target.deliverableID == nil ? .needsMissingTarget : .valid
            case .addScopeItem: return goal.target.goalID == nil || goal.content.title == nil ? .needsMissingTarget : .valid
            case .removeScopeItem: return goal.target.goalID == nil || goal.target.scopeItemID == nil ? .needsMissingTarget : .valid
            }
        case let .step(step):
            switch step.action {
            case .startSession, .complete, .delay, .split, .todayGoalStep:
                return step.target.goalID == nil || step.target.stepID == nil ? .needsMissingTarget : .valid
            case .recover:
                return hasAnyObjectTarget(step.target) ? .valid : .needsMissingTarget
            }
        case let .schedule(schedule):
            switch schedule.action {
            case .createItem: return schedule.content.primaryText == nil ? .needsConfirmation : .valid
            case .schedule:
                return schedule.target.captureID == nil && schedule.target.timeID == nil && schedule.content.primaryText == nil ? .needsMissingTarget : .valid
            case .placeStep: return schedule.target.stepID == nil || schedule.target.timeID == nil ? .needsMissingTarget : .valid
            case .protectWindow: return schedule.target.timeID == nil ? .needsMissingTarget : .valid
            case let .correctWindow(correction):
                guard TimeMutationActionKind.correctionKinds.contains(correction.action) else { return .invalid }
                return schedule.target.timeID == nil ? .needsMissingTarget : .valid
            case .undo: return .unsupportedInThisBuild
            case .ritual: return schedule.target.goalID == nil || schedule.target.stepID == nil ? .needsMissingTarget : .valid
            case let .calendarWrite(intent):
                switch intent.operationIdentityProvenance {
                case .currentRequired:
                    guard intent.operationID != nil else { return .blockedByMissingFoundation }
                    return .needsConfirmation
                case .legacyExplicit:
                    guard intent.operationID != nil else { return .blockedByMissingFoundation }
                case .legacyAbsent:
                    guard intent.operationID == nil else { return .invalid }
                }
                guard schedule.target.captureID != nil || schedule.target.timeID != nil || schedule.content.primaryText != nil else {
                    return .needsMissingTarget
                }
                return .needsConfirmation
            }
        case let .reminder(reminder):
            switch reminder.action {
            case .create: return reminder.content.primaryText == nil ? .needsConfirmation : .valid
            case .update, .delete: return targetBacked(reminder.target)
            }
        case let .profile(profile):
            return profile.target.destination == .you && profile.preferences != nil ? .valid : (profile.target.destination == .you ? .invalid : .needsMissingTarget)
        case let .history(history):
            switch history.action {
            case .openDestination: return history.target.destination == nil ? .needsMissingTarget : .valid
            case .askWhy: return history.target.explanationID == nil && history.target.destination == nil ? .needsMissingTarget : .valid
            case .dismissRecommendation:
                return history.target.recommendationID == nil && history.target.explanationID == nil ? .needsMissingTarget : .valid
            case .todayReceipt: return .valid
            }
        case let .repair(repair):
            return hasAnyObjectTarget(repair.target) ? .valid : .needsMissingTarget
        case let .importDeletion(value):
            switch value.action {
            case .prepareExport, .performExport: return .valid
            case .deleteObject, .forgetMemory: return hasAnyObjectTarget(value.target) ? .valid : .needsMissingTarget
            }
        case let .externalOperation(external):
            guard external.title.isEmpty == false else { return .invalid }
            return external.target.goalID == nil && external.target.stepID == nil ? .needsMissingTarget : .valid
        case let .compensation(compensation):
            if Task.isCancelled { return .invalid }
            guard compensation.targets.isEmpty == false,
                  compensation.targets.count <= RuntimeCompensationLimits.maximumTargets else {
                return .invalid
            }
            let targetKeys = compensation.targets.map {
                "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)"
            }
            guard compensation.planDigest.count == 64,
                  RuntimeStoreManifestCodec.isSHA256Hex(compensation.planDigest),
                  compensation.action.target == compensation.target,
                  compensation.content == RuntimeCommandContent(),
                  compensation.targets == compensation.targets.sorted(),
                  Set(targetKeys).count == targetKeys.count,
                  compensation.targets.allSatisfy({
                      if Task.isCancelled { return false }
                      return $0.aggregate.kind == compensation.action.aggregateKind &&
                          $0.requiredCurrentRevision == $0.sourceRevision &&
                          $0.inverseTransition == compensation.action.transition &&
                          RuntimeStoreManifestCodec.isSHA256Hex($0.sourceStateDigest)
                  }) else { return .invalid }
            return compensation.requiresConfirmation ? .needsConfirmation : .valid
        }
    }

    private func targetBacked(_ target: AmbitionsCommandTarget) -> AmbitionsCommandValidationState {
        target.goalID == nil && target.captureID == nil && target.timeID == nil
            ? .needsMissingTarget
            : .valid
    }

    private func hasAnyObjectTarget(_ target: AmbitionsCommandTarget) -> Bool {
        target.goalID != nil || target.captureID != nil || target.timeID != nil || target.reviewID != nil || target.stepID != nil
    }
}
