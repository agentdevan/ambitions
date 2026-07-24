import Foundation

enum InspectionCommitError: Error, Sendable, Equatable {
    case commandMismatch(expected: String, actual: String?)
    case nonLocalInput(String)
    case runtimeCommitReceiptNotReplayable(String)
    case runtimeCommitReceiptCommandMismatch(expected: String, actual: String)
    case runtimeCommitReceiptEventMismatch(expected: String, actual: String)
    case runtimeCommitReceiptCursorMismatch(expected: RuntimeEventCursor, actual: RuntimeEventCursor)
    case runtimeCommitReceiptReceiptMismatch(expected: String, actual: String)
    case receiptMissingAffectedObject(String)
    case receiptCommandMismatch(receiptID: String, commandID: String)
}

struct InspectionPublicSourceAtlasReference: Sendable, Equatable, Hashable {
    let packID: String
    let manifestID: String?
    let summary: String

    init(packID: String, manifestID: String? = nil, summary: String) {
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifestID = manifestID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct InspectionCommitInput: Sendable, Equatable {
    let commandRecord: AmbitionsCommandExecutionRecord
    let runtimeEventEnvelope: RuntimeEventEnvelope
    let runtimeCommitReceipt: RuntimeCommitReceipt
    let receipt: ActionReceipt
    let proofRelevance: ActionReceiptProofRelevance
    let publicSourceAtlasReferences: [InspectionPublicSourceAtlasReference]

    init(
        commandRecord: AmbitionsCommandExecutionRecord,
        runtimeEventEnvelope: RuntimeEventEnvelope,
        runtimeCommitReceipt: RuntimeCommitReceipt,
        receipt: ActionReceipt,
        proofRelevance: ActionReceiptProofRelevance = .notProof,
        publicSourceAtlasReferences: [InspectionPublicSourceAtlasReference] = []
    ) {
        self.commandRecord = commandRecord
        self.runtimeEventEnvelope = runtimeEventEnvelope
        self.runtimeCommitReceipt = runtimeCommitReceipt
        self.receipt = receipt
        self.proofRelevance = proofRelevance
        self.publicSourceAtlasReferences = publicSourceAtlasReferences
    }

    var runtimeEvent: RuntimeEvent {
        runtimeEventEnvelope.event
    }
}

struct InspectionCommitPlan: Sendable, Equatable {
    let commandRecord: AmbitionsCommandExecutionRecord
    let runtimeEventEnvelope: RuntimeEventEnvelope
    let runtimeCommitReceipt: RuntimeCommitReceipt
    let runtimeLineage: RuntimeTrustLineage
    let eventLedgerEntry: EventLedgerEntry
    let receiptRecord: ActionReceiptHistoryRecord
    let proofLedgerEntry: ActionReceiptProofLedgerEntry
    let proofLedger: ProofLedger
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
            auditTrail.hasCompleteRuntimeLineage(
                commandID: commandRecord.commandID,
                receiptID: receiptRecord.id
            ) &&
            runtimeLineage.hasCompleteTrustTrace &&
            receiptRecord.hasRuntimeLineage &&
            proofLedgerEntry.hasRuntimeLineage &&
            proofLedger.hasRuntimeLineage &&
            undoLedger.entry(receiptID: receiptRecord.id)?.hasRuntimeRollbackLineage == true &&
            historyProjection.results.isEmpty == false &&
            historyProjection.results.allSatisfy { $0.runtimeLineage?.runtimeTransactionID == runtimeLineage.runtimeTransactionID } &&
            replayOutcome.doubleApplyDisposition == .skipDuplicateMutation &&
            sourceRecordLedger.separationReport.isSeparated
    }
}

struct InspectionCommitPlanner: Sendable {
    let historyQueryEngine: HistoryQueryEngine

    init(historyQueryEngine: HistoryQueryEngine = HistoryQueryEngine()) {
        self.historyQueryEngine = historyQueryEngine
    }

    func plan(
        _ input: InspectionCommitInput,
        plannedAt: String
    ) throws -> InspectionCommitPlan {
        try validate(input)

        let runtimeLineage = RuntimeTrustLineage(runtimeCommitReceipt: input.runtimeCommitReceipt)
        let eventLedgerEntry = makeEventLedgerEntry(input: input, plannedAt: plannedAt)
        let receiptRecord = ActionReceiptHistoryRecord(
            receipt: input.receipt,
            privacyLevel: input.runtimeEvent.privacy.receiptPrivacyLevel,
            localOnly: input.receipt.localOnlyForTrustInput(defaultValue: input.runtimeEvent.localOnly),
            proofRelevance: input.proofRelevance,
            runtimeLineage: runtimeLineage
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receiptRecord.receipt,
            privacyLevel: receiptRecord.privacyLevel,
            localOnly: receiptRecord.localOnly,
            visibilityLevels: [.peek, .trail, .search],
            proofRelevance: receiptRecord.proofRelevance,
            runtimeLineage: runtimeLineage
        )
        let proofLedger = ProofLedger(
            proofLedgerEntry: proofLedgerEntry,
            eventLedgerEntryID: eventLedgerEntry.id,
            generatedAt: plannedAt
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
            receiptRecord: receiptRecord,
            runtimeLineage: runtimeLineage
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
            occurredAt: plannedAt,
            runtimeLineage: runtimeLineage
        )

        return InspectionCommitPlan(
            commandRecord: input.commandRecord,
            runtimeEventEnvelope: input.runtimeEventEnvelope,
            runtimeCommitReceipt: input.runtimeCommitReceipt,
            runtimeLineage: runtimeLineage,
            eventLedgerEntry: eventLedgerEntry,
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofLedgerEntry,
            proofLedger: proofLedger,
            sourceRecordLedger: sourceRecordLedger,
            undoLedger: undoLedger,
            auditTrail: auditTrail,
            historyProjection: historyProjection,
            replayOutcome: replayOutcome
        )
    }

    private func validate(_ input: InspectionCommitInput) throws {
        guard input.runtimeEvent.commandID == input.commandRecord.commandID else {
            throw InspectionCommitError.commandMismatch(
                expected: input.commandRecord.commandID,
                actual: input.runtimeEvent.commandID
            )
        }
        guard input.runtimeCommitReceipt.hasReplayableProof else {
            throw InspectionCommitError.runtimeCommitReceiptNotReplayable(input.runtimeCommitReceipt.id)
        }
        guard input.runtimeCommitReceipt.localOnly else {
            throw InspectionCommitError.nonLocalInput("runtime commit receipt")
        }
        guard input.runtimeCommitReceipt.commandID == input.commandRecord.commandID else {
            throw InspectionCommitError.runtimeCommitReceiptCommandMismatch(
                expected: input.commandRecord.commandID,
                actual: input.runtimeCommitReceipt.commandID
            )
        }
        guard input.runtimeCommitReceipt.eventID == input.runtimeEventEnvelope.id else {
            throw InspectionCommitError.runtimeCommitReceiptEventMismatch(
                expected: input.runtimeCommitReceipt.eventID,
                actual: input.runtimeEventEnvelope.id
            )
        }
        guard input.runtimeCommitReceipt.eventCursor == input.runtimeEventEnvelope.cursor else {
            throw InspectionCommitError.runtimeCommitReceiptCursorMismatch(
                expected: input.runtimeCommitReceipt.eventCursor,
                actual: input.runtimeEventEnvelope.cursor
            )
        }
        guard input.runtimeCommitReceipt.receiptID == input.receipt.id else {
            throw InspectionCommitError.runtimeCommitReceiptReceiptMismatch(
                expected: input.runtimeCommitReceipt.receiptID,
                actual: input.receipt.id
            )
        }
        guard input.commandRecord.localOnly else {
            throw InspectionCommitError.nonLocalInput("command record")
        }
        guard input.runtimeEvent.localOnly else {
            throw InspectionCommitError.nonLocalInput("runtime event")
        }
        guard input.receipt.affectedObjects.isEmpty == false else {
            throw InspectionCommitError.receiptMissingAffectedObject(input.receipt.id)
        }
        if let metadataReceiptID = input.commandRecord.result.metadata["receiptID"],
           metadataReceiptID != input.receipt.id {
            throw InspectionCommitError.receiptCommandMismatch(
                receiptID: input.receipt.id,
                commandID: input.commandRecord.commandID
            )
        }
    }

    private func makeEventLedgerEntry(
        input: InspectionCommitInput,
        plannedAt: String
    ) -> EventLedgerEntry {
        let runtimeLineage = RuntimeTrustLineage(runtimeCommitReceipt: input.runtimeCommitReceipt)
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
            kind: eventLedgerKind(commandPayload: input.commandRecord.command.typedPayload, runtimeKind: input.runtimeEvent.kind),
            occurredAt: input.runtimeEvent.occurredAt,
            source: eventLedgerSource(commandSource: input.commandRecord.command.source),
            goalID: input.commandRecord.command.target.goalID,
            captureID: input.commandRecord.command.target.captureID,
            planID: input.commandRecord.command.target.timeID,
            reviewID: input.commandRecord.command.target.reviewID,
            title: eventTitle(commandPayload: input.commandRecord.command.typedPayload, resultStatus: resultStatus),
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
                    summary: "\(input.commandRecord.command.typedPayload.diagnosticFamily).\(input.commandRecord.command.typedPayload.diagnosticCase)"
                )
            ],
            metadata: [
                "commandID": input.commandRecord.commandID,
                "commandRecordID": input.commandRecord.id,
                "runtimeEventKind": input.runtimeEvent.kind.rawValue,
                "receiptID": input.receipt.id,
                "plannedAt": plannedAt,
            ].merging(runtimeLineage.metadata) { _, new in new },
            payload: input.runtimeEvent.metadata
                .merging(input.commandRecord.result.metadata) { _, new in new }
                .merging(runtimeLineage.metadata) { _, new in new },
            privacy: input.runtimeEvent.privacy,
            localOnly: input.runtimeEvent.localOnly,
            createdAt: plannedAt,
            updatedAt: plannedAt
        )
    }

    private func makeSourceRecords(
        input: InspectionCommitInput,
        eventLedgerEntry: EventLedgerEntry,
        receiptRecord: ActionReceiptHistoryRecord,
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        plannedAt: String
    ) -> [SourceRecordLedgerRecord] {
        var records = [
            SourceRecordLedgerRecord.command(input.commandRecord),
            SourceRecordLedgerRecord.runtimeEvent(
                eventLedgerEntry,
                commandID: input.commandRecord.commandID,
                runtimeLineage: receiptRecord.runtimeLineage
            ),
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

    private func eventLedgerKind(commandPayload: RuntimeCommandPayload, runtimeKind: RuntimeEventKind) -> EventLedgerKind {
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
        case .domainMutation:
            if case let .capture(value) = commandPayload, case .quickCapture = value.action { return .captureCreated }
            if case .schedule = commandPayload { return .itemScheduled }
            return .userCorrectionAdded
        case .commandExecution:
            switch commandPayload {
            case let .capture(value):
                switch value.action {
                case .quickCapture: return .captureCreated
                case .attachToGoal: return .captureAttachedToGoal
                case .routeCommitment: return .commitmentRouted
                case .markWaiting: return .actionDelayed
                case .archive: return .goalArchived
                }
            case let .goal(value):
                switch value.action {
                case .create: return .goalCreated
                case .update: return .goalUpdated
                case .setPriority: return .priorityChanged
                case .setUrgency: return .urgencyChanged
                case .setDeadline: return .deadlineChanged
                case .addDeliverable: return .deliverableAdded
                case .removeDeliverable: return .deliverableRemoved
                case .addScopeItem: return .goalScopeItemAdded
                case .removeScopeItem: return .goalScopeItemRemoved
                case .setContextLens, .clearContextLens: return .planUpdated
                }
            case let .step(value):
                switch value.action {
                case .complete: return .actionCompleted
                case .delay: return .actionDelayed
                case .split: return .actionSplit
                case .recover: return .recoveryAccepted
                case .todayGoalStep: return .actionCompleted
                case .startSession: return .planUpdated
                }
            case .schedule, .externalOperation: return .itemScheduled
            case .profile: return .contextLensChanged
            case let .history(value):
                if case .dismissRecommendation = value.action { return .recommendationDismissed }
                return .planUpdated
            case let .importDeletion(value):
                switch value.action {
                case .deleteObject, .forgetMemory: return .goalArchived
                case .prepareExport, .performExport: return .planUpdated
                }
            case .reminder, .repair: return .planUpdated
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

    private func eventTitle(commandPayload: RuntimeCommandPayload, resultStatus: AmbitionsCommandExecutionStatus) -> String {
        if resultStatus == .failed || resultStatus == .blocked {
            return "Command failed safely"
        }
        switch commandPayload {
        case let .capture(value):
            if case .quickCapture = value.action { return "Capture saved" }
            return "Capture updated"
        case let .goal(value) where value.action == .create: return "Goal created"
        case let .step(value):
            if case .complete = value.action { return "Step completed" }
            return "Step command recorded"
        case .profile: return "Preferences updated"
        case .schedule: return "Time updated"
        default: return "Command recorded"
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

actor InspectionRecorder {
    let eventLedger: any EventLedgerRepository
    let actionReceiptHistory: any ActionReceiptHistoryRepository
    let planner: InspectionCommitPlanner

    init(
        eventLedger: any EventLedgerRepository,
        actionReceiptHistory: any ActionReceiptHistoryRepository,
        planner: InspectionCommitPlanner = InspectionCommitPlanner()
    ) {
        self.eventLedger = eventLedger
        self.actionReceiptHistory = actionReceiptHistory
        self.planner = planner
    }

    func record(
        _ input: InspectionCommitInput,
        recordedAt: String
    ) async throws -> InspectionCommitPlan {
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
