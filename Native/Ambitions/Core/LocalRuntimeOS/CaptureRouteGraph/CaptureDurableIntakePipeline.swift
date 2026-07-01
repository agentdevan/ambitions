import Foundation

struct CaptureDurableAttachmentInput: Sendable, Equatable {
    let clientAttachmentID: String
    let originalFilename: String
    let contentType: String
    let data: Data
    let privacy: EventLedgerPrivacyClassification

    init(
        clientAttachmentID: String? = nil,
        originalFilename: String,
        contentType: String,
        data: Data,
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.originalFilename = CaptureRouteGraphStableID.required(originalFilename)
        self.clientAttachmentID = CaptureRouteGraphStableID.optional(clientAttachmentID)
            ?? CaptureRouteGraphStableID.make(prefix: "capture-attachment.pending", components: [self.originalFilename])
        self.contentType = CaptureRouteGraphStableID.required(contentType)
        self.data = data
        self.privacy = privacy
    }
}

struct CaptureDurableIntakeRequest: Sendable, Equatable {
    let captureID: String
    let rawText: String
    let sourceType: CaptureSourceType?
    let sourceSurface: String
    let acceptedAt: String
    let commandID: String?
    let requestedKind: CaptureKind?
    let requestedRoute: CaptureRoute?
    let deadlineText: String?
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let linkedGoalID: String?
    let scopeItemHint: String?
    let proofIntent: String?
    let attachments: [CaptureDurableAttachmentInput]
    let privacy: EventLedgerPrivacyClassification

    init(
        captureID: String,
        rawText: String,
        sourceType: CaptureSourceType?,
        sourceSurface: String,
        acceptedAt: String,
        commandID: String? = nil,
        requestedKind: CaptureKind? = nil,
        requestedRoute: CaptureRoute? = nil,
        deadlineText: String? = nil,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints = CapturePriorityHints(),
        linkedGoalID: String? = nil,
        scopeItemHint: String? = nil,
        proofIntent: String? = nil,
        attachments: [CaptureDurableAttachmentInput] = [],
        privacy: EventLedgerPrivacyClassification = .privateUserText
    ) {
        self.captureID = CaptureRouteGraphStableID.required(captureID)
        self.rawText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceType = sourceType
        self.sourceSurface = CaptureRouteGraphStableID.required(sourceSurface)
        self.acceptedAt = CaptureRouteGraphStableID.required(acceptedAt)
        self.commandID = CaptureRouteGraphStableID.optional(commandID)
        self.requestedKind = requestedKind
        self.requestedRoute = requestedRoute
        self.deadlineText = CaptureRouteGraphStableID.optional(deadlineText)
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.linkedGoalID = CaptureRouteGraphStableID.optional(linkedGoalID)
        self.scopeItemHint = CaptureRouteGraphStableID.optional(scopeItemHint)
        self.proofIntent = CaptureRouteGraphStableID.optional(proofIntent)
        self.attachments = attachments
        self.privacy = privacy
    }
}

struct CaptureRouteGraphPreparation: Sendable, Equatable {
    let intakeReceipt: CaptureIntakeJournalReceipt
    let intakeRecord: CaptureIntakeJournalRecord
    let attachmentRecords: [CaptureAttachmentVaultRecord]
    let decision: CaptureRouteDecision
    let draft: CaptureDraftRecord
    let lookupEntry: CaptureDirectLookupEntry
}

struct CaptureDurableIntakePipeline: Sendable {
    let services: CaptureRouteGraphServices

    init(services: CaptureRouteGraphServices) {
        self.services = services
    }

    func prepareAcceptedInput(_ request: CaptureDurableIntakeRequest) async throws -> CaptureRouteGraphPreparation {
        let intakeReceipt = try await services.intakeJournal.append(
            CaptureIntakeJournalAppendRequest(
                captureID: request.captureID,
                rawText: request.rawText,
                sourceType: request.sourceType,
                sourceSurface: request.sourceSurface,
                receivedAt: request.acceptedAt,
                commandID: request.commandID,
                attachmentIDs: request.attachments.map(\.clientAttachmentID),
                deadlineIntent: request.deadlineText,
                goalIntent: request.linkedGoalID,
                stepIntent: request.scopeItemHint,
                proofIntent: request.proofIntent,
                privacy: request.privacy
            )
        )
        guard let intakeRecord = try await services.intakeJournal.record(id: intakeReceipt.journalRecordID) else {
            throw CaptureIntakeJournalError.missingDurableReceipt(intakeReceipt.journalRecordID)
        }

        var attachmentRecords: [CaptureAttachmentVaultRecord] = []
        for attachment in request.attachments {
            let record = try await services.attachmentVault.stage(
                CaptureAttachmentVaultStageRequest(
                    captureID: request.captureID,
                    intakeRecordID: intakeRecord.id,
                    originalFilename: attachment.originalFilename,
                    contentType: attachment.contentType,
                    data: attachment.data,
                    privacy: attachment.privacy,
                    stagedAt: request.acceptedAt
                )
            )
            attachmentRecords.append(record)
        }

        let decision = try services.routeResolver.resolve(
            CaptureRouteResolveRequest(
                intakeReceipt: intakeReceipt,
                rawText: intakeRecord.rawText,
                requestedKind: request.requestedKind,
                requestedRoute: request.requestedRoute,
                deadlineText: request.deadlineText,
                contextLensHint: request.contextLensHint,
                priorityHints: request.priorityHints,
                sourceType: intakeRecord.sourceType,
                sourceSurface: intakeRecord.sourceSurface
            )
        )
        let draft = try await services.draftStore.upsert(
            intake: intakeRecord,
            decision: decision,
            updatedAt: request.acceptedAt
        )
        let lookupEntry = try await services.directLookupIndex.index(
            intake: intakeRecord,
            draft: draft,
            decision: decision,
            updatedAt: request.acceptedAt
        )
        return CaptureRouteGraphPreparation(
            intakeReceipt: intakeReceipt,
            intakeRecord: intakeRecord,
            attachmentRecords: attachmentRecords,
            decision: decision,
            draft: draft,
            lookupEntry: lookupEntry
        )
    }
}
