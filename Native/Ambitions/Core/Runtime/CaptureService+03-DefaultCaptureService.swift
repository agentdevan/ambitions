import Foundation

struct DefaultCaptureService: CaptureServicing {
    let repository: any CaptureRepository
    let goalRepository: (any GoalRepository)?
    let goalsService: (any GoalsServicing)?
    let goalCreationPreparer: (any GoalCreationPreparing)?
    let capturePromotionUnitOfWork: (any CapturePromotionUnitOfWorking)?
    let eventLedger: (any EventLedgerRepository)?
    let simpleStepLifecycleService: SimpleStepLifecycleService?
    let idProvider: @Sendable () -> String

    init(
        repository: any CaptureRepository,
        goalRepository: (any GoalRepository)? = nil,
        goalsService: (any GoalsServicing)? = nil,
        goalCreationPreparer: (any GoalCreationPreparing)? = nil,
        capturePromotionUnitOfWork: (any CapturePromotionUnitOfWorking)? = nil,
        eventLedger: (any EventLedgerRepository)? = nil,
        simpleStepLifecycleService: SimpleStepLifecycleService? = nil,
        idProvider: @escaping @Sendable () -> String = { DomainIdentifier.prefixed("capture") }
    ) {
        self.repository = repository
        self.goalRepository = goalRepository
        self.goalsService = goalsService
        self.goalCreationPreparer = goalCreationPreparer
        self.capturePromotionUnitOfWork = capturePromotionUnitOfWork
        self.eventLedger = eventLedger
        self.simpleStepLifecycleService = simpleStepLifecycleService
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
        let captureID = idProvider()
        let stepRouting: CaptureStepRoutingResult?
        if request.linkedGoalID == nil, request.goalRelationship?.goalID == nil {
            stepRouting = try await createStepIfNeeded(
                captureID: captureID,
                rawText: trimmed,
                summary: request.assumptionSummary ?? classification.assumptionSummary,
                route: classification.route,
                now: now
            )
        } else {
            stepRouting = nil
        }
        let capture = Capture(
            id: captureID,
            createdAt: timestamp,
            updatedAt: timestamp,
            rawText: trimmed,
            sourceType: request.sourceType,
            status: status(for: classification.route, kind: classification.kind),
            linkedGoalID: request.linkedGoalID ?? stepRouting?.goalID,
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
            goalRelationship: request.goalRelationship ?? stepRouting.map { CaptureGoalRelationship(goalID: $0.goalID, relationshipKind: .nextAction, note: "Created local Step \($0.stepID).") },
            deliverableHint: request.deliverableHint,
            scopeItemHint: request.scopeItemHint,
            waitingMetadata: request.waitingMetadata,
            assumptionSummary: stepRouting.map { "Saved locally as Step: \($0.stepTitle)." } ?? request.assumptionSummary ?? classification.assumptionSummary,
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
        if request.route == .timeSeed {
            try await appendCaptureEvent(.commitmentRouted, capture: updated, occurredAt: timestamp)
        }
        return updated
    }

    func markAsOneTimeCommitment(id: String, deadlineText: String?, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .oneTimeCommitment, route: .timeSeed, deadlineText: deadlineText, contextLensHint: contextLensHint, assumptionSummary: "I treated this as a one-time commitment."), now: now)
    }

    func markAsDeadlineTask(id: String, deadlineText: String, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .deadlineTask, route: .timeSeed, deadlineText: deadlineText, contextLensHint: contextLensHint, priorityHints: CapturePriorityHints(urgency: .elevated, deadline: .high), assumptionSummary: "I treated this as deadline-bound work."), now: now)
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
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .oneTimeCommitment, route: .timeSeed, assumptionSummary: "I routed this as a Time idea. Scheduling is still deferred to Time."), now: now)
    }

    func routeToTimeSeed(id: String, now: Date) async throws -> Capture? {
        guard let existing = try await repository.capture(id: id) else {
            return nil
        }
        let stepRouting: CaptureStepRoutingResult?
        if existing.linkedGoalID == nil {
            stepRouting = try await createStepIfNeeded(
                captureID: existing.id,
                rawText: existing.rawText,
                summary: "Created from Capture and saved as a local Step.",
                route: .timeSeed,
                now: now
            )
        } else {
            stepRouting = nil
        }
        return try await updateCaptureRoute(
            CaptureRouteUpdateRequest(
                id: id,
                kind: .oneTimeCommitment,
                route: .timeSeed,
                goalRelationship: stepRouting.map { CaptureGoalRelationship(goalID: $0.goalID, relationshipKind: .nextAction, note: "Created local Step \($0.stepID).") },
                assumptionSummary: stepRouting.map { "Saved locally as Step: \($0.stepTitle)." } ?? "I routed this as a Time idea. Scheduling is still deferred to Time."
            ),
            now: now
        )
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

        let createRequest = CreateGoalRequest(title: existing.rawText, mode: request.mode)

        if let goalCreationPreparer,
           let capturePromotionUnitOfWork {
            let prepared = try await goalCreationPreparer.prepareGoalCreation(createRequest, now: now)
            guard let goal = prepared.goal,
                  let goalID = prepared.response.target.goalID else {
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
            let result = try await capturePromotionUnitOfWork.saveCapturePromotion(
                CapturePromotionUnitOfWorkPayload(goal: goal, draft: prepared.draft, capture: updated),
                id: "capture-promotion.\(existing.id).\(goalID).\(prepared.draft.id)",
                timestampProvider: { DomainTimestamp.string(from: now) }
            )
            try await appendCaptureEvent(.captureTriaged, capture: updated, occurredAt: DomainTimestamp.string(from: now))
            await goalCreationPreparer.didCommitPreparedGoalCreation(now: now)
            return CaptureGoalBinding(capture: updated, target: prepared.response.target, unitOfWorkReceipt: result.receipt)
        }

        let response = try await goalsService.createGoal(createRequest, now: now)
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
        return CaptureGoalBinding(capture: updated, target: response.target, unitOfWorkReceipt: response.unitOfWorkReceipt)
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
