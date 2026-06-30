import Foundation

extension AmbitionsCommandExecutor {
    @discardableResult
    func persistExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date,
        compilation: CommandCompilation? = nil,
        journalReceipt: CommandJournalAppendReceipt? = nil
    ) async -> AmbitionsCommandExecutionResult {
        let recordedAt = DomainTimestamp.string(from: timestamp)
        let commandRecordID = "command.execution.\(command.id)"
        let transactionResult = await resultByCommittingRuntimeTransaction(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: commandRecordID,
            timestamp: timestamp
        )
        let receipt = receiptFactory.makeReceipt(
            command: command,
            result: transactionResult,
            compilation: compilation,
            journalReceipt: journalReceipt,
            issuedAt: recordedAt
        )
        let enrichedResult = transactionResult.mergingMetadata(receipt.resultMetadata)
        let record = AmbitionsCommandExecutionRecord(
            id: commandRecordID,
            command: command,
            result: enrichedResult,
            recordedAt: recordedAt
        )

        try? await commandExecutionRecords?.append(record)
        return enrichedResult
    }

    func appendCommandEnvelope(
        _ compilation: CommandCompilation
    ) async -> CommandJournalAppendOutcome {
        do {
            return .appended(try await commandJournal.append(compilation.envelope))
        } catch {
            return .failed(error)
        }
    }

    func commandJournalFailureResult(
        command: AmbitionsCommand,
        compilation: CommandCompilation,
        error: Error
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command journal append failed before mutation, so Ambitions skipped execution to preserve replay safety.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "blockedBy": "command_journal_append_failed",
                "commandJournalError": String(describing: error)
            ]
        )
        .mergingMetadata(compilation.resultMetadata)
    }

    private func resultByCommittingRuntimeTransaction(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        commandRecordID: String,
        timestamp: Date
    ) async -> AmbitionsCommandExecutionResult {
        guard let runtimeEvents,
              let request = runtimeTransactionRequest(
                command: command,
                result: result,
                recordedAt: recordedAt
              )
        else {
            return result
        }

        let coordinator = RuntimeTransactionCoordinator(
            eventStore: runtimeEvents,
            idempotencyStore: runtimeTransactionIdempotencyStore,
            validator: runtimeValidator
        )

        do {
            let outcome = try await coordinator.commit(
                command: request.command,
                beforeSnapshot: request.beforeSnapshot,
                afterSnapshot: request.afterSnapshot,
                targetSurface: request.targetSurface,
                executionResult: result,
                commandRecordID: commandRecordID,
                occurredAt: timestamp
            )
            return result.mergingMetadata([
                "runtimeTransactionDisposition": outcome.disposition.rawValue,
                "runtimeTransactionID": outcome.receipt.transactionID,
                "runtimeEventID": outcome.receipt.eventID,
                "runtimeReceiptID": outcome.receipt.receiptID,
                "runtimeRollbackPlanID": outcome.receipt.rollbackPlanID,
                "runtimeReplayTraceID": outcome.receipt.replayTraceID,
                "runtimeReplayDecision": outcome.replayOutcome.decision.rawValue,
                "runtimeDoubleApplyDisposition": outcome.replayOutcome.doubleApplyDisposition.rawValue,
                "runtimeProjectionCursorCount": String(outcome.receipt.projectionCursors.count),
                "runtimeProjectionIDs": outcome.receipt.projectionCursors.map(\.projectionID.rawValue).sorted().joined(separator: ","),
            ])
        } catch {
            return result.mergingMetadata([
                "runtimeTransactionDisposition": "not_committed",
                "runtimeTransactionBlockedBy": String(describing: error),
            ])
        }
    }

    private func runtimeTransactionRequest(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String
    ) -> RuntimeCommandTransactionRequest? {
        guard result.status == .succeeded, command.kind.recordsRuntimeMutation else {
            return nil
        }

        let resolvedCommand = command.resolvedForRuntimeTransaction(result: result)
        guard resolvedCommand.target.hasRuntimeObjectReference else {
            return nil
        }

        return RuntimeCommandTransactionRequest(
            command: resolvedCommand,
            beforeSnapshot: RuntimeCommandTransactionRequest.beforeSummary(command: command),
            afterSnapshot: RuntimeCommandTransactionRequest.afterSummary(command: resolvedCommand, result: result, recordedAt: recordedAt),
            targetSurface: StageMutationTargetSurface.commandSurface(command: resolvedCommand, result: result)
        )
    }
}

enum CommandJournalAppendOutcome {
    case appended(CommandJournalAppendReceipt)
    case failed(Error)
}

private struct RuntimeCommandTransactionRequest: Sendable, Equatable {
    let command: AmbitionsCommand
    let beforeSnapshot: String
    let afterSnapshot: String
    let targetSurface: StageMutationTargetSurface

    static func beforeSummary(command: AmbitionsCommand) -> String {
        "Before \(command.kind.rawValue) from \(command.source.rawValue)."
    }

    static func afterSummary(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String
    ) -> String {
        let objectSummary = command.target.runtimeObjectSummary
        if objectSummary.isEmpty {
            return "\(result.summary) Recorded at \(recordedAt)."
        }
        return "\(result.summary) \(objectSummary). Recorded at \(recordedAt)."
    }
}

private extension AmbitionsCommand {
    func resolvedForRuntimeTransaction(result: AmbitionsCommandExecutionResult) -> AmbitionsCommand {
        let resolvedTarget = result.target ?? target
        return AmbitionsCommand(
            id: id,
            kind: kind,
            source: source,
            target: resolvedTarget,
            payload: payload,
            validationState: validationState,
            executionStatus: result.status,
            result: result,
            createdAt: createdAt,
            requestedAt: requestedAt,
            actor: actor,
            sourceSurface: sourceSurface,
            relations: relations.merging(target: resolvedTarget, result: result),
            localOnly: localOnly,
            privacy: privacy,
            schemaVersion: schemaVersion
        )
    }
}

private extension AmbitionsCommandKind {
    var recordsRuntimeMutation: Bool {
        switch self {
        case .openDestination, .askWhy, .dismissRecommendation, .prepareExport, .performExport:
            return false
        default:
            return true
        }
    }
}

private extension AmbitionsCommandRelations {
    func merging(
        target: AmbitionsCommandTarget,
        result: AmbitionsCommandExecutionResult
    ) -> AmbitionsCommandRelations {
        func appendedUnique(_ values: [String], _ candidate: String?) -> [String] {
            guard let candidate, candidate.isEmpty == false, values.contains(candidate) == false else {
                return values
            }
            return values + [candidate]
        }

        func mergingUnique(_ values: [String], _ additions: [String]) -> [String] {
            additions.reduce(values) { current, addition in
                guard addition.isEmpty == false, current.contains(addition) == false else {
                    return current
                }
                return current + [addition]
            }
        }

        return AmbitionsCommandRelations(
            goalIDs: appendedUnique(goalIDs, target.goalID),
            captureIDs: appendedUnique(captureIDs, target.captureID),
            timeIDs: appendedUnique(timeIDs, target.timeID),
            reviewIDs: appendedUnique(reviewIDs, target.reviewID),
            eventLedgerEntryIDs: mergingUnique(eventLedgerEntryIDs, result.eventLedgerEntryIDs),
            recommendationExplanationIDs: mergingUnique(recommendationExplanationIDs, result.recommendationExplanationIDs)
        )
    }
}

private extension AmbitionsCommandTarget {
    var hasRuntimeObjectReference: Bool {
        goalID != nil ||
            captureID != nil ||
            timeID != nil ||
            reviewID != nil ||
            stepID != nil ||
            deliverableID != nil ||
            scopeItemID != nil ||
            recommendationID != nil ||
            explanationID != nil
    }

    var runtimeObjectSummary: String {
        [
            goalID.map { "goal=\($0)" },
            captureID.map { "capture=\($0)" },
            timeID.map { "time=\($0)" },
            reviewID.map { "review=\($0)" },
            stepID.map { "step=\($0)" },
            deliverableID.map { "deliverable=\($0)" },
            scopeItemID.map { "scope=\($0)" },
            recommendationID.map { "recommendation=\($0)" },
            explanationID.map { "explanation=\($0)" },
        ].compactMap { $0 }.joined(separator: " ")
    }
}

private extension StageMutationTargetSurface {
    static func commandSurface(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult
    ) -> StageMutationTargetSurface {
        if let destinationSurface = surface(destination: result.target?.destination ?? result.route) {
            return destinationSurface
        }
        if let sourceSurface = surface(source: command.source) {
            return sourceSurface
        }
        return .today
    }

    static func surface(destination: AmbitionsCommandDestination?) -> StageMutationTargetSurface? {
        switch destination {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .time:
            return .time
        case .you:
            return .you
        case .reviews, .capture, .captureInbox, .memoryLens, .commandSheet, .weeklyReview, .none:
            return nil
        }
    }

    static func surface(source: AmbitionsCommandSource) -> StageMutationTargetSurface? {
        switch source {
        case .today, .capture, .widget, .liveActivity, .appIntent, .notification, .deepLink, .system:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .time:
            return .time
        case .you:
            return .you
        case .reviews:
            return nil
        }
    }
}
