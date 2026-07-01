import Foundation

extension DefaultCaptureService {
    func prepareCaptureRouteGraphDecision(
        captureID: String,
        rawText: String,
        sourceType: CaptureSourceType?,
        sourceSurface: String,
        timestamp: String,
        requestedKind: CaptureKind?,
        requestedRoute: CaptureRoute?,
        deadlineText: String?,
        contextLensHint: NowContextLens?,
        priorityHints: CapturePriorityHints,
        linkedGoalID: String?,
        scopeItemHint: String?,
        proofIntent: String?
    ) async throws -> CaptureRouteGraphPreparation {
        try await captureRouteGraph.durableIntakePipeline().prepareAcceptedInput(
            CaptureDurableIntakeRequest(
                captureID: captureID,
                rawText: rawText,
                sourceType: sourceType,
                sourceSurface: sourceSurface,
                acceptedAt: timestamp,
                requestedKind: requestedKind,
                requestedRoute: requestedRoute,
                deadlineText: deadlineText,
                contextLensHint: contextLensHint,
                priorityHints: priorityHints,
                linkedGoalID: linkedGoalID,
                scopeItemHint: scopeItemHint,
                proofIntent: proofIntent,
                privacy: .privateUserText
            )
        )
    }

    func durableIntakeReceipt(for capture: Capture, now: Date) async throws -> CaptureIntakeJournalReceipt {
        if let record = try await captureRouteGraph.intakeJournal.latestRecord(captureID: capture.id) {
            return CaptureIntakeJournalReceipt(record: record, acknowledgedAfterDurableWrite: true)
        }
        return try await captureRouteGraph.intakeJournal.append(
            CaptureIntakeJournalAppendRequest(
                captureID: capture.id,
                rawText: capture.rawText,
                sourceType: capture.sourceType,
                sourceSurface: sourceSurface(for: capture.sourceType),
                receivedAt: DomainTimestamp.string(from: now),
                deadlineIntent: capture.deadlineText,
                goalIntent: capture.linkedGoalID ?? capture.goalRelationship?.goalID,
                stepIntent: capture.scopeItemHint,
                proofIntent: capture.route == .proofItem || capture.route == .goalAttachment ? capture.rawText : nil,
                privacy: capture.privacy
            )
        )
    }

    func recordRouteCorrection(
        from existing: Capture,
        to updated: Capture,
        request: CaptureRouteUpdateRequest,
        occurredAt: String
    ) async throws {
        let lookupEntry = try await captureRouteGraph.directLookupIndex.updateRoute(
            captureID: updated.id,
            route: updated.route,
            kind: updated.kind,
            updatedAt: occurredAt
        )
        _ = try await captureRouteGraph.correctionLedger.append(
            CaptureCorrectionLedgerRequest(
                captureID: updated.id,
                previousRoute: existing.route,
                correctedRoute: updated.route,
                previousKind: existing.kind,
                correctedKind: updated.kind,
                reason: request.assumptionSummary ?? "User corrected capture route.",
                occurredAt: occurredAt,
                intakeRecordID: lookupEntry?.intakeRecordID,
                decisionID: lookupEntry?.decisionID,
                privacy: updated.privacy
            )
        )
    }

    func preparePromotionTransaction(
        intakeReceipt: CaptureIntakeJournalReceipt,
        captureID: String,
        destination: CapturePromotionDestination,
        targetObjectIDs: [String],
        occurredAt: String,
        summary: String,
        privacy: EventLedgerPrivacyClassification
    ) async throws {
        _ = try await captureRouteGraph.promotionTransaction.prepare(
            CapturePromotionTransactionRequest(
                intakeReceipt: intakeReceipt,
                captureID: captureID,
                destination: destination,
                targetObjectIDs: targetObjectIDs,
                occurredAt: occurredAt,
                summary: summary,
                privacy: privacy
            )
        )
    }

    func sourceSurface(for sourceType: CaptureSourceType?) -> String {
        sourceType?.title ?? "Capture"
    }

    func createStepIfNeeded(
        captureID: String,
        rawText: String,
        summary: String?,
        route: CaptureRoute,
        now: Date
    ) async throws -> CaptureStepRoutingResult? {
        guard route == .timeSeed,
              let simpleStepLifecycleService else {
            return nil
        }

        let result = try await simpleStepLifecycleService.createSimpleStep(
            title: rawText,
            summary: summary,
            now: now
        )
        return CaptureStepRoutingResult(
            captureID: captureID,
            goalID: result.goalID,
            stepID: result.stepID,
            stepTitle: result.step.title
        )
    }

    func capture(
        from existing: Capture,
        status: CaptureStatus,
        linkedGoalID: String?,
        triage: CaptureTriageMetadata?,
        revisitAfter: String?,
        kind: CaptureKind,
        route: CaptureRoute,
        triageStatus: CaptureTriageStatus,
        commitmentKind: NowCommitmentKind?,
        deadlineText: String?,
        deadlineKind: CaptureDeadlineKind,
        contextLensHint: NowContextLens?,
        priorityHints: CapturePriorityHints,
        goalRelationship: CaptureGoalRelationship?,
        deliverableHint: String?,
        scopeItemHint: String?,
        waitingMetadata: CaptureWaitingMetadata?,
        assumptionSummary: String?,
        correctionActions: [CaptureCorrectionAction],
        recommendationExplanationIDs: [String],
        now: Date
    ) -> Capture {
        Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: status,
            linkedGoalID: linkedGoalID,
            triage: triage,
            revisitAfter: revisitAfter,
            kind: kind,
            route: route,
            triageStatus: triageStatus,
            commitmentKind: commitmentKind,
            deadlineText: deadlineText,
            deadlineKind: deadlineKind,
            contextLensHint: contextLensHint,
            priorityHints: priorityHints,
            goalRelationship: goalRelationship,
            deliverableHint: deliverableHint,
            scopeItemHint: scopeItemHint,
            waitingMetadata: waitingMetadata,
            assumptionSummary: assumptionSummary,
            correctionActions: correctionActions,
            recommendationExplanationIDs: recommendationExplanationIDs,
            localOnly: existing.localOnly,
            privacy: existing.privacy
        )
    }

    func status(for route: CaptureRoute, kind: CaptureKind) -> CaptureStatus {
        switch route {
        case .captureInbox:
            kind == .raw ? .needsTriage : .actionable
        case .timeSeed:
            .scheduled
        case .goalSeed:
            .seed
        case .goalAttachment:
            .goalBound
        case .deliverableSeed:
            .seed
        case .proofItem, .constraintItem:
            .seed
        case .waiting:
            .waiting
        case .optionalSomeday:
            .optionalSomeday
        case .archive:
            .archived
        }
    }

    func commitmentKind(for kind: CaptureKind) -> NowCommitmentKind? {
        switch kind {
        case .oneTimeCommitment, .deadlineTask:
            .oneTime
        case .goalSupportingTask:
            .goalSupporting
        case .waitingItem:
            .waiting
        case .optionalSomeday:
            .optionalSomeday
        case .raw, .goalSeed, .deliverableSeed, .archiveItem:
            nil
        }
    }

    func assumption(for kind: CaptureKind, route: CaptureRoute) -> String {
        switch kind {
        case .raw:
            "I left this in Capture because I could not safely classify it."
        case .oneTimeCommitment:
            "I treated this as a one-time commitment."
        case .deadlineTask:
            "I treated this as deadline-bound."
        case .goalSeed:
            "I kept this as a possible goal seed."
        case .goalSupportingTask:
            "I treated this as goal-supporting."
        case .deliverableSeed:
            "I kept this as a deliverable seed."
        case .waitingItem:
            "I marked this as waiting."
        case .optionalSomeday:
            "I parked this as optional or someday."
        case .archiveItem:
            "I archived this item."
        }
    }

    func appendUpdateEvents(from existing: Capture, to updated: Capture, occurredAt: String) async throws {
        if existing.status != updated.status || existing.route != updated.route || existing.kind != updated.kind {
            try await appendCaptureEvent(updated.status == .archived ? .captureArchived : .captureTriaged, capture: updated, occurredAt: occurredAt)
        }
        if existing.deadlineText != updated.deadlineText || existing.deadlineKind != updated.deadlineKind {
            try await appendCaptureEvent(.deadlineChanged, capture: updated, occurredAt: occurredAt)
        }
        if existing.priorityHints.importance != updated.priorityHints.importance {
            try await appendCaptureEvent(.priorityChanged, capture: updated, occurredAt: occurredAt)
        }
        if existing.priorityHints.urgency != updated.priorityHints.urgency {
            try await appendCaptureEvent(.urgencyChanged, capture: updated, occurredAt: occurredAt)
        }
    }

    func appendCaptureEvent(_ kind: EventLedgerKind, capture: Capture, occurredAt: String) async throws {
        guard let eventLedger else { return }
        try await eventLedger.append(
            EventLedgerEntry(
                id: "ledger.capture.\(capture.id).\(kind.rawValue).\(occurredAt)",
                kind: kind,
                occurredAt: occurredAt,
                source: .capture,
                goalID: capture.linkedGoalID,
                captureID: capture.id,
                title: title(for: kind),
                summary: capture.assumptionSummary,
                semanticState: capture.route.rawValue,
                tone: tone(for: kind),
                trust: EventLedgerTrustMetadata(isUserConfirmed: capture.triageStatus == .userCorrected || capture.triageStatus == .routed),
                evidenceReferences: [
                    EventLedgerEvidenceReference(id: capture.id, kind: .capture, occurredAt: capture.updatedAt, summary: capture.kind.rawValue)
                ],
                metadata: [
                    "captureKind": capture.kind.rawValue,
                    "captureRoute": capture.route.rawValue,
                    "triageStatus": capture.triageStatus.rawValue
                ],
                payload: [
                    "deadlineText": capture.deadlineText ?? "",
                    "contextLens": capture.contextLensHint?.rawValue ?? "",
                    "commitmentKind": capture.commitmentKind?.rawValue ?? ""
                ].filter { $0.value.isEmpty == false },
                privacy: capture.privacy
            )
        )
    }

    func title(for kind: EventLedgerKind) -> String {
        switch kind {
        case .captureCreated: "Capture created"
        case .captureTriaged: "Capture triaged"
        case .captureAttachedToGoal: "Capture attached to goal"
        case .captureArchived: "Capture archived"
        case .commitmentCaptured: "Commitment captured"
        case .commitmentRouted: "Commitment routed"
        case .deadlineChanged: "Deadline changed"
        case .priorityChanged: "Priority changed"
        case .urgencyChanged: "Urgency changed"
        case .userCorrectionAdded: "Capture correction recorded"
        default: "Capture event"
        }
    }

    func tone(for kind: EventLedgerKind) -> EventLedgerTone {
        switch kind {
        case .captureArchived:
            .neutral
        case .userCorrectionAdded:
            .correction
        case .captureAttachedToGoal, .commitmentRouted:
            .positive
        default:
            .neutral
        }
    }
}

enum CaptureServiceError: LocalizedError {
    case emptyRawText
    case invalidTransition(from: CaptureStatus, to: CaptureStatus)
    case missingGoalRepository
    case missingGoalsService
    case goalNotFound
    case goalCreationDidNotReturnGoal

    var errorDescription: String? {
        switch self {
        case .emptyRawText:
            return "Capture text cannot be empty."
        case let .invalidTransition(from, to):
            return "Capture cannot move from \(from.title) to \(to.title)."
        case .missingGoalRepository:
            return "Capture goal attachment is unavailable."
        case .missingGoalsService:
            return "Capture goal creation is unavailable."
        case .goalNotFound:
            return "The selected goal could not be found."
        case .goalCreationDidNotReturnGoal:
            return "The created goal could not be opened."
        }
    }
}
