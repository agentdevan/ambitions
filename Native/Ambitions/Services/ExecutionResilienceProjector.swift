import Foundation

protocol ExecutionResilienceAssessing: Sendable {
    func assess(_ input: ExecutionResilienceProjectionInput) -> ExecutionResilienceAssessment
    func makeExplanation(
        for assessment: ExecutionResilienceAssessment,
        option: ExecutionRecoveryOption?,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation
}

struct ExecutionResilienceProjector: ExecutionResilienceAssessing {
    func assess(_ input: ExecutionResilienceProjectionInput) -> ExecutionResilienceAssessment {
        let generatedAt = DomainTimestamp.string(from: input.generatedAt)
        let assessments = normalizedAssessments(input)
        let explanations = input.recommendationExplanations
        let disruptions = makeDisruptions(input: input, assessments: assessments)
        let protected = protectedWork(from: assessments)
        let displaced = displacedWork(from: assessments, protected: protected)
        let passive = passiveWork(from: assessments)
        let waiting = waitingOrBlockedWork(from: assessments, captures: input.captures, nowState: input.nowState)
        let options = makeOptions(
            input: input,
            assessments: assessments,
            disruptions: disruptions,
            protected: protected,
            displaced: displaced,
            passive: passive,
            waiting: waiting,
            explanations: explanations,
            generatedAt: generatedAt
        )
        let status = status(disruptions: disruptions, nowState: input.nowState)
        let recommended = recommendedOption(from: options, status: status)
        let relatedGoalIDs = assessments.compactMap(\.goalID) + protected.compactMap(\.relatedGoalID) + displaced.compactMap(\.relatedGoalID)
        let relatedCaptureIDs = assessments.compactMap(\.captureID) + input.captures.map(\.id)
        let relatedPlanIDs = assessments.compactMap(\.planID) + [input.planID].compactMap { $0 }
        let eventIDs = normalized(
            input.eventLedgerEntries.map(\.id) +
            assessments.flatMap(\.eventLedgerEntryIDs) +
            (input.realitySnapshot?.eventLedgerEntryIDs ?? []) +
            (input.nowState?.eventLedgerEntryIDs ?? [])
        )
        let explanationIDs = normalized(
            explanations.map(\.id) +
            assessments.flatMap(\.recommendationExplanationIDs) +
            options.flatMap(\.recommendationExplanationIDs) +
            (input.realitySnapshot?.recommendationExplanationIDs ?? []) +
            (input.nowState?.recommendationExplanationIDs ?? [])
        )
        let assumptions = assumptions(input: input, assessments: assessments)
        let corrections = correctionSuggestions(disruptions: disruptions, assessments: assessments)

        return ExecutionResilienceAssessment(
            id: "resilience.\(generatedAt)",
            generatedAt: generatedAt,
            relatedGoalIDs: relatedGoalIDs,
            relatedCaptureIDs: relatedCaptureIDs,
            relatedPlanIDs: relatedPlanIDs,
            relatedReviewIDs: [input.reviewID].compactMap { $0 },
            relatedBelievabilityAssessmentIDs: assessments.map(\.id),
            relatedRealitySnapshotID: input.realitySnapshot?.id ?? input.believabilitySnapshot?.relatedRealitySnapshotID,
            relatedNowStateID: input.nowState?.id,
            status: status,
            disruptions: disruptions,
            recoveryOptions: options,
            recommendedRecoveryOptionID: recommended?.id,
            smallestUsefulNextStep: smallestUsefulNextStep(from: recommended, assessments: assessments, input: input),
            protectedHighPriorityWork: protected,
            displacedLowerPriorityWork: displaced,
            passiveWorkDeferredCalmly: passive,
            waitingOrBlockedRemovedFromPressure: waiting,
            reasons: reasons(disruptions: disruptions, options: options, input: input),
            assumptions: assumptions,
            correctionSuggestions: corrections,
            eventLedgerEntryIDs: eventIDs,
            recommendationExplanationIDs: explanationIDs,
            privacy: privacy(input: input, assessments: assessments)
        )
    }

    func makeExplanation(
        for assessment: ExecutionResilienceAssessment,
        option: ExecutionRecoveryOption?,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation {
        let selected = option ?? assessment.recommendedRecoveryOption
        let evidence = explanationEvidence(for: assessment, option: selected)
        let correctionActions = assessment.correctionSuggestions.map { kind in
            RecommendationExplanationCorrectionAction(
                id: "resilience.correction.\(kind.rawValue)",
                kind: kind,
                title: correctionTitle(for: kind),
                targetFieldKey: correctionField(for: kind)
            )
        }
        return RecommendationExplanation(
            id: "explanation.resilience.\(assessment.id).\(type.rawValue)",
            type: type,
            title: explanationTitle(for: type),
            summary: selected?.summary ?? "No recovery is needed right now.",
            recommendationTitle: selected?.title ?? "Keep current plan",
            recommendationSummary: selected?.expectedEffect,
            confidence: assessment.status == .stable ? .high : .medium,
            evidence: evidence,
            assumptions: assessment.assumptions,
            userCorrectableFields: correctionActions.compactMap(\.targetFieldKey),
            correctionActions: correctionActions,
            lastUpdatedAt: assessment.generatedAt,
            source: .recovery,
            relations: RecommendationExplanationRelations(
                goalIDs: assessment.relatedGoalIDs,
                captureIDs: assessment.relatedCaptureIDs,
                planIDs: assessment.relatedPlanIDs,
                reviewIDs: assessment.relatedReviewIDs,
                eventLedgerEntryIDs: assessment.eventLedgerEntryIDs
            ),
            privacy: assessment.privacy,
            localOnly: true,
            metadata: [
                "resilienceAssessmentID": assessment.id,
                "status": assessment.status.rawValue,
                "schema": assessment.schemaVersion,
                "optionID": selected?.id ?? ""
            ].filter { $0.value.isEmpty == false }
        )
    }
}

extension ExecutionResilienceProjector {
    func nowRecoverySummary(from assessment: ExecutionResilienceAssessment) -> NowPressureSummary {
        NowPressureSummary(
            level: pressure(for: assessment.status),
            itemCount: assessment.disruptions.count,
            summary: assessment.recommendedRecoveryOption?.summary ?? "No recovery pressure is visible.",
            evidenceReferenceIDs: assessment.eventLedgerEntryIDs
        )
    }

    func nowRecoveryState(from assessment: ExecutionResilienceAssessment) -> NowRecoveryState {
        switch assessment.status {
        case .stable:
            return .stable
        case .watch:
            return .watch
        case .needsRecovery, .atRisk:
            return .needsRecovery
        case .blocked:
            return .blocked
        case .recovering:
            return .recovering
        }
    }

    func command(for option: ExecutionRecoveryOption, assessment: ExecutionResilienceAssessment, createdAt: String? = nil) -> AmbitionsCommand? {
        guard let kind = option.relatedCommandKind else { return nil }
        let destination: AmbitionsCommandDestination?
        switch option.strategy {
        case .openPlan:
            destination = .plan
        case .openGoal:
            destination = .goalDetail
        case .openCapture:
            destination = .capture
        default:
            destination = nil
        }
        let command = AmbitionsCommand(
            id: "command.resilience.\(option.id)",
            kind: kind,
            source: .system,
            target: AmbitionsCommandTarget(
                goalID: option.relatedGoalID,
                captureID: option.relatedCaptureID,
                planID: option.relatedPlanID,
                recommendationID: option.id,
                explanationID: option.relatedExplanationID,
                destination: destination
            ),
            payload: AmbitionsCommandPayload(
                title: option.title,
                notes: option.summary,
                priorityHints: AmbitionsCommandPriorityHints(recoveryState: nowRecoveryState(from: assessment)),
                explanationID: option.relatedExplanationID,
                metadata: [
                    "resilienceAssessmentID": assessment.id,
                    "recoveryOptionID": option.id,
                    "recoveryStatus": assessment.status.rawValue,
                    "recoveryStrategy": option.strategy.rawValue,
                    "requiresUserConfirmation": option.requiresUserConfirmation ? "true" : "false"
                ]
            ),
            createdAt: createdAt ?? assessment.generatedAt,
            actor: .system,
            relations: AmbitionsCommandRelations(
                goalIDs: assessment.relatedGoalIDs,
                captureIDs: assessment.relatedCaptureIDs,
                planIDs: assessment.relatedPlanIDs,
                reviewIDs: assessment.relatedReviewIDs,
                eventLedgerEntryIDs: option.eventLedgerEntryIDs,
                recommendationExplanationIDs: option.recommendationExplanationIDs
            ),
            privacy: assessment.privacy
        )
        return command.validated(as: AmbitionsCommandValidator().validate(command))
    }
}

private extension ExecutionResilienceProjector {
    func normalizedAssessments(_ input: ExecutionResilienceProjectionInput) -> [GoalBelievabilityAssessment] {
        let merged = input.believabilityAssessments + (input.believabilitySnapshot?.assessments ?? [])
        var byID: [String: GoalBelievabilityAssessment] = [:]
        for assessment in merged {
            byID[assessment.id] = assessment
        }
        return byID.values.sorted { $0.id < $1.id }
    }

    func makeDisruptions(
        input: ExecutionResilienceProjectionInput,
        assessments: [GoalBelievabilityAssessment]
    ) -> [ExecutionDisruption] {
        var disruptions: [ExecutionDisruption] = []
        for assessment in assessments {
            for signal in assessment.signals {
                guard let kind = disruptionKind(for: signal, assessment: assessment) else { continue }
                disruptions.append(
                    ExecutionDisruption(
                        id: "disruption.\(assessment.id).\(kind.rawValue)",
                        kind: kind,
                        title: title(for: kind),
                        summary: summary(for: kind, assessment: assessment),
                        severity: severity(for: kind, assessment: assessment),
                        relatedGoalID: assessment.goalID,
                        relatedCaptureID: assessment.captureID,
                        relatedPlanID: assessment.planID,
                        relatedAssessmentID: assessment.id,
                        evidenceReferenceIDs: assessment.eventLedgerEntryIDs + assessment.recommendationExplanationIDs
                    )
                )
            }
            if assessment.status == .underdefined {
                disruptions.append(underdefinedDisruption(for: assessment))
            }
            if assessment.status == .unrealistic && assessment.deadlineRisk.isDeadlineBound {
                disruptions.append(slippedDeadlineDisruption(for: assessment))
            }
        }

        if input.realitySnapshot?.availability.schedulePressure == .high || input.realitySnapshot?.availability.schedulePressure == .critical {
            disruptions.append(
                ExecutionDisruption(
                    id: "disruption.reality.overloaded_day",
                    kind: .overloadedDay,
                    title: "Day is overloaded",
                    summary: input.realitySnapshot?.availability.summary ?? "Capacity pressure is high.",
                    severity: input.realitySnapshot?.availability.schedulePressure ?? .high,
                    relatedPlanID: input.planID,
                    evidenceReferenceIDs: input.realitySnapshot?.eventLedgerEntryIDs ?? []
                )
            )
        }
        if input.realitySnapshot?.conflictSummary.calendarConflictCount ?? 0 > 0 {
            disruptions.append(
                ExecutionDisruption(
                    id: "disruption.reality.calendar_conflict",
                    kind: .calendarConflict,
                    title: "Calendar conflict",
                    summary: input.realitySnapshot?.conflictSummary.summary ?? "Calendar-derived context shows a conflict.",
                    severity: .high,
                    relatedPlanID: input.planID,
                    evidenceReferenceIDs: input.realitySnapshot?.eventLedgerEntryIDs ?? []
                )
            )
        }
        if input.nowState?.recoveryState == .recovering || input.nowState?.recoveryState == .needsRecovery {
            disruptions.append(
                ExecutionDisruption(
                    id: "disruption.now.recovery_in_progress",
                    kind: .recoveryAlreadyInProgress,
                    title: "Recovery is already in progress",
                    summary: "Now State is already carrying recovery pressure.",
                    severity: input.nowState?.recoveryState == .recovering ? .moderate : .elevated,
                    evidenceReferenceIDs: input.nowState?.eventLedgerEntryIDs ?? []
                )
            )
        }
        if input.eventLedgerEntries.contains(where: { $0.kind == .actionSkipped || $0.kind == .actionDelayed }) {
            disruptions.append(
                ExecutionDisruption(
                    id: "disruption.ledger.missed_action",
                    kind: .missedAction,
                    title: "Action slipped",
                    summary: "Recent action history shows a skipped or delayed item.",
                    severity: .elevated,
                    evidenceReferenceIDs: input.eventLedgerEntries.filter { $0.kind == .actionSkipped || $0.kind == .actionDelayed }.map(\.id)
                )
            )
        }
        return unique(disruptions)
    }

    func makeOptions(
        input: ExecutionResilienceProjectionInput,
        assessments: [GoalBelievabilityAssessment],
        disruptions: [ExecutionDisruption],
        protected: [ProtectedWorkSummary],
        displaced: [DisplacedWorkSummary],
        passive: [DisplacedWorkSummary],
        waiting: [DisplacedWorkSummary],
        explanations: [RecommendationExplanation],
        generatedAt: String
    ) -> [ExecutionRecoveryOption] {
        guard disruptions.isEmpty == false else {
            return [
                ExecutionRecoveryOption(
                    id: "option.keep.stable",
                    title: "Keep current plan",
                    summary: "No recovery pressure is visible right now.",
                    strategy: .doSmallestNextStep,
                    expectedEffect: "Keeps the current execution path stable.",
                    tradeoff: RecoveryTradeoff(summary: "No tradeoff is needed.", protectsHighPriorityWork: false, defersPassiveOrFlexibleWork: false, displacesLowerPriorityWork: false, requiresUserDecision: false),
                    urgencyBasis: "No urgent disruption detected.",
                    capacityBasis: input.realitySnapshot?.capacityEstimate.summary ?? "Baseline capacity is enough for now.",
                    requiresUserConfirmation: false,
                    relatedCommandKind: nil
                )
            ]
        }

        var options: [ExecutionRecoveryOption] = []
        if let protectedFirst = protected.first {
            options.append(
                ExecutionRecoveryOption(
                    id: "option.protect.\(protectedFirst.id)",
                    title: "Protect the deadline work",
                    summary: "\(protectedFirst.title) should stay ahead of lower-pressure work.",
                    strategy: .protectDeadlineWork,
                    expectedEffect: "Keeps high-consequence deadline work visible without scheduling automatically.",
                    tradeoff: RecoveryTradeoff(summary: "Lower-priority flexible work may wait.", protectsHighPriorityWork: true, defersPassiveOrFlexibleWork: passive.isEmpty == false, displacesLowerPriorityWork: displaced.isEmpty == false, requiresUserDecision: true),
                    urgencyBasis: protectedFirst.summary,
                    deadlineBasis: protectedFirst.deadline,
                    capacityBasis: input.realitySnapshot?.capacityEstimate.summary ?? "Uses baseline capacity because calendar/reality data may be absent.",
                    protectsHighPriorityWork: true,
                    defersPassiveOrFlexibleWork: passive.isEmpty == false,
                    relatedCommandKind: .recoverAction,
                    relatedExplanationID: explanationID(type: .whyPrioritized, explanations: explanations),
                    relatedGoalID: protectedFirst.relatedGoalID,
                    relatedCaptureID: protectedFirst.relatedCaptureID,
                    relatedPlanID: input.planID,
                    eventLedgerEntryIDs: input.eventLedgerEntries.map(\.id),
                    recommendationExplanationIDs: explanations.map(\.id)
                )
            )
        }
        if let waitingFirst = waiting.first {
            options.append(
                ExecutionRecoveryOption(
                    id: "option.waiting.\(waitingFirst.id)",
                    title: "Keep blocked work waiting",
                    summary: "\(waitingFirst.title) should not keep pressuring Today while it is waiting.",
                    strategy: .moveToWaiting,
                    expectedEffect: "Removes blocked work from urgent execution pressure until the blocker changes.",
                    tradeoff: RecoveryTradeoff(summary: "Progress waits for the dependency instead of creating false urgency.", protectsHighPriorityWork: false, defersPassiveOrFlexibleWork: false, displacesLowerPriorityWork: false, requiresUserDecision: false),
                    urgencyBasis: waitingFirst.summary,
                    capacityBasis: "Waiting work should not consume open execution capacity.",
                    protectsHighPriorityWork: false,
                    defersPassiveOrFlexibleWork: false,
                    requiresUserConfirmation: false,
                    relatedCommandKind: .markWaiting,
                    relatedExplanationID: explanationID(type: .whyDeferred, explanations: explanations),
                    relatedGoalID: waitingFirst.relatedGoalID,
                    relatedCaptureID: waitingFirst.relatedCaptureID,
                    relatedPlanID: input.planID
                )
            )
        }
        if passive.isEmpty == false {
            options.append(
                ExecutionRecoveryOption(
                    id: "option.defer.passive",
                    title: "Let passive work move slowly",
                    summary: "Passive or flexible work can stay active without crowding urgent commitments.",
                    strategy: .deferPassiveWork,
                    expectedEffect: "Protects urgent work while preserving passive goals without guilt.",
                    tradeoff: RecoveryTradeoff(summary: "Meaningful flexible work waits calmly.", protectsHighPriorityWork: protected.isEmpty == false, defersPassiveOrFlexibleWork: true, displacesLowerPriorityWork: false, requiresUserDecision: false),
                    urgencyBasis: "Passive goals have lower immediate consequence.",
                    capacityBasis: input.realitySnapshot?.capacityEstimate.summary ?? "Uses baseline capacity because calendar/reality data may be absent.",
                    protectsHighPriorityWork: protected.isEmpty == false,
                    defersPassiveOrFlexibleWork: true,
                    requiresUserConfirmation: false,
                    relatedCommandKind: .delayAction,
                    relatedExplanationID: explanationID(type: .whyDeferred, explanations: explanations),
                    relatedGoalID: passive.first?.relatedGoalID,
                    relatedCaptureID: passive.first?.relatedCaptureID,
                    relatedPlanID: input.planID
                )
            )
        }
        if disruptions.contains(where: { [.missedAction, .overloadedDay, .lowCapacity, .noOpenWindow].contains($0.kind) }) {
            let anchor = assessments.first { $0.status == .tight || $0.status == .atRisk || $0.status == .unrealistic } ?? assessments.first
            options.append(
                ExecutionRecoveryOption(
                    id: "option.smallest.\(anchor?.id ?? "baseline")",
                    title: "Do the smallest useful next step",
                    summary: "This slipped, so the recovery path should start with the smallest useful next step.",
                    strategy: .doSmallestNextStep,
                    expectedEffect: "Restarts movement without pretending the whole original plan still fits.",
                    tradeoff: RecoveryTradeoff(summary: "Scope is reduced for the next action, not for the whole goal.", protectsHighPriorityWork: protected.isEmpty == false, defersPassiveOrFlexibleWork: false, displacesLowerPriorityWork: false, requiresUserDecision: true),
                    urgencyBasis: anchor?.priorityReality.summary ?? "Recent disruption needs a smaller action.",
                    deadlineBasis: anchor?.deadlineRisk.summary,
                    capacityBasis: anchor?.capacityFit.summary ?? input.realitySnapshot?.capacityEstimate.summary ?? "Uses baseline capacity.",
                    protectsHighPriorityWork: protected.isEmpty == false,
                    relatedCommandKind: .splitAction,
                    relatedExplanationID: explanationID(type: .whyRecovered, explanations: explanations),
                    relatedGoalID: anchor?.goalID,
                    relatedCaptureID: anchor?.captureID,
                    relatedPlanID: anchor?.planID ?? input.planID,
                    eventLedgerEntryIDs: anchor?.eventLedgerEntryIDs ?? [],
                    recommendationExplanationIDs: anchor?.recommendationExplanationIDs ?? []
                )
            )
        }
        if disruptions.contains(where: { [.underdefinedNextStep, .scopeIncrease, .deliverableAdded].contains($0.kind) }) {
            let anchor = assessments.first { $0.signals.contains(.scopeIncreased) || $0.signals.contains(.deliverableAdded) || $0.status == .underdefined }
            options.append(
                ExecutionRecoveryOption(
                    id: "option.clarify.\(anchor?.id ?? "scope")",
                    title: "Clarify the next step",
                    summary: "Scope changed or the next step is underdefined, so recovery needs one clear decision.",
                    strategy: anchor?.signals.contains(.scopeIncreased) == true ? .reduceScope : .clarifyNextStep,
                    expectedEffect: "Turns changed scope into a believable next action before adding pressure.",
                    tradeoff: RecoveryTradeoff(summary: "A short decision replaces extra dashboard pressure.", protectsHighPriorityWork: false, defersPassiveOrFlexibleWork: false, displacesLowerPriorityWork: false, requiresUserDecision: true),
                    urgencyBasis: "Underdefined work cannot be recovered by pushing harder.",
                    capacityBasis: anchor?.capacityFit.summary ?? "Capacity stays provisional until the next step is clear.",
                    relatedCommandKind: .openDestination,
                    relatedExplanationID: explanationID(type: .whyGoalChanged, explanations: explanations),
                    relatedGoalID: anchor?.goalID,
                    relatedCaptureID: anchor?.captureID,
                    relatedPlanID: anchor?.planID ?? input.planID
                )
            )
        }
        if disruptions.contains(where: { $0.kind == .calendarConflict || $0.kind == .noOpenWindow }) {
            options.append(
                ExecutionRecoveryOption(
                    id: "option.open.plan",
                    title: "Open Plan",
                    summary: "Plan can inspect the real week, but this assessment will not schedule or write calendar blocks.",
                    strategy: .openPlan,
                    expectedEffect: "Moves the decision to the Plan workspace without automatic scheduling.",
                    tradeoff: RecoveryTradeoff(summary: "The user chooses the change.", protectsHighPriorityWork: protected.isEmpty == false, defersPassiveOrFlexibleWork: passive.isEmpty == false, displacesLowerPriorityWork: displaced.isEmpty == false, requiresUserDecision: true),
                    urgencyBasis: "Capacity or calendar conflict needs a planning decision.",
                    capacityBasis: input.realitySnapshot?.capacityEstimate.summary ?? "Baseline capacity is all that is available.",
                    protectsHighPriorityWork: protected.isEmpty == false,
                    defersPassiveOrFlexibleWork: passive.isEmpty == false,
                    relatedCommandKind: .openDestination,
                    relatedExplanationID: explanationID(type: .whyCalendarAware, explanations: explanations),
                    relatedPlanID: input.planID
                )
            )
        }
        return unique(options)
    }

    func recommendedOption(from options: [ExecutionRecoveryOption], status: ExecutionRecoveryStatus) -> ExecutionRecoveryOption? {
        guard status != .stable else { return options.first }
        return options.first { $0.strategy == .protectDeadlineWork } ??
            options.first { $0.protectsHighPriorityWork } ??
            options.first { $0.strategy == .doSmallestNextStep } ??
            options.first { $0.strategy == .moveToWaiting } ??
            options.first
    }

    func protectedWork(from assessments: [GoalBelievabilityAssessment]) -> [ProtectedWorkSummary] {
        assessments.filter { assessment in
            rank(assessment.priorityReality.deadline) >= rank(.elevated) &&
            rank(assessment.consequenceLevel) >= rank(.high) &&
            assessment.posture != .passive &&
            assessment.posture != .optionalSomeday &&
            assessment.posture != .waiting
        }.map { assessment in
            ProtectedWorkSummary(
                id: "protected.\(assessment.id)",
                title: title(for: assessment),
                summary: assessment.deadlineRisk.summary,
                relatedGoalID: assessment.goalID,
                relatedCaptureID: assessment.captureID,
                deadline: assessment.deadlineRisk.deadlineText ?? assessment.deadlineRisk.deadline.map(DomainTimestamp.string(from:)),
                consequence: assessment.consequenceLevel,
                pressure: assessment.priorityReality.overallPressure
            )
        }
    }

    func displacedWork(from assessments: [GoalBelievabilityAssessment], protected: [ProtectedWorkSummary]) -> [DisplacedWorkSummary] {
        guard protected.isEmpty == false else { return [] }
        return assessments.filter { assessment in
            assessment.posture == .optionalSomeday ||
            assessment.posture == .passive ||
            rank(assessment.priorityReality.overallPressure) <= rank(.moderate)
        }.map { displacedSummary($0, reason: .priorityProtection) }
    }

    func passiveWork(from assessments: [GoalBelievabilityAssessment]) -> [DisplacedWorkSummary] {
        assessments.filter { $0.posture == .passive || $0.posture == .optionalSomeday }
            .map { displacedSummary($0, reason: .passiveDeferral) }
    }

    func waitingOrBlockedWork(
        from assessments: [GoalBelievabilityAssessment],
        captures: [Capture],
        nowState: CanonicalNowState?
    ) -> [DisplacedWorkSummary] {
        let fromAssessments = assessments.filter { $0.posture == .waiting || $0.posture == .blocked || $0.status == .waiting || $0.status == .blocked }
            .map { displacedSummary($0, reason: .waitingOrBlocked) }
        let fromCaptures = captures.filter { $0.status == .waiting || $0.status == .delegated || $0.route == .waiting }
            .map { capture in
                DisplacedWorkSummary(
                    id: "waiting.capture.\(capture.id)",
                    title: capture.rawText,
                    summary: "Waiting work stays findable without pressuring Today.",
                    relatedGoalID: capture.linkedGoalID,
                    relatedCaptureID: capture.id,
                    reason: .waitingOrBlocked,
                    pressure: .low,
                    isPassiveOrFlexible: false
                )
            }
        let fromNow = nowState?.blockersWaiting.references.map { reference in
            DisplacedWorkSummary(
                id: "waiting.now.\(reference.goalID ?? reference.captureID ?? reference.stepID ?? "reference")",
                title: "Blocked or waiting reference",
                summary: nowState?.blockersWaiting.summary ?? "Waiting work should not create false urgency.",
                relatedGoalID: reference.goalID,
                relatedCaptureID: reference.captureID,
                reason: .waitingOrBlocked,
                pressure: .low,
                isPassiveOrFlexible: false
            )
        } ?? []
        return unique(fromAssessments + fromCaptures + fromNow)
    }

    func displacedSummary(_ assessment: GoalBelievabilityAssessment, reason: ExecutionRecoveryReason) -> DisplacedWorkSummary {
        DisplacedWorkSummary(
            id: "displaced.\(reason.rawValue).\(assessment.id)",
            title: title(for: assessment),
            summary: assessment.summary.headline,
            relatedGoalID: assessment.goalID,
            relatedCaptureID: assessment.captureID,
            reason: reason,
            pressure: assessment.priorityReality.overallPressure,
            isPassiveOrFlexible: assessment.posture == .passive || assessment.posture == .optionalSomeday
        )
    }

    func status(disruptions: [ExecutionDisruption], nowState: CanonicalNowState?) -> ExecutionRecoveryStatus {
        if nowState?.recoveryState == .recovering { return .recovering }
        if disruptions.isEmpty { return .stable }
        if disruptions.contains(where: { $0.kind == .blockedByWaiting }) { return .blocked }
        if disruptions.contains(where: { [.noOpenWindow, .slippedDeadline].contains($0.kind) }) { return .atRisk }
        if disruptions.contains(where: { $0.severity == .high || $0.severity == .critical }) { return .needsRecovery }
        return .watch
    }

    func smallestUsefulNextStep(
        from option: ExecutionRecoveryOption?,
        assessments: [GoalBelievabilityAssessment],
        input: ExecutionResilienceProjectionInput
    ) -> String? {
        if option?.strategy == .doSmallestNextStep {
            return "Open the next step, reduce it to one useful action, and do only that."
        }
        if option?.strategy == .protectDeadlineWork {
            return "Protect the high-consequence deadline item before flexible work."
        }
        if option?.strategy == .moveToWaiting {
            return "Leave the blocked item waiting until the blocker changes."
        }
        return assessments.first?.recommendations.first?.summary ?? input.nowState?.bestNextAction?.title
    }

    func assumptions(
        input: ExecutionResilienceProjectionInput,
        assessments: [GoalBelievabilityAssessment]
    ) -> [RecommendationExplanationAssumption] {
        var output: [RecommendationExplanationAssumption] = []
        if input.realitySnapshot == nil {
            output.append(.init(id: "resilience.assumption.baseline-capacity", summary: "I used baseline capacity because no Reality Snapshot was attached.", fieldKey: "capacity"))
        }
        if assessments.isEmpty {
            output.append(.init(id: "resilience.assumption.no-believability", summary: "No believability assessments were attached, so recovery can only use Now State, captures, and recent events.", fieldKey: "believability"))
        }
        return output
    }

    func correctionSuggestions(
        disruptions: [ExecutionDisruption],
        assessments: [GoalBelievabilityAssessment]
    ) -> [RecommendationExplanationCorrectionActionKind] {
        var output = assessments.flatMap(\.correctionSuggestions)
        if disruptions.contains(where: { $0.kind == .underdefinedNextStep }) { output.append(.explainMore) }
        if disruptions.contains(where: { $0.kind == .contextMismatch }) { output.append(.changeDomainContext) }
        if disruptions.contains(where: { $0.kind == .slippedDeadline }) { output.append(.changeDeadline) }
        if disruptions.contains(where: { $0.kind == .blockedByWaiting }) { output.append(.changeRoute) }
        if output.isEmpty { output.append(.explainMore) }
        return output
    }

    func reasons(
        disruptions: [ExecutionDisruption],
        options: [ExecutionRecoveryOption],
        input: ExecutionResilienceProjectionInput
    ) -> [ExecutionRecoveryReason] {
        var output: [ExecutionRecoveryReason] = disruptions.compactMap { disruption in
            switch disruption.kind {
            case .missedAction:
                return .missedAction
            case .slippedDeadline:
                return .deadlineCompression
            case .overloadedDay, .lowCapacity:
                return .capacityPressure
            case .noOpenWindow:
                return .noOpenWindow
            case .blockedByWaiting:
                return .waitingOrBlocked
            case .priorityConflict, .lowerPriorityDisplaced, .passiveGoalCrowding:
                return .priorityProtection
            case .calendarConflict:
                return .calendarConflict
            case .contextMismatch:
                return .contextMismatch
            case .stalePlan:
                return .baselineAssumption
            case .underdefinedNextStep:
                return .underdefinedNextStep
            case .scopeIncrease, .deliverableAdded:
                return .scopeChanged
            case .recoveryAlreadyInProgress:
                return .recoveryInProgress
            }
        }
        if input.realitySnapshot == nil { output.append(.baselineAssumption) }
        if options.contains(where: \.defersPassiveOrFlexibleWork) { output.append(.passiveDeferral) }
        return output
    }

    func disruptionKind(for signal: GoalHealthSignal, assessment: GoalBelievabilityAssessment) -> ExecutionDisruptionKind? {
        switch signal {
        case .limitedCapacity:
            return .lowCapacity
        case .noOpenWindow:
            return .noOpenWindow
        case .deadlineClose where assessment.status == .unrealistic || assessment.status == .atRisk:
            return .slippedDeadline
        case .blockedByWaiting:
            return .blockedByWaiting
        case .contextMismatch:
            return .contextMismatch
        case .calendarDerivedConflict:
            return .calendarConflict
        case .scopeIncreased:
            return .scopeIncrease
        case .deliverableAdded:
            return .deliverableAdded
        case .recoveryNeeded:
            return .recoveryAlreadyInProgress
        case .passiveFlexible where rank(assessment.priorityReality.capacity) >= rank(.elevated):
            return .passiveGoalCrowding
        default:
            return nil
        }
    }

    func underdefinedDisruption(for assessment: GoalBelievabilityAssessment) -> ExecutionDisruption {
        ExecutionDisruption(
            id: "disruption.\(assessment.id).underdefined_next_step",
            kind: .underdefinedNextStep,
            title: "Next step is underdefined",
            summary: "This needs a clearer next step before recovery can be trusted.",
            severity: .moderate,
            relatedGoalID: assessment.goalID,
            relatedCaptureID: assessment.captureID,
            relatedPlanID: assessment.planID,
            relatedAssessmentID: assessment.id
        )
    }

    func slippedDeadlineDisruption(for assessment: GoalBelievabilityAssessment) -> ExecutionDisruption {
        ExecutionDisruption(
            id: "disruption.\(assessment.id).slipped_deadline",
            kind: .slippedDeadline,
            title: "Deadline has too little slack",
            summary: assessment.deadlineRisk.summary,
            severity: assessment.deadlineRisk.level,
            relatedGoalID: assessment.goalID,
            relatedCaptureID: assessment.captureID,
            relatedPlanID: assessment.planID,
            relatedAssessmentID: assessment.id,
            evidenceReferenceIDs: assessment.eventLedgerEntryIDs
        )
    }

    func title(for kind: ExecutionDisruptionKind) -> String {
        kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }

    func summary(for kind: ExecutionDisruptionKind, assessment: GoalBelievabilityAssessment) -> String {
        switch kind {
        case .noOpenWindow:
            return "No open window is visible for \(title(for: assessment))."
        case .blockedByWaiting:
            return "\(title(for: assessment)) is blocked or waiting and should not keep pressuring Today."
        case .passiveGoalCrowding:
            return "\(title(for: assessment)) is flexible and can move slowly."
        case .scopeIncrease:
            return "Scope increased for \(title(for: assessment)); recovery needs a believable next cut."
        case .deliverableAdded:
            return "A deliverable was added to \(title(for: assessment)); the goal is still a living container."
        default:
            return assessment.reasons.first?.summary ?? assessment.summary.headline
        }
    }

    func severity(for kind: ExecutionDisruptionKind, assessment: GoalBelievabilityAssessment) -> NowPressureLevel {
        switch kind {
        case .blockedByWaiting:
            return .low
        case .passiveGoalCrowding:
            return .moderate
        case .deliverableAdded, .scopeIncrease, .underdefinedNextStep:
            return .moderate
        case .calendarConflict, .noOpenWindow, .slippedDeadline:
            return maxPressure([assessment.deadlineRisk.level, assessment.capacityFit.openWindowFit])
        default:
            return assessment.priorityReality.overallPressure
        }
    }

    func title(for assessment: GoalBelievabilityAssessment) -> String {
        assessment.reasons.first?.summary.components(separatedBy: " because ").first ??
            assessment.goalID ??
            assessment.captureID ??
            "Recovery item"
    }

    func explanationID(type: RecommendationExplanationType, explanations: [RecommendationExplanation]) -> String? {
        explanations.first { $0.type == type }?.id
    }

    func pressure(for status: ExecutionRecoveryStatus) -> NowPressureLevel {
        switch status {
        case .stable:
            return .none
        case .watch:
            return .moderate
        case .needsRecovery, .recovering:
            return .elevated
        case .atRisk:
            return .high
        case .blocked:
            return .low
        }
    }

    func explanationEvidence(
        for assessment: ExecutionResilienceAssessment,
        option: ExecutionRecoveryOption?
    ) -> [RecommendationExplanationEvidence] {
        var evidence = assessment.disruptions.map {
            RecommendationExplanationEvidence(
                id: "evidence.resilience.disruption.\($0.id)",
                category: evidenceCategory(for: $0.kind),
                title: $0.title,
                summary: $0.summary,
                sourceID: $0.id,
                confidence: .medium
            )
        }
        evidence.append(contentsOf: assessment.eventLedgerEntryIDs.map {
            RecommendationExplanationEvidence(
                id: "evidence.resilience.ledger.\($0)",
                category: .memoryEvent,
                title: "Event Ledger evidence",
                sourceID: $0,
                eventLedgerEntryID: $0,
                confidence: .medium
            )
        })
        if let option {
            evidence.append(
                RecommendationExplanationEvidence(
                    id: "evidence.resilience.option.\(option.id)",
                    category: .recovery,
                    title: option.title,
                    summary: option.expectedEffect,
                    sourceID: option.id,
                    confidence: .medium,
                    isPriorityRelevant: option.protectsHighPriorityWork,
                    isDeadlineRelevant: option.protectsHighPriorityWork
                )
            )
        }
        return evidence
    }

    func evidenceCategory(for kind: ExecutionDisruptionKind) -> RecommendationExplanationEvidenceCategory {
        switch kind {
        case .calendarConflict:
            return .calendarDerived
        case .contextMismatch:
            return .contextLens
        case .noOpenWindow, .overloadedDay, .lowCapacity:
            return .capacity
        case .slippedDeadline:
            return .deadline
        case .priorityConflict, .lowerPriorityDisplaced, .passiveGoalCrowding:
            return .priority
        case .scopeIncrease:
            return .scopeChange
        case .deliverableAdded:
            return .deliverable
        case .missedAction, .blockedByWaiting, .stalePlan, .underdefinedNextStep, .recoveryAlreadyInProgress:
            return .recovery
        }
    }

    func explanationTitle(for type: RecommendationExplanationType) -> String {
        switch type {
        case .whyRecovered:
            return "Why this recovery helps"
        case .whyDeferred:
            return "Why this can wait"
        case .whyDisplaced:
            return "Why lower-priority work moved"
        case .whyPrioritized:
            return "Why this gets protected"
        case .whyScheduled:
            return "Why this belongs in Plan"
        case .whyCalendarAware:
            return "Why calendar-aware evidence matters"
        case .whyBelievable:
            return "Why this remains believable"
        case .whyNotBelievable:
            return "Why this is at risk"
        default:
            return "Why this recovery option"
        }
    }

    func correctionTitle(for kind: RecommendationExplanationCorrectionActionKind) -> String {
        switch kind {
        case .changeDomainContext: return "Change context"
        case .changeDeadline: return "Change deadline"
        case .changeImportance: return "Change importance"
        case .changeUrgency: return "Change urgency"
        case .changeConsequence: return "Change consequence"
        case .changeRoute: return "Change route"
        case .markGoalSupporting: return "Mark goal-supporting"
        case .markOneTimeTask: return "Mark one-time task"
        case .markOptionalSomeday: return "Mark optional someday"
        case .dismissRecommendation: return "Dismiss"
        case .explainMore: return "Explain more"
        }
    }

    func correctionField(for kind: RecommendationExplanationCorrectionActionKind) -> String? {
        switch kind {
        case .changeDomainContext: return "context"
        case .changeDeadline: return "deadline"
        case .changeImportance: return "importance"
        case .changeUrgency: return "urgency"
        case .changeConsequence: return "consequence"
        case .changeRoute: return "route"
        case .markGoalSupporting: return "goalRelationship"
        case .markOneTimeTask: return "commitmentKind"
        case .markOptionalSomeday: return "posture"
        case .dismissRecommendation, .explainMore: return nil
        }
    }

    func privacy(
        input: ExecutionResilienceProjectionInput,
        assessments: [GoalBelievabilityAssessment]
    ) -> EventLedgerPrivacyClassification {
        if input.captures.contains(where: { $0.privacy == .privateUserText }) { return .privateUserText }
        if input.eventLedgerEntries.contains(where: { $0.privacy == .privateUserText }) { return .privateUserText }
        if assessments.contains(where: { $0.privacy == .calendarDerived }) { return .calendarDerived }
        if input.realitySnapshot?.privacy == .calendarDerived { return .calendarDerived }
        if input.recommendationExplanations.contains(where: { $0.privacy == .calendarDerived }) { return .calendarDerived }
        return .standard
    }

    func unique(_ disruptions: [ExecutionDisruption]) -> [ExecutionDisruption] {
        var byID: [String: ExecutionDisruption] = [:]
        for disruption in disruptions {
            byID[disruption.id] = disruption
        }
        return byID.values.sorted { lhs, rhs in
            if lhs.severity != rhs.severity { return rank(lhs.severity) > rank(rhs.severity) }
            return lhs.id < rhs.id
        }
    }

    func unique(_ options: [ExecutionRecoveryOption]) -> [ExecutionRecoveryOption] {
        var byID: [String: ExecutionRecoveryOption] = [:]
        for option in options {
            byID[option.id] = option
        }
        return byID.values.sorted { $0.id < $1.id }
    }

    func unique(_ summaries: [DisplacedWorkSummary]) -> [DisplacedWorkSummary] {
        var byID: [String: DisplacedWorkSummary] = [:]
        for summary in summaries {
            byID[summary.id] = summary
        }
        return byID.values.sorted { $0.id < $1.id }
    }

    func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    func maxPressure(_ values: [NowPressureLevel]) -> NowPressureLevel {
        values.max { rank($0) < rank($1) } ?? .none
    }

    func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: 0
        case .low: 1
        case .moderate: 2
        case .elevated: 3
        case .high: 4
        case .critical: 5
        }
    }
}
