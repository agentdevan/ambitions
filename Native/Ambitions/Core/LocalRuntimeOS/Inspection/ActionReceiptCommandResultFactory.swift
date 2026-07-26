import Foundation

extension ActionReceipt {
    static func fromCommandResult(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        occurredAt: String
    ) -> ActionReceipt {
        let affectedObjects = ActionReceipt.affectedObjects(command: command, result: result)
        let resultState = ActionReceipt.resultState(command: command, result: result)
        let safeFailure = ActionReceipt.safeFailure(command: command, result: result, resultState: resultState)

        return ActionReceipt(
            id: "receipt.command.\(command.id)",
            resultState: resultState,
            title: ActionReceipt.title(command: command, resultState: resultState),
            summary: result.summary,
            sourceDomain: ActionReceipt.sourceDomain(for: command.source),
            occurredAt: occurredAt,
            affectedObjects: affectedObjects.isEmpty ? [ActionReceipt.commandSourceObject(command)] : affectedObjects,
            changedFacts: ActionReceipt.changedFacts(command: command, result: result, resultState: resultState),
            why: ActionReceiptWhyExplanation(
                recommendationExplanationIDs: result.recommendationExplanationIDs + command.relations.recommendationExplanationIDs,
                eventLedgerEntryIDs: result.eventLedgerEntryIDs + command.relations.eventLedgerEntryIDs
            ),
            nextAction: ActionReceipt.nextAction(for: result),
            correctionAvailability: ActionReceipt.correctionAvailability(command: command, result: result),
            undoAvailability: ActionReceipt.undoAvailability(command: command, result: result),
            safetyState: ActionReceipt.safetyState(result: result, resultState: resultState),
            safeFailure: safeFailure,
            sourceObject: ActionReceipt.commandSourceObject(command)
        )
    }

    static func affectedObjects(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> [LifeGraphObjectReference] {
        let target = result.target ?? command.target
        var objects: [LifeGraphObjectReference] = []
        if let goalID = target.goalID {
            objects.append(LifeGraphObjectReference(kind: .goal, id: goalID, sourceDomain: .goals))
        }
        if let captureID = target.captureID {
            objects.append(LifeGraphObjectReference(kind: .capture, id: captureID, sourceDomain: .capture))
        }
        if let timeID = target.timeID {
            objects.append(LifeGraphObjectReference(kind: .action, id: timeID, sourceDomain: .time))
        }
        if let stepID = target.stepID {
            objects.append(LifeGraphObjectReference(kind: .step, id: stepID, parentContextID: target.goalID, sourceDomain: .goalEngine))
        }
        return objects
    }

    static func resultState(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> ActionReceiptResultState {
        switch result.status {
        case .succeeded:
            switch command.typedPayload {
            case let .capture(value):
                switch value.action {
                case .quickCapture: return .created
                case .attachToGoal: return .attached
                case .routeCommitment, .markWaiting, .archive: return .changed
                }
            case let .step(value):
                if case .complete = value.action { return .completed }
                return .changed
            case .schedule: return .draftedPrepared
            case .goal, .reminder, .profile, .history, .repair, .importDeletion,
                 .externalOperation, .attachment:
                return .changed
            case .compensation:
                return .failedSafely
            }
        case .requiresConfirmation:
            return .needsConfirmation
        case .noOp:
            return .noOp
        case .failed, .unsupported, .blocked:
            return .failedSafely
        case .pending, .queued:
            return .draftedPrepared
        }
    }

    static func changedFacts(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        resultState: ActionReceiptResultState
    ) -> [ActionReceiptChangedFact] {
        let object = affectedObjects(command: command, result: result).first
        let kind: ActionReceiptChangedFactKind
        switch resultState {
        case .created:
            kind = .createdCapture
        case .attached:
            kind = .attachedCaptureToGoal
        case .moved:
            kind = .movedActionToLater
        case .completed:
            kind = .completedAction
        case .exportedPrepared:
            kind = .preparedExport
        case .draftedPrepared:
            kind = .preparedDraft
        case .failedSafely:
            kind = .failedSafely
        case .needsConfirmation:
            kind = .needsConfirmation
        case .noOp:
            kind = .noChange
        case .changed, .scheduled, .detached, .undoAvailable, .undoUnavailable, .correctionAvailable:
            if case let .capture(value) = command.typedPayload,
               case .markWaiting = value.action {
                kind = .markedWaiting
            } else {
                kind = .changedField
            }
        }

        return [
            ActionReceiptChangedFact(
                id: "fact.\(command.id).\(kind.rawValue)",
                kind: kind,
                object: object,
                summary: result.summary
            )
        ]
    }

    static func safeFailure(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        resultState: ActionReceiptResultState
    ) -> ActionReceiptSafeFailure? {
        guard resultState == .failedSafely else { return nil }
        return ActionReceiptSafeFailure(
            whatFailed: title(command: command, resultState: resultState),
            whyFailed: result.metadata["blockedBy"] ?? result.metadata["validation"] ?? result.metadata["error"],
            unchangedFacts: ["No calendar, export, sync, external surface, or unsupported app data was changed."],
            nextSafeAction: ActionReceiptNextAction(kind: .dismiss, title: "Dismiss")
        )
    }

    static func undoAvailability(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> ActionReceiptUndoAvailability {
        guard result.status == .succeeded else {
            return result.status == .requiresConfirmation ? .requiresConfirmation : .unavailable
        }

        switch command.typedPayload {
        case let .capture(value):
            switch value.action {
            case .quickCapture, .routeCommitment, .attachToGoal, .markWaiting, .archive: return .availableLocal
            }
        case let .goal(value):
            switch value.action {
            case .setPriority, .setUrgency, .setDeadline: return .availableLocal
            default: return .notSupportedYet
            }
        case let .schedule(value):
            if case let .calendarWrite(intent) = value.action {
                return intent.operationIdentityProvenance == .currentRequired ? .requiresConfirmation : .availableLocal
            }
            return .notSupportedYet
        case .history: return .unavailable
        case .step, .reminder, .profile, .repair, .importDeletion, .externalOperation,
             .compensation:
            return .notSupportedYet
        }
    }

    static func correctionAvailability(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult) -> ActionReceiptCorrectionAvailability {
        switch result.status {
        case .succeeded:
            return command.relations.recommendationExplanationIDs.isEmpty && result.recommendationExplanationIDs.isEmpty ? .available : .availableWithReason
        case .requiresConfirmation, .failed, .blocked, .unsupported:
            return .availableWithReason
        case .pending, .queued, .noOp:
            return .unavailable
        }
    }

    static func safetyState(result: AmbitionsCommandExecutionResult, resultState: ActionReceiptResultState) -> ActionReceiptSafetyState {
        if resultState == .needsConfirmation {
            return .confirmationRequired
        }
        switch result.status {
        case .failed, .blocked, .unsupported:
            return .safeFailure
        case .queued, .pending:
            return .degraded
        case .succeeded, .noOp, .requiresConfirmation:
            return .normal
        }
    }

    static func nextAction(for result: AmbitionsCommandExecutionResult) -> ActionReceiptNextAction? {
        switch result.route {
        case .today:
            return ActionReceiptNextAction(kind: .openToday, title: "Open Today", destination: .today)
        case .time:
            return ActionReceiptNextAction(kind: .openTime, title: "Open Time", destination: .time)
        case .goalDetail, .goals:
            return ActionReceiptNextAction(kind: .reviewGoal, title: "Review goal", destination: result.route)
        case .capture, .captureInbox:
            return ActionReceiptNextAction(kind: .dismiss, title: "Dismiss", destination: result.route)
        case .you, .reviews, .memoryLens, .commandSheet, .weeklyReview, nil:
            return nil
        }
    }

    static func title(command: AmbitionsCommand, resultState: ActionReceiptResultState) -> String {
        switch resultState {
        case .created:
            return "Capture created"
        case .attached:
            return "Item attached"
        case .draftedPrepared:
            return "Draft prepared"
        case .failedSafely:
            return "Action did not change anything"
        case .needsConfirmation:
            return "Confirmation needed"
        case .completed:
            return "Action completed"
        default:
            return command.content.title ?? command.operation.rawValue.replacingOccurrences(of: "_", with: " ")
        }
    }

    static func sourceDomain(for source: AmbitionsCommandSource) -> ActionReceiptSourceDomain {
        switch source {
        case .today:
            return .today
        case .goals:
            return .goals
        case .capture:
            return .capture
        case .time:
            return .time
        case .you:
            return .you
        case .reviews:
            return .reviews
        case .goalDetail:
            return .goalDetail
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            return .externalSurface
        case .system:
            return .system
        }
    }

    static func commandSourceObject(_ command: AmbitionsCommand) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: .action,
            id: command.id,
            label: command.operation.rawValue,
            sourceDomain: .commandPipeline
        )
    }
}
