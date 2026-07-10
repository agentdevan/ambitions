import Foundation

struct RuntimeCommandTransactionRequest: Sendable, Equatable {
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

enum RuntimeTransactionCommitPolicy {
    static let policyID = "meaningful_mutation_requires_commit"

    static let requiredEvidenceKeys = [
        "runtimeTransactionID",
        "runtimeEventID",
        "runtimeReceiptID",
        "runtimeRollbackPlanID",
        "runtimeReplayTraceID",
    ]

    static func requiresCommit(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult
    ) -> Bool {
        result.status == .succeeded && command.kind.recordsRuntimeMutation
    }

    static func transactionRequest(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String
    ) -> RuntimeCommandTransactionRequest? {
        guard requiresCommit(command: command, result: result) else {
            return nil
        }

        let resolvedCommand = command.resolvedForRuntimeTransaction(result: result)
        return RuntimeCommandTransactionRequest(
            command: resolvedCommand,
            beforeSnapshot: RuntimeCommandTransactionRequest.beforeSummary(command: command),
            afterSnapshot: RuntimeCommandTransactionRequest.afterSummary(
                command: resolvedCommand,
                result: result,
                recordedAt: recordedAt
            ),
            targetSurface: StageMutationTargetSurface.commandSurface(command: resolvedCommand, result: result)
        )
    }

    static func missingEvidenceKeys(in result: AmbitionsCommandExecutionResult) -> [String] {
        requiredEvidenceKeys.filter { key in
            result.metadata[key]?.isEmpty != false
        }
    }

    static func hasCommittedEvidence(_ result: AmbitionsCommandExecutionResult) -> Bool {
        result.metadata["runtimeTransactionDisposition"] != "not_committed" &&
            missingEvidenceKeys(in: result).isEmpty
    }

    static func failureResult(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        reason: String,
        error: Error? = nil
    ) -> AmbitionsCommandExecutionResult {
        let receipt = RuntimeTransactionFailureReceipt(
            command: command,
            reason: reason,
            missingEvidenceKeys: missingEvidenceKeys(in: result),
            blockedAt: recordedAt,
            attemptedResultStatus: result.status
        )
        var metadata = result.metadata
        metadata.merge(receipt.resultMetadata) { _, new in new }
        metadata["blockedBy"] = "runtime_transaction_commit_failed"
        if result.eventLedgerEntryIDs.isEmpty == false {
            metadata["runtimeBlockedEventLedgerEntryIDs"] = result.eventLedgerEntryIDs.joined(separator: ",")
        }
        if let error {
            metadata["runtimeTransactionBlockedBy"] = String(describing: error)
        }

        return AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Runtime transaction did not commit, so Ambitions blocked the mutation result to preserve replay safety.",
            route: result.route,
            target: result.target ?? command.target,
            eventLedgerEntryIDs: [],
            recommendationExplanationIDs: result.recommendationExplanationIDs,
            metadata: metadata
        )
    }

    static func resultByCommittingRuntimeTransaction(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        commandRecordID: String,
        timestamp: Date,
        runtimeEvents: (any RuntimeEventStore)?,
        projectionStore: ProjectionStoreSQLite? = nil,
        searchIndex: FTSIndex? = nil,
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore,
        runtimeValidator: RuntimeValidator,
        commandJournal: any CommandJournal,
        journalReceipt: CommandJournalAppendReceipt?
    ) async -> AmbitionsCommandExecutionResult {
        guard requiresCommit(command: command, result: result) else {
            return result
        }
        guard let runtimeEvents else {
            return failureResult(
                command: command,
                result: result,
                recordedAt: recordedAt,
                reason: "runtime_events_unavailable"
            )
        }
        guard let request = transactionRequest(
            command: command,
            result: result,
            recordedAt: recordedAt
        ) else {
            return failureResult(
                command: command,
                result: result,
                recordedAt: recordedAt,
                reason: "runtime_transaction_request_unavailable"
            )
        }

        let coordinator = RuntimeTransactionCoordinator(
            eventStore: runtimeEvents,
            idempotencyStore: runtimeTransactionIdempotencyStore,
            validator: runtimeValidator,
            projectionStore: projectionStore,
            searchIndex: searchIndex
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
            var runtimeMetadata = outcome.receipt.resultMetadata(disposition: outcome.disposition).merging([
                "runtimeReplayDecision": outcome.replayOutcome.decision.rawValue,
                "runtimeDoubleApplyDisposition": outcome.replayOutcome.doubleApplyDisposition.rawValue,
                "runtimeProjectionStoreStatus": outcome.projectionStoreReceipt != nil
                    ? "saved"
                    : (projectionStore == nil ? "not_configured" : "needs_recovery"),
                "runtimeProjectionStoreIDs": outcome.projectionStoreReceipt?.storedProjectionIDs.map(\.rawValue).joined(separator: ",") ?? "",
                "runtimeSearchStoreStatus": outcome.searchRebuildReceipt == nil ? "not_configured" : "rebuilt",
                "runtimeSearchStoreIndexedRecordCount": outcome.searchRebuildReceipt.map { String($0.indexedRecordCount) } ?? "",
            ], uniquingKeysWith: { _, new in new })
            if let projectionReceipt = outcome.projectionStoreReceipt {
                let projectionIDs = projectionReceipt.storedProjectionIDs.sorted()
                runtimeMetadata["runtimeMaterializedProjectionCursorIDs"] = projectionIDs.map(\.rawValue).joined(separator: ",")
                runtimeMetadata["runtimeMaterializedProjectionCursorSequences"] = projectionIDs.compactMap {
                    projectionReceipt.cursorSequencesByProjectionID[$0].map(String.init)
                }.joined(separator: ",")
                runtimeMetadata["runtimeMaterializedProjectionCursorChecksums"] = projectionIDs.compactMap {
                    projectionReceipt.cursorChecksumsByProjectionID[$0]
                }.joined(separator: ",")
            }
            if journalReceipt != nil {
                do {
                    let linkReceipt = try await commandJournal.linkRuntimeCommit(
                        commandID: command.id,
                        runtimeEventID: outcome.receipt.eventID,
                        runtimeReceiptID: outcome.receipt.receiptID,
                        linkedAt: DomainTimestamp.string(from: timestamp)
                    )
                    runtimeMetadata.merge(linkReceipt.resultMetadata) { _, new in new }
                    runtimeMetadata["commandJournalRuntimeLinkStatus"] = "linked"
                } catch {
                    runtimeMetadata["commandJournalRuntimeLinkStatus"] = "failed"
                    runtimeMetadata["commandJournalRuntimeLinkError"] = String(describing: error)
                }
            }
            let committedResult = result.mergingMetadata(runtimeMetadata)
            guard hasCommittedEvidence(committedResult) else {
                return failureResult(
                    command: command,
                    result: committedResult,
                    recordedAt: recordedAt,
                    reason: "runtime_commit_evidence_missing"
                )
            }
            return committedResult
        } catch {
            let failedResult = result.mergingMetadata([
                "runtimeTransactionDisposition": "not_committed",
                "runtimeTransactionBlockedBy": String(describing: error),
            ])
            return failureResult(
                command: command,
                result: failedResult,
                recordedAt: recordedAt,
                reason: "runtime_transaction_commit_failed",
                error: error
            )
        }
    }
}

extension AmbitionsCommand {
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

extension AmbitionsCommandKind {
    var recordsRuntimeMutation: Bool {
        switch self {
        case .openDestination, .askWhy, .prepareExport, .performExport:
            return false
        default:
            return true
        }
    }
}

extension AmbitionsCommandRelations {
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

extension AmbitionsCommandTarget {
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

extension StageMutationTargetSurface {
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
