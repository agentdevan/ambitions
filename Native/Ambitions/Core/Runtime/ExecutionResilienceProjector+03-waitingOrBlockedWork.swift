import Foundation

extension ExecutionResilienceProjector {

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
            relatedTimeID: assessment.planID,
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
            relatedTimeID: assessment.planID,
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
}
