import Foundation

extension ExecutionResilienceProjector {
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
                        relatedTimeID: assessment.planID,
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
                    relatedTimeID: input.timeID,
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
                    relatedTimeID: input.timeID,
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
                    relatedTimeID: input.timeID,
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
                    relatedTimeID: input.timeID
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
                    expectedEffect: "Protects urgent work while preserving passive goals without pressure.",
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
                    relatedTimeID: input.timeID
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
                    relatedTimeID: anchor?.planID ?? input.timeID,
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
                    tradeoff: RecoveryTradeoff(summary: "A short decision keeps pressure from spreading.", protectsHighPriorityWork: false, defersPassiveOrFlexibleWork: false, displacesLowerPriorityWork: false, requiresUserDecision: true),
                    urgencyBasis: "Underdefined work cannot be recovered by pushing harder.",
                    capacityBasis: anchor?.capacityFit.summary ?? "Capacity stays provisional until the next step is clear.",
                    relatedCommandKind: .openDestination,
                    relatedExplanationID: explanationID(type: .whyGoalChanged, explanations: explanations),
                    relatedGoalID: anchor?.goalID,
                    relatedCaptureID: anchor?.captureID,
                    relatedTimeID: anchor?.planID ?? input.timeID
                )
            )
        }
        if disruptions.contains(where: { $0.kind == .calendarConflict || $0.kind == .noOpenWindow }) {
            options.append(
                ExecutionRecoveryOption(
                    id: "option.open.plan",
                    title: "Open Time",
                    summary: "Plan can inspect the real week, but this assessment will not schedule or write calendar blocks.",
                    strategy: .openTime,
                    expectedEffect: "Moves the decision to Time without automatic scheduling.",
                    tradeoff: RecoveryTradeoff(summary: "The user chooses the change.", protectsHighPriorityWork: protected.isEmpty == false, defersPassiveOrFlexibleWork: passive.isEmpty == false, displacesLowerPriorityWork: displaced.isEmpty == false, requiresUserDecision: true),
                    urgencyBasis: "Capacity or calendar conflict needs a planning decision.",
                    capacityBasis: input.realitySnapshot?.capacityEstimate.summary ?? "Baseline capacity is all that is available.",
                    protectsHighPriorityWork: protected.isEmpty == false,
                    defersPassiveOrFlexibleWork: passive.isEmpty == false,
                    relatedCommandKind: .openDestination,
                    relatedExplanationID: explanationID(type: .whyCalendarAware, explanations: explanations),
                    relatedTimeID: input.timeID
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
}
