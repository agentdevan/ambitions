import Foundation

enum TrustSystemCommitError: Error, Sendable, Equatable {
    case commandMismatch(expected: String, actual: String?)
    case nonLocalInput(String)
    case receiptMissingAffectedObject(String)
    case receiptCommandMismatch(receiptID: String, commandID: String)
}

struct TrustSystemPublicSourceAtlasReference: Sendable, Equatable, Hashable {
    let packID: String
    let manifestID: String?
    let summary: String

    init(packID: String, manifestID: String? = nil, summary: String) {
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifestID = manifestID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct TrustSystemCommitInput: Sendable, Equatable {
    let commandRecord: AmbitionsCommandExecutionRecord
    let runtimeEvent: RuntimeEvent
    let receipt: ActionReceipt
    let proofRelevance: ActionReceiptProofRelevance
    let publicSourceAtlasReferences: [TrustSystemPublicSourceAtlasReference]

    init(
        commandRecord: AmbitionsCommandExecutionRecord,
        runtimeEvent: RuntimeEvent,
        receipt: ActionReceipt,
        proofRelevance: ActionReceiptProofRelevance = .notProof,
        publicSourceAtlasReferences: [TrustSystemPublicSourceAtlasReference] = []
    ) {
        self.commandRecord = commandRecord
        self.runtimeEvent = runtimeEvent
        self.receipt = receipt
        self.proofRelevance = proofRelevance
        self.publicSourceAtlasReferences = publicSourceAtlasReferences
    }
}

struct TrustSystemCommitPlan: Sendable, Equatable {
    let commandRecord: AmbitionsCommandExecutionRecord
    let runtimeEvent: RuntimeEvent
    let eventLedgerEntry: EventLedgerEntry
    let receiptRecord: ActionReceiptHistoryRecord
    let proofLedgerEntry: ActionReceiptProofLedgerEntry
    let sourceRecordLedger: SourceRecordLedger
    let undoLedger: UndoLedger
    let auditTrail: AuditTrail
    let historyProjection: TrustHistoryQueryProjection
    let replayOutcome: LedgerReplayOutcome

    var hasCompleteCommandEventProjectionReceiptReplayFlow: Bool {
        auditTrail.hasCompleteCommandEventReceiptHistoryFlow(
            commandID: commandRecord.commandID,
            receiptID: receiptRecord.id
        ) &&
            historyProjection.results.isEmpty == false &&
            replayOutcome.doubleApplyDisposition == .skipDuplicateMutation &&
            sourceRecordLedger.separationReport.isSeparated
    }
}

struct TrustSystemCommitPlanner: Sendable {
    let historyQueryEngine: HistoryQueryEngine

    init(historyQueryEngine: HistoryQueryEngine = HistoryQueryEngine()) {
        self.historyQueryEngine = historyQueryEngine
    }

    func plan(
        _ input: TrustSystemCommitInput,
        plannedAt: String
    ) throws -> TrustSystemCommitPlan {
        try validate(input)

        let eventLedgerEntry = makeEventLedgerEntry(input: input, plannedAt: plannedAt)
        let receiptRecord = ActionReceiptHistoryRecord(
            receipt: input.receipt,
            privacyLevel: input.runtimeEvent.privacy.receiptPrivacyLevel,
            localOnly: input.receipt.localOnlyForTrustInput(defaultValue: input.runtimeEvent.localOnly),
            proofRelevance: input.proofRelevance
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receiptRecord.receipt,
            privacyLevel: receiptRecord.privacyLevel,
            localOnly: receiptRecord.localOnly,
            visibilityLevels: [.peek, .trail, .search],
            proofRelevance: receiptRecord.proofRelevance
        )
        let sourceRecordLedger = SourceRecordLedger(records: makeSourceRecords(
            input: input,
            eventLedgerEntry: eventLedgerEntry,
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofLedgerEntry,
            plannedAt: plannedAt
        ))
        let undoEntry = UndoLedgerEntry(
            commandID: input.commandRecord.commandID,
            receiptRecord: receiptRecord
        )
        let undoLedger = UndoLedger(entries: [undoEntry])
        let historyProjection = historyQueryEngine.project(
            query: TrustHistoryQuery(limit: 20),
            receiptRecords: [receiptRecord],
            eventLedgerEntries: [eventLedgerEntry]
        )
        let replayOutcome = LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey(input.commandRecord.commandID),
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: receiptRecord.receipt.summary
        )
        let auditTrail = AuditTrail.forCommit(
            commandRecord: input.commandRecord,
            eventLedgerEntry: eventLedgerEntry,
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofLedgerEntry,
            sourceRecordLedger: sourceRecordLedger,
            undoEntry: undoEntry,
            historyProjection: historyProjection,
            occurredAt: plannedAt
        )

        return TrustSystemCommitPlan(
            commandRecord: input.commandRecord,
            runtimeEvent: input.runtimeEvent,
            eventLedgerEntry: eventLedgerEntry,
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofLedgerEntry,
            sourceRecordLedger: sourceRecordLedger,
            undoLedger: undoLedger,
            auditTrail: auditTrail,
            historyProjection: historyProjection,
            replayOutcome: replayOutcome
        )
    }

    private func validate(_ input: TrustSystemCommitInput) throws {
        guard input.runtimeEvent.commandID == input.commandRecord.commandID else {
            throw TrustSystemCommitError.commandMismatch(
                expected: input.commandRecord.commandID,
                actual: input.runtimeEvent.commandID
            )
        }
        guard input.commandRecord.localOnly else {
            throw TrustSystemCommitError.nonLocalInput("command record")
        }
        guard input.runtimeEvent.localOnly else {
            throw TrustSystemCommitError.nonLocalInput("runtime event")
        }
        guard input.receipt.affectedObjects.isEmpty == false else {
            throw TrustSystemCommitError.receiptMissingAffectedObject(input.receipt.id)
        }
        if let metadataReceiptID = input.commandRecord.result.metadata["receiptID"],
           metadataReceiptID != input.receipt.id {
            throw TrustSystemCommitError.receiptCommandMismatch(
                receiptID: input.receipt.id,
                commandID: input.commandRecord.commandID
            )
        }
    }

    private func makeEventLedgerEntry(
        input: TrustSystemCommitInput,
        plannedAt: String
    ) -> EventLedgerEntry {
        let resultSummary: String
        let resultStatus: AmbitionsCommandExecutionStatus
        switch input.runtimeEvent.payload {
        case .commandExecution(let payload):
            resultSummary = payload.resultSummary
            resultStatus = payload.resultStatus
        default:
            resultSummary = input.commandRecord.result.summary
            resultStatus = input.commandRecord.result.status
        }

        return EventLedgerEntry(
            id: "event-ledger.\(input.commandRecord.commandID).\(input.runtimeEvent.kind.rawValue)",
            kind: eventLedgerKind(commandKind: input.commandRecord.command.kind, runtimeKind: input.runtimeEvent.kind),
            occurredAt: input.runtimeEvent.occurredAt,
            source: eventLedgerSource(commandSource: input.commandRecord.command.source),
            goalID: input.commandRecord.command.target.goalID,
            captureID: input.commandRecord.command.target.captureID,
            planID: input.commandRecord.command.target.timeID,
            reviewID: input.commandRecord.command.target.reviewID,
            title: eventTitle(commandKind: input.commandRecord.command.kind, resultStatus: resultStatus),
            summary: resultSummary,
            semanticState: input.runtimeEvent.kind.rawValue,
            tone: eventTone(resultStatus: resultStatus),
            trust: EventLedgerTrustMetadata(
                isUserConfirmed: input.commandRecord.command.actor == .user,
                requiresReview: input.runtimeEvent.privacy != .standard || resultStatus == .requiresConfirmation
            ),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: input.commandRecord.id,
                    kind: .externalCommand,
                    occurredAt: input.commandRecord.recordedAt,
                    summary: input.commandRecord.command.kind.rawValue
                )
            ],
            metadata: [
                "commandID": input.commandRecord.commandID,
                "commandRecordID": input.commandRecord.id,
                "runtimeEventKind": input.runtimeEvent.kind.rawValue,
                "receiptID": input.receipt.id,
                "plannedAt": plannedAt,
            ],
            payload: input.runtimeEvent.metadata.merging(input.commandRecord.result.metadata) { _, new in new },
            privacy: input.runtimeEvent.privacy,
            localOnly: input.runtimeEvent.localOnly,
            createdAt: plannedAt,
            updatedAt: plannedAt
        )
    }

    private func makeSourceRecords(
        input: TrustSystemCommitInput,
        eventLedgerEntry: EventLedgerEntry,
        receiptRecord: ActionReceiptHistoryRecord,
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        plannedAt: String
    ) -> [SourceRecordLedgerRecord] {
        var records = [
            SourceRecordLedgerRecord.command(input.commandRecord),
            SourceRecordLedgerRecord.runtimeEvent(eventLedgerEntry, commandID: input.commandRecord.commandID),
            SourceRecordLedgerRecord.actionReceipt(receiptRecord),
        ]

        if let proofReference = proofLedgerEntry.proofReference {
            records.append(.proofReference(proofReference, receiptRecord: receiptRecord))
        }

        records.append(contentsOf: input.publicSourceAtlasReferences.map {
            SourceRecordLedgerRecord.publicSourceAtlasReference(
                packID: $0.packID,
                manifestID: $0.manifestID,
                summary: $0.summary,
                observedAt: plannedAt,
                linkedReceiptIDs: [receiptRecord.id]
            )
        })

        return records
    }

    private func eventLedgerKind(commandKind: AmbitionsCommandKind, runtimeKind: RuntimeEventKind) -> EventLedgerKind {
        switch runtimeKind {
        case .captureRouteDecided:
            return .captureTriaged
        case .closureRecorded:
            return .actionCompleted
        case .correctionRecorded:
            return .userCorrectionAdded
        case .proofAttached:
            return .actionCompleted
        case .timePlacementProposed:
            return .itemScheduled
        case .tombstoneRecorded:
            return .goalArchived
        case .compactionSnapshot:
            return .reviewCompleted
        case .commandExecution:
            switch commandKind {
            case .quickCapture:
                return .captureCreated
            case .createGoal:
                return .goalCreated
            case .updateGoal:
                return .goalUpdated
            case .attachToGoal:
                return .captureAttachedToGoal
            case .createTimeItem, .scheduleItem, .placeStepInTime:
                return .itemScheduled
            case .completeAction:
                return .actionCompleted
            case .delayAction:
                return .actionDelayed
            case .splitAction:
                return .actionSplit
            case .recoverAction:
                return .recoveryAccepted
            case .markWaiting:
                return .actionDelayed
            case .archiveItem, .deleteObject, .forgetMemory:
                return .goalArchived
            case .setPriority:
                return .priorityChanged
            case .setUrgency:
                return .urgencyChanged
            case .setDeadline:
                return .deadlineChanged
            case .routeCommitment:
                return .commitmentRouted
            case .addDeliverable:
                return .deliverableAdded
            case .removeDeliverable:
                return .deliverableRemoved
            case .addGoalScopeItem:
                return .goalScopeItemAdded
            case .removeGoalScopeItem:
                return .goalScopeItemRemoved
            case .dismissRecommendation:
                return .recommendationDismissed
            case .updateUserPreferences:
                return .contextLensChanged
            case .openDestination, .protectTimeWindow, .correctTimeWindow, .startStepSession, .prepareExport, .performExport, .setContextLens, .clearContextLensOverride, .askWhy:
                return .planUpdated
            }
        }
    }

    private func eventLedgerSource(commandSource: AmbitionsCommandSource) -> EventLedgerSource {
        switch commandSource {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .time:
            return .time
        case .you, .reviews:
            return .you
        case .widget, .liveActivity, .appIntent, .notification, .deepLink:
            return .system
        case .system:
            return .system
        }
    }

    private func eventTitle(commandKind: AmbitionsCommandKind, resultStatus: AmbitionsCommandExecutionStatus) -> String {
        if resultStatus == .failed || resultStatus == .blocked {
            return "Command failed safely"
        }
        switch commandKind {
        case .quickCapture:
            return "Capture saved"
        case .createGoal:
            return "Goal created"
        case .completeAction:
            return "Step completed"
        case .updateUserPreferences:
            return "Preferences updated"
        case .placeStepInTime, .scheduleItem, .createTimeItem:
            return "Time updated"
        default:
            return "Command recorded"
        }
    }

    private func eventTone(resultStatus: AmbitionsCommandExecutionStatus) -> EventLedgerTone {
        switch resultStatus {
        case .succeeded:
            return .positive
        case .requiresConfirmation, .queued, .pending:
            return .caution
        case .failed, .blocked, .unsupported:
            return .recovering
        case .noOp:
            return .neutral
        }
    }
}

actor TrustSystemRecorder {
    let eventLedger: any EventLedgerRepository
    let actionReceiptHistory: any ActionReceiptHistoryRepository
    let planner: TrustSystemCommitPlanner

    init(
        eventLedger: any EventLedgerRepository,
        actionReceiptHistory: any ActionReceiptHistoryRepository,
        planner: TrustSystemCommitPlanner = TrustSystemCommitPlanner()
    ) {
        self.eventLedger = eventLedger
        self.actionReceiptHistory = actionReceiptHistory
        self.planner = planner
    }

    func record(
        _ input: TrustSystemCommitInput,
        recordedAt: String
    ) async throws -> TrustSystemCommitPlan {
        let plan = try planner.plan(input, plannedAt: recordedAt)
        try await eventLedger.append(plan.eventLedgerEntry)
        try await actionReceiptHistory.save([plan.receiptRecord])
        return plan
    }
}

private extension ActionReceipt {
    func localOnlyForTrustInput(defaultValue: Bool) -> Bool {
        defaultValue
    }
}

private extension EventLedgerPrivacyClassification {
    var receiptPrivacyLevel: ActionReceiptPrivacyLevel {
        switch self {
        case .standard:
            return .safeToShow
        case .sensitive, .calendarDerived, .syncMetadata:
            return .sensitive
        case .privateUserText:
            return .privateItem
        }
    }
}
