import Foundation

extension DefaultCaptureService {
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

struct CaptureClassification {
    let kind: CaptureKind
    let route: CaptureRoute
    let triageStatus: CaptureTriageStatus
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let assumptionSummary: String
}

enum CaptureClassifier {
    static func classify(
        text: String,
        requestedKind: CaptureKind?,
        requestedRoute: CaptureRoute?,
        deadlineText: String?,
        contextLensHint: NowContextLens?,
        priorityHints: CapturePriorityHints
    ) -> CaptureClassification {
        let lowercased = text.lowercased()
        let inferredDeadline = deadlineText ?? deadlinePhrase(in: lowercased, original: text)
        let hasDeadline = inferredDeadline != nil || lowercased.contains(" by ") || lowercased.contains("before ")
        let looksWaiting = lowercased.contains("waiting on") || lowercased.contains("blocked by") || lowercased.contains("follow up")
        let looksOptional = lowercased.contains("someday") || lowercased.contains("maybe") || lowercased.contains("optional")
        let looksDeliverable = lowercased.contains("add another") || lowercased.contains("deliverable") || lowercased.contains("song")
        let looksCommitment = lowercased.contains("send") || lowercased.contains("create") || lowercased.contains("finish") || lowercased.contains("call") || lowercased.contains("email")
        let inferredKind: CaptureKind
        let inferredRoute: CaptureRoute

        if let requestedKind {
            inferredKind = requestedKind
            inferredRoute = requestedRoute ?? route(for: requestedKind)
        } else if looksWaiting {
            inferredKind = .waitingItem
            inferredRoute = .waiting
        } else if looksOptional {
            inferredKind = .optionalSomeday
            inferredRoute = .optionalSomeday
        } else if looksDeliverable {
            inferredKind = .deliverableSeed
            inferredRoute = .deliverableSeed
        } else if hasDeadline, looksCommitment {
            inferredKind = .oneTimeCommitment
            inferredRoute = .timeSeed
        } else if hasDeadline {
            inferredKind = .deadlineTask
            inferredRoute = .timeSeed
        } else if looksCommitment {
            inferredKind = .oneTimeCommitment
            inferredRoute = .timeSeed
        } else {
            inferredKind = .raw
            inferredRoute = .captureInbox
        }

        let route = requestedRoute ?? inferredRoute
        let context = contextLensHint ?? (lowercased.contains("spreadsheet") || lowercased.contains("kaylee") || lowercased.contains("client") ? .work : nil)
        let deadlineLevel: NowPressureLevel? = hasDeadline ? .high : priorityHints.deadline
        let mergedHints = CapturePriorityHints(
            importance: priorityHints.importance,
            urgency: priorityHints.urgency ?? (hasDeadline ? .elevated : nil),
            consequence: priorityHints.consequence,
            deadline: deadlineLevel,
            effort: priorityHints.effort,
            contextFit: priorityHints.contextFit,
            optionalSomeday: inferredKind == .optionalSomeday || priorityHints.optionalSomeday,
            passive: inferredKind == .optionalSomeday || priorityHints.passive,
            goalSupporting: inferredKind == .goalSupportingTask || priorityHints.goalSupporting
        )

        return CaptureClassification(
            kind: inferredKind,
            route: route,
            triageStatus: inferredKind == .raw ? .needsTriage : .assumedRoute,
            commitmentKind: commitmentKind(for: inferredKind),
            deadlineText: inferredDeadline,
            deadlineKind: hasDeadline ? .hard : .none,
            contextLensHint: context,
            priorityHints: mergedHints,
            assumptionSummary: assumption(for: inferredKind)
        )
    }

    static func route(for kind: CaptureKind) -> CaptureRoute {
        switch kind {
        case .raw: .captureInbox
        case .oneTimeCommitment, .deadlineTask: .timeSeed
        case .goalSeed: .goalSeed
        case .goalSupportingTask: .goalAttachment
        case .deliverableSeed: .deliverableSeed
        case .waitingItem: .waiting
        case .optionalSomeday: .optionalSomeday
        case .archiveItem: .archive
        }
    }

    static func commitmentKind(for kind: CaptureKind) -> NowCommitmentKind? {
        switch kind {
        case .oneTimeCommitment, .deadlineTask: .oneTime
        case .goalSupportingTask: .goalSupporting
        case .waitingItem: .waiting
        case .optionalSomeday: .optionalSomeday
        case .raw, .goalSeed, .deliverableSeed, .archiveItem: nil
        }
    }

    static func assumption(for kind: CaptureKind) -> String {
        switch kind {
        case .raw: "I left this as a raw capture because the route was not obvious."
        case .oneTimeCommitment: "I treated this as a one-time commitment."
        case .deadlineTask: "I treated this as deadline-bound work."
        case .goalSeed: "I kept this as a possible goal seed."
        case .goalSupportingTask: "I treated this as supporting a goal."
        case .deliverableSeed: "I kept this as a deliverable seed."
        case .waitingItem: "I treated this as waiting on someone or something."
        case .optionalSomeday: "I parked this as optional or someday."
        case .archiveItem: "I archived this capture."
        }
    }

    static func deadlinePhrase(in lowercased: String, original: String) -> String? {
        let markers = [" by ", " before ", " due "]
        guard let marker = markers.first(where: { lowercased.contains($0) }),
              let range = lowercased.range(of: marker) else {
            return nil
        }
        let originalIndex = original.index(original.startIndex, offsetBy: lowercased.distance(from: lowercased.startIndex, to: range.upperBound))
        let phrase = original[originalIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
        return phrase.isEmpty ? nil : phrase
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
