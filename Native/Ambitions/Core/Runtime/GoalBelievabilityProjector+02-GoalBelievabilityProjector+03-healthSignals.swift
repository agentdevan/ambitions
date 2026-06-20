import Foundation

extension GoalBelievabilityProjector {

    func healthSignals(
        input: BelievabilityProjectionInput,
        posture: GoalPosture,
        priority: GoalPriorityRealityAssessment,
        deadline: GoalDeadlineRisk,
        capacity: GoalCapacityFit,
        consequence: NowPressureLevel,
        effort: NowPressureLevel,
        contextFit: NowPressureLevel
    ) -> [GoalHealthSignal] {
        var signals: [GoalHealthSignal] = []
        if capacity.hasEnoughCapacity { signals.append(.enoughCapacity) }
        if capacity.hasEnoughCapacity == false || rank(capacity.level) >= rank(.elevated) { signals.append(.limitedCapacity) }
        if capacity.openWindowCount == 0 && input.realitySnapshot != nil { signals.append(.noOpenWindow) }
        if rank(deadline.level) >= rank(.elevated) { signals.append(.deadlineClose) }
        if deadline.isHardDeadline { signals.append(.hardDeadline) }
        if rank(consequence) >= rank(.high) { signals.append(.highConsequence) }
        if rank(consequence) <= rank(.low) { signals.append(.lowConsequence) }
        if rank(effort) >= rank(.elevated) { signals.append(.highEffort) }
        if posture == .passive { signals.append(.passiveFlexible) }
        if posture == .active && rank(priority.importance) >= rank(.moderate) { signals.append(.activePriority) }
        if rank(contextFit) >= rank(.high) { signals.append(.contextMismatch) }
        if input.realitySnapshot?.conflictSummary.calendarConflictCount ?? 0 > 0 { signals.append(.calendarDerivedConflict) }
        if deadline.isDeadlineBound == false && posture == .active { signals.append(.missingDeadline) }
        if input.effortMinutes == nil { signals.append(.missingEffort) }
        if priority.importance == .none || priority.importance == .low { signals.append(.missingPriority) }
        if posture == .waiting || posture == .blocked { signals.append(.blockedByWaiting) }
        if input.subjectKind == .scopeChangeSeed { signals.append(.scopeIncreased) }
        if input.subjectKind == .deliverableSeed || input.capture?.kind == .deliverableSeed { signals.append(.deliverableAdded) }
        if input.recoveryState == .needsRecovery || input.recoveryState == .recovering { signals.append(.recoveryNeeded) }
        return signals
    }


    func status(
        posture: GoalPosture,
        signals: [GoalHealthSignal],
        priority: GoalPriorityRealityAssessment,
        deadline: GoalDeadlineRisk,
        capacity: GoalCapacityFit
    ) -> GoalHealthStatus {
        if posture == .waiting { return .waiting }
        if posture == .blocked || signals.contains(.blockedByWaiting) { return .blocked }
        if posture == .optionalSomeday { return .optionalSomeday }
        if posture == .passive { return .passive }
        if posture == .underdefined || (signals.contains(.missingPriority) && signals.contains(.missingEffort) && signals.contains(.missingDeadline)) {
            return .underdefined
        }
        if signals.contains(.noOpenWindow) && deadline.isDeadlineBound && rank(deadline.level) >= rank(.high) {
            return .unrealistic
        }
        if capacity.hasEnoughCapacity == false && rank(priority.consequence) >= rank(.high) {
            return .atRisk
        }
        if rank(deadline.level) >= rank(.high) || signals.contains(.contextMismatch) || capacity.hasEnoughCapacity == false {
            return .tight
        }
        return .believable
    }


    func confidence(
        status: GoalHealthStatus,
        input: BelievabilityProjectionInput,
        deadline: GoalDeadlineRisk,
        capacity: GoalCapacityFit,
        signals: [GoalHealthSignal]
    ) -> RecommendationConfidence {
        var score = input.realitySnapshot == nil ? 0.58 : 0.76
        if deadline.isDeadlineBound { score += 0.06 }
        if capacity.requiredMinutes != nil { score += 0.05 }
        if signals.contains(.missingEffort) { score -= 0.12 }
        if signals.contains(.missingPriority) { score -= 0.08 }
        if signals.contains(.missingDeadline), status != .passive && status != .optionalSomeday { score -= 0.08 }
        if status == .underdefined { score -= 0.18 }
        return RecommendationConfidence.label(for: score)
    }


    func reasons(
        status: GoalHealthStatus,
        input: BelievabilityProjectionInput,
        deadline: GoalDeadlineRisk,
        capacity: GoalCapacityFit,
        priority: GoalPriorityRealityAssessment,
        posture: GoalPosture,
        contextLens: NowContextLens
    ) -> [GoalBelievabilityReason] {
        var output: [GoalBelievabilityReason] = []
        switch status {
        case .believable:
            output.append(.init(id: "reason.capacity.enough", signal: .enoughCapacity, summary: "This looks believable because there are enough open windows before the deadline.", evidenceCategory: .capacity))
        case .tight:
            output.append(.init(id: "reason.capacity.tight", signal: .limitedCapacity, summary: "This is tight because the deadline is close and available time is limited.", evidenceCategory: .capacity))
        case .atRisk:
            output.append(.init(id: "reason.risk.consequence", signal: .highConsequence, summary: "This is at risk because the item has high consequence but capacity is thin.", evidenceCategory: .consequence))
        case .unrealistic:
            output.append(.init(id: "reason.window.none", signal: .noOpenWindow, summary: "This is not realistic yet because no open window is visible before the deadline.", evidenceCategory: .capacity))
        case .blocked:
            output.append(.init(id: "reason.waiting.blocked", signal: .blockedByWaiting, summary: "This is blocked by a waiting state or blocked step.", evidenceCategory: .recovery))
        case .underdefined:
            output.append(.init(id: "reason.underdefined.missing", summary: "This needs more definition before Ambitions can judge believability.", evidenceCategory: .assumption))
        case .passive:
            output.append(.init(id: "reason.passive.flexible", signal: .passiveFlexible, summary: "This can move slowly because it is passive and flexible.", evidenceCategory: .goalState))
        case .optionalSomeday:
            output.append(.init(id: "reason.optional.someday", signal: .passiveFlexible, summary: "This can stay optional without competing with urgent commitments.", evidenceCategory: .captureState))
        case .waiting:
            output.append(.init(id: "reason.waiting", signal: .blockedByWaiting, summary: "This is waiting on someone or something else.", evidenceCategory: .captureState))
        }
        if input.realitySnapshot == nil {
            output.append(.init(id: "reason.assumption.baseline", summary: "I used baseline capacity because no Reality Snapshot was attached.", evidenceCategory: .systemDefault))
        }
        if input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true {
            output.append(.init(id: "reason.calendar.local", signal: .calendarDerivedConflict, summary: "Calendar-derived capacity evidence stayed local to this assessment.", evidenceCategory: .calendarDerived))
        }
        if priority.contextFit == .high {
            output.append(.init(id: "reason.context.mismatch", signal: .contextMismatch, summary: "I assumed this belongs in \(contextLens.rawValue.replacingOccurrences(of: "_", with: " ")) time. You can change that.", evidenceCategory: .contextLens))
        }
        if deadline.isHardDeadline && rank(deadline.level) >= rank(.elevated) {
            output.append(.init(id: "reason.deadline.hard", signal: .hardDeadline, summary: deadline.summary, evidenceCategory: .deadline))
        }
        if output.count < 2 {
            output.append(.init(id: "reason.priority.dimensions", summary: priority.summary, evidenceCategory: .priority))
        }
        if output.count < 3 {
            output.append(.init(id: "reason.capacity.summary", summary: capacity.summary, evidenceCategory: .capacity))
        }
        return Array(output.prefix(4))
    }


    func assumptions(input: BelievabilityProjectionInput, posture: GoalPosture, effortMinutes: Int?) -> [GoalBelievabilityAssumption] {
        var output: [GoalBelievabilityAssumption] = []
        if input.realitySnapshot == nil {
            output.append(.init(id: "assumption.baseline-capacity", summary: "I assumed baseline open capacity because calendar/reality data was not attached.", fieldKey: "capacity"))
        }
        if effortMinutes == nil {
            output.append(.init(id: "assumption.effort", summary: "I do not have a confirmed effort estimate yet.", fieldKey: "effort"))
        }
        if input.capture?.contextLensHint == nil && input.goal?.lifeGraph?.domains.first == nil {
            output.append(.init(id: "assumption.context", summary: "I assumed this can fit the current context until you choose a better one.", fieldKey: "context"))
        }
        if posture == .passive {
            output.append(.init(id: "assumption.passive", summary: "I treated this as passive because it is learning, exploratory, paused, or untimed.", fieldKey: "posture"))
        }
        return output
    }


    func recommendations(status: GoalHealthStatus, signals: [GoalHealthSignal], posture: GoalPosture) -> [GoalBelievabilityRecommendation] {
        switch status {
        case .believable:
            return [.init(id: "recommend.keep", title: "Keep current plan", summary: "No capacity correction is needed right now.")]
        case .tight:
            return [.init(id: "recommend.protect-window", title: "Protect a work window", summary: "Use Time later to place a user-confirmed block if this still matters.", correctionAction: .changeUrgency)]
        case .atRisk, .unrealistic:
            return [.init(id: "recommend.correct-scope", title: "Correct deadline, effort, or scope", summary: "Change the deadline, effort, consequence, or scope before treating this as stable.", correctionAction: .changeDeadline)]
        case .blocked, .waiting:
            return [.init(id: "recommend.waiting", title: "Keep it waiting", summary: "Keep this out of urgent execution until the blocker changes.", correctionAction: .changeRoute)]
        case .underdefined:
            return [.init(id: "recommend.define", title: "Add missing details", summary: "Add deadline, effort, priority, or context before relying on this assessment.", correctionAction: .explainMore)]
        case .passive:
            return [.init(id: "recommend.passive", title: "Let it move slowly", summary: "Keep it active without letting it crowd urgent commitments.", correctionAction: .markOptionalSomeday)]
        case .optionalSomeday:
            return [.init(id: "recommend.optional", title: "Leave it optional", summary: "It can remain findable without competing for capacity.", correctionAction: .markOptionalSomeday)]
        }
    }


    func correctionSuggestions(signals: [GoalHealthSignal], posture: GoalPosture) -> [RecommendationExplanationCorrectionActionKind] {
        var output: [RecommendationExplanationCorrectionActionKind] = []
        if signals.contains(.missingDeadline) || signals.contains(.deadlineClose) { output.append(.changeDeadline) }
        if signals.contains(.missingPriority) { output.append(.changeImportance) }
        if signals.contains(.contextMismatch) { output.append(.changeDomainContext) }
        if signals.contains(.highConsequence) { output.append(.changeConsequence) }
        if posture == .optionalSomeday || posture == .passive { output.append(.markOptionalSomeday) }
        if posture == .waiting { output.append(.changeRoute) }
        if output.isEmpty { output.append(.explainMore) }
        return output
    }


    func explanationEvidence(for assessment: GoalBelievabilityAssessment) -> [RecommendationExplanationEvidence] {
        var evidence: [RecommendationExplanationEvidence] = [
            .init(id: "evidence.believability.status", category: .goalState, title: "Believability status", summary: assessment.status.rawValue, sourceID: assessment.id, confidence: assessment.confidence),
            .init(id: "evidence.believability.capacity", category: .capacity, title: "Capacity fit", summary: assessment.capacityFit.summary, sourceID: assessment.relatedRealitySnapshotID, confidence: assessment.confidence),
            .init(id: "evidence.believability.deadline", category: .deadline, title: "Deadline risk", summary: assessment.deadlineRisk.summary, sourceID: assessment.relatedRealitySnapshotID, confidence: assessment.confidence),
            .init(id: "evidence.believability.priority", category: .priority, title: "Priority reality", summary: assessment.priorityReality.summary, sourceID: assessment.id, confidence: assessment.confidence)
        ]
        evidence.append(contentsOf: assessment.eventLedgerEntryIDs.map {
            RecommendationExplanationEvidence(
                id: "evidence.believability.ledger.\($0)",
                category: .memoryEvent,
                title: "Event Ledger evidence",
                sourceID: $0,
                eventLedgerEntryID: $0,
                confidence: assessment.confidence
            )
        })
        if assessment.hasCalendarDerivedEvidence {
            evidence.append(.init(id: "evidence.believability.calendar", category: .calendarDerived, title: "Calendar-derived capacity", summary: "Calendar-derived evidence is local-only.", sourceID: assessment.relatedRealitySnapshotID, confidence: assessment.confidence, isCalendarDerived: true))
        }
        return evidence
    }


    func title(for type: RecommendationExplanationType, status: GoalHealthStatus) -> String {
        switch type {
        case .whyBelievable:
            return "Why this looks believable"
        case .whyNotBelievable:
            return "Why this does not look believable"
        case .whyPrioritized:
            return "Why this has priority pressure"
        case .whyDeferred:
            return "Why this can wait"
        case .whyDisplaced:
            return "Why this may displace lower-pressure work"
        case .whyCalendarAware:
            return "Why calendar-aware capacity matters"
        case .whyGoalChanged:
            return "Why goal health changed"
        case .whyPlanChanged:
            return "Why plan believability changed"
        default:
            return "Why this assessment says \(status.rawValue.replacingOccurrences(of: "_", with: " "))"
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


    func assessmentID(generatedAt: String, goalID: String?, captureID: String?, stepID: String?, subjectKind: GoalBelievabilitySubjectKind) -> String {
        let anchor = goalID ?? captureID ?? stepID ?? "unanchored"
        return "believability.\(subjectKind.rawValue).\(anchor).\(generatedAt)"
    }


    func date(from value: String?) -> Date? {
        guard let value else { return nil }
        return DomainTimestamp.date(from: value)
    }


    func captureHint(_ value: NowPressureLevel?) -> NowPressureLevel {
        value ?? .none
    }


    func maxPressure(_ values: [NowPressureLevel]) -> NowPressureLevel {
        values.max { rank($0) < rank($1) } ?? .none
    }
}
