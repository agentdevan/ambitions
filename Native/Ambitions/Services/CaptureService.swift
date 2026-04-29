import Foundation

struct CreateCaptureRequest: Sendable, Equatable {
    let rawText: String
    let sourceType: CaptureSourceType?
    let linkedGoalID: String?
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?
    let kind: CaptureKind?
    let route: CaptureRoute?
    let triageStatus: CaptureTriageStatus?
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let recommendationExplanationIDs: [String]

    init(
        rawText: String,
        sourceType: CaptureSourceType? = nil,
        linkedGoalID: String? = nil,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil,
        kind: CaptureKind? = nil,
        route: CaptureRoute? = nil,
        triageStatus: CaptureTriageStatus? = nil,
        commitmentKind: NowCommitmentKind? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind = .none,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints = CapturePriorityHints(),
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        recommendationExplanationIDs: [String] = []
    ) {
        self.rawText = rawText
        self.sourceType = sourceType
        self.linkedGoalID = linkedGoalID
        self.triage = triage
        self.revisitAfter = revisitAfter
        self.kind = kind
        self.route = route
        self.triageStatus = triageStatus
        self.commitmentKind = commitmentKind
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.recommendationExplanationIDs = recommendationExplanationIDs
    }
}

struct CaptureStateUpdateRequest: Sendable, Equatable {
    let id: String
    let status: CaptureStatus
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?
    let kind: CaptureKind?
    let route: CaptureRoute?
    let triageStatus: CaptureTriageStatus?
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind?
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints?
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let correctionActions: [CaptureCorrectionAction]?
    let recommendationExplanationIDs: [String]?

    init(
        id: String,
        status: CaptureStatus,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil,
        kind: CaptureKind? = nil,
        route: CaptureRoute? = nil,
        triageStatus: CaptureTriageStatus? = nil,
        commitmentKind: NowCommitmentKind? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind? = nil,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints? = nil,
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        correctionActions: [CaptureCorrectionAction]? = nil,
        recommendationExplanationIDs: [String]? = nil
    ) {
        self.id = id
        self.status = status
        self.triage = triage
        self.revisitAfter = revisitAfter
        self.kind = kind
        self.route = route
        self.triageStatus = triageStatus
        self.commitmentKind = commitmentKind
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.correctionActions = correctionActions
        self.recommendationExplanationIDs = recommendationExplanationIDs
    }
}

struct CaptureRouteUpdateRequest: Sendable, Equatable {
    let id: String
    let kind: CaptureKind
    let route: CaptureRoute
    let deadlineText: String?
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints?
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let userCorrection: Bool

    init(
        id: String,
        kind: CaptureKind,
        route: CaptureRoute,
        deadlineText: String? = nil,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints? = nil,
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        userCorrection: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.route = route
        self.deadlineText = deadlineText
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.userCorrection = userCorrection
    }
}

struct AttachCaptureToGoalRequest: Sendable, Equatable {
    let captureID: String
    let goalID: String

    init(captureID: String, goalID: String) {
        self.captureID = captureID
        self.goalID = goalID
    }
}

struct TurnCaptureIntoGoalRequest: Sendable, Equatable {
    let captureID: String
    let mode: GoalMode?

    init(captureID: String, mode: GoalMode? = nil) {
        self.captureID = captureID
        self.mode = mode
    }
}

struct CaptureGoalBinding: Sendable, Equatable {
    let capture: Capture
    let target: GoalRouteTarget
}

struct DefaultCaptureService: CaptureServicing {
    private let repository: any CaptureRepository
    private let goalRepository: (any GoalRepository)?
    private let goalsService: (any GoalsServicing)?
    private let eventLedger: (any EventLedgerRepository)?
    private let idProvider: @Sendable () -> String

    init(
        repository: any CaptureRepository,
        goalRepository: (any GoalRepository)? = nil,
        goalsService: (any GoalsServicing)? = nil,
        eventLedger: (any EventLedgerRepository)? = nil,
        idProvider: @escaping @Sendable () -> String = { DomainIdentifier.prefixed("capture") }
    ) {
        self.repository = repository
        self.goalRepository = goalRepository
        self.goalsService = goalsService
        self.eventLedger = eventLedger
        self.idProvider = idProvider
    }

    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        let trimmed = request.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw CaptureServiceError.emptyRawText
        }

        let timestamp = DomainTimestamp.string(from: now)
        let classification = CaptureClassifier.classify(
            text: trimmed,
            requestedKind: request.kind,
            requestedRoute: request.route,
            deadlineText: request.deadlineText,
            contextLensHint: request.contextLensHint,
            priorityHints: request.priorityHints
        )
        let capture = Capture(
            id: idProvider(),
            createdAt: timestamp,
            updatedAt: timestamp,
            rawText: trimmed,
            sourceType: request.sourceType,
            status: status(for: classification.route, kind: classification.kind),
            linkedGoalID: request.linkedGoalID,
            triage: request.triage ?? CaptureTriageMetadata(destination: classification.route.triageDestination, hint: classification.assumptionSummary),
            revisitAfter: request.revisitAfter,
            kind: classification.kind,
            route: classification.route,
            triageStatus: classification.triageStatus,
            commitmentKind: request.commitmentKind ?? classification.commitmentKind,
            deadlineText: request.deadlineText ?? classification.deadlineText,
            deadlineKind: request.deadlineKind == .none ? classification.deadlineKind : request.deadlineKind,
            contextLensHint: request.contextLensHint ?? classification.contextLensHint,
            priorityHints: classification.priorityHints,
            goalRelationship: request.goalRelationship,
            deliverableHint: request.deliverableHint,
            scopeItemHint: request.scopeItemHint,
            waitingMetadata: request.waitingMetadata,
            assumptionSummary: request.assumptionSummary ?? classification.assumptionSummary,
            recommendationExplanationIDs: request.recommendationExplanationIDs
        )
        try await repository.saveCaptures([capture])
        try await appendCaptureEvent(.captureCreated, capture: capture, occurredAt: timestamp)
        if capture.commitmentKind != nil {
            try await appendCaptureEvent(.commitmentCaptured, capture: capture, occurredAt: timestamp)
        }
        return capture
    }

    func listCaptures() async throws -> [Capture] {
        try await repository.listCaptures()
    }

    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        guard let existing = try await repository.capture(id: request.id) else {
            return nil
        }
        guard existing.status.canTransition(to: request.status) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: request.status)
        }

        let updated = capture(
            from: existing,
            status: request.status,
            linkedGoalID: existing.linkedGoalID,
            triage: request.triage ?? existing.triage,
            revisitAfter: request.revisitAfter ?? existing.revisitAfter,
            kind: request.kind ?? existing.kind,
            route: request.route ?? existing.route,
            triageStatus: request.triageStatus ?? existing.triageStatus,
            commitmentKind: request.commitmentKind ?? existing.commitmentKind,
            deadlineText: request.deadlineText ?? existing.deadlineText,
            deadlineKind: request.deadlineKind ?? existing.deadlineKind,
            contextLensHint: request.contextLensHint ?? existing.contextLensHint,
            priorityHints: request.priorityHints ?? existing.priorityHints,
            goalRelationship: request.goalRelationship ?? existing.goalRelationship,
            deliverableHint: request.deliverableHint ?? existing.deliverableHint,
            scopeItemHint: request.scopeItemHint ?? existing.scopeItemHint,
            waitingMetadata: request.waitingMetadata ?? existing.waitingMetadata,
            assumptionSummary: request.assumptionSummary ?? existing.assumptionSummary,
            correctionActions: request.correctionActions ?? existing.correctionActions,
            recommendationExplanationIDs: request.recommendationExplanationIDs ?? existing.recommendationExplanationIDs,
            now: now
        )
        try await repository.saveCaptures([updated])
        try await appendUpdateEvents(from: existing, to: updated, occurredAt: DomainTimestamp.string(from: now))
        return updated
    }

    func updateCaptureRoute(_ request: CaptureRouteUpdateRequest, now: Date) async throws -> Capture? {
        guard let existing = try await repository.capture(id: request.id) else {
            return nil
        }
        let status = status(for: request.route, kind: request.kind)
        guard existing.status.canTransition(to: status) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: status)
        }

        let updated = capture(
            from: existing,
            status: status,
            linkedGoalID: request.goalRelationship?.goalID ?? existing.linkedGoalID,
            triage: CaptureTriageMetadata(destination: request.route.triageDestination, hint: request.assumptionSummary ?? existing.assumptionSummary),
            revisitAfter: existing.revisitAfter,
            kind: request.kind,
            route: request.route,
            triageStatus: request.userCorrection ? .userCorrected : .assumedRoute,
            commitmentKind: commitmentKind(for: request.kind),
            deadlineText: request.deadlineText ?? existing.deadlineText,
            deadlineKind: request.deadlineText == nil ? existing.deadlineKind : .hard,
            contextLensHint: request.contextLensHint ?? existing.contextLensHint,
            priorityHints: request.priorityHints ?? existing.priorityHints,
            goalRelationship: request.goalRelationship ?? existing.goalRelationship,
            deliverableHint: request.deliverableHint ?? existing.deliverableHint,
            scopeItemHint: request.scopeItemHint ?? existing.scopeItemHint,
            waitingMetadata: request.waitingMetadata ?? existing.waitingMetadata,
            assumptionSummary: request.assumptionSummary ?? assumption(for: request.kind, route: request.route),
            correctionActions: existing.correctionActions,
            recommendationExplanationIDs: existing.recommendationExplanationIDs,
            now: now
        )
        try await repository.saveCaptures([updated])
        let timestamp = DomainTimestamp.string(from: now)
        try await appendCaptureEvent(.captureTriaged, capture: updated, occurredAt: timestamp)
        if request.userCorrection {
            try await appendCaptureEvent(.userCorrectionAdded, capture: updated, occurredAt: timestamp)
        }
        if request.route == .planSeed {
            try await appendCaptureEvent(.commitmentRouted, capture: updated, occurredAt: timestamp)
        }
        return updated
    }

    func markAsOneTimeCommitment(id: String, deadlineText: String?, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .oneTimeCommitment, route: .planSeed, deadlineText: deadlineText, contextLensHint: contextLensHint, assumptionSummary: "I treated this as a one-time commitment."), now: now)
    }

    func markAsDeadlineTask(id: String, deadlineText: String, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .deadlineTask, route: .planSeed, deadlineText: deadlineText, contextLensHint: contextLensHint, priorityHints: CapturePriorityHints(urgency: .elevated, deadline: .high), assumptionSummary: "I treated this as deadline-bound work."), now: now)
    }

    func markAsGoalSeed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .goalSeed, route: .goalSeed, assumptionSummary: "I kept this as a possible goal seed."), now: now)
    }

    func markAsGoalSupportingTask(id: String, goalID: String?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .goalSupportingTask, route: .goalAttachment, goalRelationship: CaptureGoalRelationship(goalID: goalID, relationshipKind: .nextAction), assumptionSummary: "I treated this as supporting an existing goal."), now: now)
    }

    func markAsDeliverableSeed(id: String, deliverableHint: String?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .deliverableSeed, route: .deliverableSeed, deliverableHint: deliverableHint, assumptionSummary: "I kept this as a deliverable seed for a future goal container."), now: now)
    }

    func markAsWaiting(id: String, waitingMetadata: CaptureWaitingMetadata?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .waitingItem, route: .waiting, waitingMetadata: waitingMetadata, assumptionSummary: "I marked this as waiting so it does not compete with active work."), now: now)
    }

    func markAsOptionalSomeday(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .optionalSomeday, route: .optionalSomeday, priorityHints: CapturePriorityHints(optionalSomeday: true, passive: true), assumptionSummary: "I parked this as optional or someday."), now: now)
    }

    func routeToPlanSeed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .oneTimeCommitment, route: .planSeed, assumptionSummary: "I routed this as a Plan idea. Scheduling is still deferred to Plan."), now: now)
    }

    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        guard let existing = try await repository.capture(id: request.captureID) else {
            return nil
        }
        guard let goalRepository else {
            throw CaptureServiceError.missingGoalRepository
        }
        guard try await goalRepository.goal(id: request.goalID) != nil else {
            throw CaptureServiceError.goalNotFound
        }
        guard existing.status.canTransition(to: .goalBound) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: .goalBound)
        }

        let updated = capture(
            from: existing,
            status: .goalBound,
            linkedGoalID: request.goalID,
            triage: CaptureTriageMetadata(destination: .attachToGoal, hint: existing.triage?.hint),
            revisitAfter: existing.revisitAfter,
            kind: .goalSupportingTask,
            route: .goalAttachment,
            triageStatus: .routed,
            commitmentKind: .goalSupporting,
            deadlineText: existing.deadlineText,
            deadlineKind: existing.deadlineKind,
            contextLensHint: existing.contextLensHint,
            priorityHints: CapturePriorityHints(
                importance: existing.priorityHints.importance,
                urgency: existing.priorityHints.urgency,
                consequence: existing.priorityHints.consequence,
                deadline: existing.priorityHints.deadline,
                effort: existing.priorityHints.effort,
                contextFit: existing.priorityHints.contextFit,
                optionalSomeday: existing.priorityHints.optionalSomeday,
                passive: existing.priorityHints.passive,
                goalSupporting: true
            ),
            goalRelationship: CaptureGoalRelationship(goalID: request.goalID, relationshipKind: .nextAction, note: existing.goalRelationship?.note),
            deliverableHint: existing.deliverableHint,
            scopeItemHint: existing.scopeItemHint,
            waitingMetadata: existing.waitingMetadata,
            assumptionSummary: "This capture is attached to an existing goal.",
            correctionActions: existing.correctionActions,
            recommendationExplanationIDs: existing.recommendationExplanationIDs,
            now: now
        )
        try await repository.saveCaptures([updated])
        try await appendCaptureEvent(.captureAttachedToGoal, capture: updated, occurredAt: DomainTimestamp.string(from: now))
        return CaptureGoalBinding(capture: updated, target: GoalRouteTarget(goalID: request.goalID, draftID: nil))
    }

    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        guard let existing = try await repository.capture(id: request.captureID) else {
            return nil
        }
        guard let goalsService else {
            throw CaptureServiceError.missingGoalsService
        }
        guard existing.status.canTransition(to: .goalBound) else {
            throw CaptureServiceError.invalidTransition(from: existing.status, to: .goalBound)
        }

        let response = try await goalsService.createGoal(
            CreateGoalRequest(title: existing.rawText, mode: request.mode),
            now: now
        )
        guard let goalID = response.target.goalID else {
            throw CaptureServiceError.goalCreationDidNotReturnGoal
        }

        let updated = capture(
            from: existing,
            status: .goalBound,
            linkedGoalID: goalID,
            triage: CaptureTriageMetadata(destination: .turnIntoGoal, hint: existing.triage?.hint),
            revisitAfter: existing.revisitAfter,
            kind: .goalSeed,
            route: .goalSeed,
            triageStatus: .routed,
            commitmentKind: existing.commitmentKind,
            deadlineText: existing.deadlineText,
            deadlineKind: existing.deadlineKind,
            contextLensHint: existing.contextLensHint,
            priorityHints: existing.priorityHints,
            goalRelationship: CaptureGoalRelationship(goalID: goalID, relationshipKind: .activeGoal),
            deliverableHint: existing.deliverableHint,
            scopeItemHint: existing.scopeItemHint,
            waitingMetadata: existing.waitingMetadata,
            assumptionSummary: "This capture became a goal through the existing goal creation flow.",
            correctionActions: existing.correctionActions,
            recommendationExplanationIDs: existing.recommendationExplanationIDs,
            now: now
        )
        try await repository.saveCaptures([updated])
        try await appendCaptureEvent(.captureTriaged, capture: updated, occurredAt: DomainTimestamp.string(from: now))
        return CaptureGoalBinding(capture: updated, target: response.target)
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(
            CaptureStateUpdateRequest(id: id, status: .goalBound),
            now: now
        )
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(
            CaptureStateUpdateRequest(
                id: id,
                status: .archived,
                kind: .archiveItem,
                route: .archive,
                triageStatus: .archived
            ),
            now: now
        )
    }
}

private extension DefaultCaptureService {
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
        case .planSeed:
            .scheduled
        case .goalSeed:
            .seed
        case .goalAttachment:
            .goalBound
        case .deliverableSeed:
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

private struct CaptureClassification {
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

private enum CaptureClassifier {
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
            inferredRoute = .planSeed
        } else if hasDeadline {
            inferredKind = .deadlineTask
            inferredRoute = .planSeed
        } else if looksCommitment {
            inferredKind = .oneTimeCommitment
            inferredRoute = .planSeed
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

    private static func route(for kind: CaptureKind) -> CaptureRoute {
        switch kind {
        case .raw: .captureInbox
        case .oneTimeCommitment, .deadlineTask: .planSeed
        case .goalSeed: .goalSeed
        case .goalSupportingTask: .goalAttachment
        case .deliverableSeed: .deliverableSeed
        case .waitingItem: .waiting
        case .optionalSomeday: .optionalSomeday
        case .archiveItem: .archive
        }
    }

    private static func commitmentKind(for kind: CaptureKind) -> NowCommitmentKind? {
        switch kind {
        case .oneTimeCommitment, .deadlineTask: .oneTime
        case .goalSupportingTask: .goalSupporting
        case .waitingItem: .waiting
        case .optionalSomeday: .optionalSomeday
        case .raw, .goalSeed, .deliverableSeed, .archiveItem: nil
        }
    }

    private static func assumption(for kind: CaptureKind) -> String {
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

    private static func deadlinePhrase(in lowercased: String, original: String) -> String? {
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
