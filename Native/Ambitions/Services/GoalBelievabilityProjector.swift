import Foundation

protocol GoalBelievabilityAssessing: Sendable {
    func assess(_ input: BelievabilityProjectionInput) -> GoalBelievabilityAssessment
    func makeExplanation(
        for assessment: GoalBelievabilityAssessment,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation
}

struct GoalBelievabilityProjector: GoalBelievabilityAssessing {
    func assess(_ input: BelievabilityProjectionInput) -> GoalBelievabilityAssessment {
        let generatedAt = DomainTimestamp.string(from: input.generatedAt)
        let goalID = input.goal?.id ?? input.capture?.goalRelationship?.goalID ?? input.capture?.linkedGoalID
        let captureID = input.capture?.id
        let stepID = input.step?.id
        let planID = input.planID ?? input.goal?.plan?.id
        let posture = posture(for: input)
        let contextLens = contextLens(for: input)
        let effortMinutes = input.effortMinutes ?? inferredEffortMinutes(for: input)
        let effortLevel = effortLevel(minutes: effortMinutes, input: input)
        let deadline = deadlineRisk(for: input)
        let consequence = input.consequence ?? consequenceLevel(for: input, deadline: deadline)
        let importance = input.importance ?? importanceLevel(for: input, consequence: consequence)
        let contextFit = contextFit(for: input, contextLens: contextLens)
        let capacity = capacityFit(for: input, effortMinutes: effortMinutes, deadline: deadline)
        let urgency = maxPressure([deadline.level, captureHint(input.capture?.priorityHints.urgency)])
        let goalRelationship = goalRelationshipPressure(for: input)
        let userPreference = input.userPreference ?? .none
        let priority = priorityReality(
            importance: importance,
            urgency: urgency,
            deadline: deadline.level,
            consequence: consequence,
            effort: effortLevel,
            contextFit: contextFit,
            goalRelationship: goalRelationship,
            userPreference: userPreference,
            capacity: capacity.level,
            recoveryState: input.recoveryState
        )
        let signals = healthSignals(
            input: input,
            posture: posture,
            priority: priority,
            deadline: deadline,
            capacity: capacity,
            consequence: consequence,
            effort: effortLevel,
            contextFit: contextFit
        )
        let status = status(
            posture: posture,
            signals: signals,
            priority: priority,
            deadline: deadline,
            capacity: capacity
        )
        let confidence = confidence(
            status: status,
            input: input,
            deadline: deadline,
            capacity: capacity,
            signals: signals
        )
        let reasons = reasons(
            status: status,
            input: input,
            deadline: deadline,
            capacity: capacity,
            priority: priority,
            posture: posture,
            contextLens: contextLens
        )
        let assumptions = assumptions(input: input, posture: posture, effortMinutes: effortMinutes)
        let recommendations = recommendations(
            status: status,
            signals: signals,
            posture: posture
        )
        let correctionSuggestions = correctionSuggestions(signals: signals, posture: posture)
        let eventIDs = normalized(
            input.eventLedgerEntries.map(\.id) +
            (input.realitySnapshot?.eventLedgerEntryIDs ?? []) +
            input.recommendationExplanations.flatMap(\.relations.eventLedgerEntryIDs)
        )
        let explanationIDs = normalized(
            input.recommendationExplanations.map(\.id) +
            (input.realitySnapshot?.recommendationExplanationIDs ?? []) +
            (input.capture?.recommendationExplanationIDs ?? [])
        )
        let calendarDerived = input.realitySnapshot?.privacy == .calendarDerived ||
            input.realitySnapshot?.calendarContext != nil ||
            input.realitySnapshot?.windows.contains(where: \.isCalendarDerived) == true ||
            input.recommendationExplanations.contains(where: \.containsCalendarDerivedEvidence)
        let privacy: EventLedgerPrivacyClassification = calendarDerived ? .calendarDerived : (input.capture?.privacy ?? .standard)

        return GoalBelievabilityAssessment(
            id: assessmentID(generatedAt: generatedAt, goalID: goalID, captureID: captureID, stepID: stepID, subjectKind: input.subjectKind),
            goalID: goalID,
            captureID: captureID,
            planID: planID,
            stepID: stepID,
            subjectKind: input.subjectKind,
            generatedAt: generatedAt,
            status: status,
            confidence: confidence,
            posture: posture,
            priorityReality: priority,
            deadlineRisk: deadline,
            consequenceLevel: consequence,
            effortLevel: effortLevel,
            effortMinutes: effortMinutes,
            contextLens: contextLens,
            contextFit: contextFit,
            capacityFit: capacity,
            signals: signals,
            reasons: reasons,
            recommendations: recommendations,
            assumptions: assumptions,
            correctionSuggestions: correctionSuggestions,
            hasCalendarDerivedEvidence: calendarDerived,
            privacy: privacy,
            relatedRealitySnapshotID: input.realitySnapshot?.id,
            eventLedgerEntryIDs: eventIDs,
            recommendationExplanationIDs: explanationIDs
        )
    }

    func makeExplanation(
        for assessment: GoalBelievabilityAssessment,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation {
        let evidence = explanationEvidence(for: assessment)
        let assumptionEvidence = assessment.assumptions.map {
            RecommendationExplanationAssumption(
                id: "explanation.\($0.id)",
                summary: $0.summary,
                fieldKey: $0.fieldKey,
                confidence: $0.confidence,
                isUserCorrectable: $0.isUserCorrectable
            )
        }
        let correctionActions = assessment.correctionSuggestions.map { action in
            RecommendationExplanationCorrectionAction(
                id: "believability.correction.\(action.rawValue)",
                kind: action,
                title: correctionTitle(for: action),
                targetFieldKey: correctionField(for: action)
            )
        }
        return RecommendationExplanation(
            id: "explanation.believability.\(assessment.id).\(type.rawValue)",
            type: type,
            title: title(for: type, status: assessment.status),
            summary: assessment.summary.headline,
            recommendationTitle: assessment.recommendations.first?.title ?? assessment.summary.headline,
            recommendationSummary: assessment.reasons.map(\.summary).joined(separator: " "),
            confidence: assessment.confidence,
            evidence: evidence,
            assumptions: assumptionEvidence,
            userCorrectableFields: correctionActions.compactMap(\.targetFieldKey),
            correctionActions: correctionActions,
            lastUpdatedAt: assessment.generatedAt,
            source: .recommendation,
            relations: RecommendationExplanationRelations(
                goalIDs: [assessment.goalID].compactMap { $0 },
                captureIDs: [assessment.captureID].compactMap { $0 },
                planIDs: [assessment.planID].compactMap { $0 },
                eventLedgerEntryIDs: assessment.eventLedgerEntryIDs
            ),
            privacy: assessment.privacy,
            localOnly: true,
            metadata: [
                "assessmentID": assessment.id,
                "status": assessment.status.rawValue,
                "posture": assessment.posture.rawValue,
                "schema": assessment.schemaVersion
            ]
        )
    }
}

extension GoalBelievabilityProjector {
    func nowGoalPressureSummary(from assessment: GoalBelievabilityAssessment) -> NowGoalPressureSummary? {
        guard let goalID = assessment.goalID else { return nil }
        let kind: NowGoalPressureKind = assessment.posture == .passive ? .passiveGoal : .activeGoal
        return NowGoalPressureSummary(
            id: "now.believability.\(assessment.id)",
            kind: kind,
            level: assessment.priorityReality.overallPressure,
            goalID: goalID,
            title: assessment.summary.headline,
            summary: assessment.reasons.first?.summary ?? assessment.priorityReality.summary,
            explanationID: assessment.recommendationExplanationIDs.first,
            eventLedgerEntryIDs: assessment.eventLedgerEntryIDs
        )
    }

    func commandNeedsConfirmationMetadata(from assessment: GoalBelievabilityAssessment) -> [String: String] {
        guard assessment.status == .atRisk || assessment.status == .unrealistic || assessment.status == .blocked else {
            return [:]
        }
        return [
            "believabilityAssessmentID": assessment.id,
            "believabilityStatus": assessment.status.rawValue,
            "believabilitySummary": assessment.summary.headline,
            "needsConfirmation": "true"
        ]
    }
}

private extension GoalBelievabilityProjector {
    func posture(for input: BelievabilityProjectionInput) -> GoalPosture {
        if input.capture?.route == .waiting || input.capture?.status == .waiting || input.capture?.status == .delegated {
            return .waiting
        }
        if input.capture?.route == .optionalSomeday || input.capture?.priorityHints.optionalSomeday == true {
            return .optionalSomeday
        }
        if input.step?.state == .blocked {
            return .blocked
        }
        if input.goal?.state == .paused || input.goal?.mode == .learning || input.goal?.mode == .exploration || input.goal?.timing.tempo == .untimed || input.capture?.priorityHints.passive == true {
            return .passive
        }
        if input.goal == nil && input.capture == nil {
            return .underdefined
        }
        return .active
    }

    func contextLens(for input: BelievabilityProjectionInput) -> NowContextLens {
        input.capture?.contextLensHint ??
            lens(for: input.goal) ??
            input.activeContextLens
    }

    func lens(for goal: Goal?) -> NowContextLens? {
        guard let domain = goal?.lifeGraph?.domains.first?.domain else { return nil }
        switch domain {
        case .career, .education:
            return .work
        case .creativity:
            return .creative
        case .finance, .home:
            return .admin
        case .health:
            return .recovery
        case .personalGrowth, .relationships:
            return .personal
        }
    }

    func inferredEffortMinutes(for input: BelievabilityProjectionInput) -> Int? {
        if let stepMinutes = input.step?.timing.repeatEveryDays.map({ _ in 30 }) {
            return stepMinutes
        }
        if input.capture?.priorityHints.effort == .high || input.capture?.priorityHints.effort == .critical {
            return 120
        }
        if input.capture?.kind == .deliverableSeed || input.subjectKind == .deliverableSeed || input.subjectKind == .scopeChangeSeed {
            return 90
        }
        if input.capture?.kind == .oneTimeCommitment || input.capture?.kind == .deadlineTask {
            return 60
        }
        if let target = input.goal?.progressStrategy.targetMinutes {
            return target
        }
        return nil
    }

    func effortLevel(minutes: Int?, input: BelievabilityProjectionInput) -> NowPressureLevel {
        let hint = captureHint(input.capture?.priorityHints.effort)
        if hint != .none {
            return hint
        }
        guard let minutes else { return .none }
        switch minutes {
        case 0..<30:
            return .low
        case 30..<90:
            return .moderate
        case 90..<180:
            return .elevated
        default:
            return .high
        }
    }

    func deadlineRisk(for input: BelievabilityProjectionInput) -> GoalDeadlineRisk {
        let deadline = date(from: input.step?.timing.dueAt ?? input.step?.timing.targetBy ?? input.step?.timing.windowEnd) ??
            date(from: input.goal?.timing.dueAt ?? input.goal?.timing.targetBy ?? input.goal?.timing.windowEnd)
        let deadlineText = input.capture?.deadlineText
        let deadlineKind = input.capture?.deadlineKind
        let isDeadlineBound = deadline != nil || deadlineText != nil || deadlineKind == .hard || input.capture?.kind == .deadlineTask || input.capture?.kind == .oneTimeCommitment
        let isHard = deadlineKind == .hard || input.step?.timing.timingType == .dueAt || input.goal?.timing.timingType == .dueAt
        let openBefore = openMinutesBeforeDeadline(input.realitySnapshot, deadline: deadline)
        let days = deadline.map { Calendar(identifier: .gregorian).dateComponents([.day], from: input.generatedAt, to: $0).day ?? 0 }
        let level: NowPressureLevel
        if isDeadlineBound == false {
            level = .none
        } else if let days, days < 0 {
            level = .critical
        } else if openBefore == 0 && input.realitySnapshot != nil {
            level = .high
        } else if let days, days <= 1 {
            level = .critical
        } else if let days, days <= 3 {
            level = .high
        } else if let days, days <= 7 || deadlineText != nil {
            level = .elevated
        } else {
            level = .moderate
        }

        return GoalDeadlineRisk(
            level: level,
            deadline: deadline,
            deadlineText: deadlineText,
            deadlineKind: deadlineKind,
            daysUntilDeadline: days,
            openMinutesBeforeDeadline: openBefore,
            isDeadlineBound: isDeadlineBound,
            isHardDeadline: isHard,
            summary: deadlineSummary(isDeadlineBound: isDeadlineBound, isHard: isHard, level: level, openBefore: openBefore, deadlineText: deadlineText)
        )
    }

    func openMinutesBeforeDeadline(_ snapshot: RealitySnapshot?, deadline: Date?) -> Int {
        guard let snapshot else { return 0 }
        guard let deadline else {
            return snapshot.capacityEstimate.totalOpenMinutes
        }
        return snapshot.openWindowCandidates
            .filter { $0.start < deadline }
            .reduce(0) { total, candidate in
                total + max(0, Int(min(candidate.end, deadline).timeIntervalSince(candidate.start) / 60))
            }
    }

    func deadlineSummary(isDeadlineBound: Bool, isHard: Bool, level: NowPressureLevel, openBefore: Int, deadlineText: String?) -> String {
        guard isDeadlineBound else { return "No deadline pressure is visible." }
        if openBefore == 0 && rank(level) >= rank(.high) {
            return "No open window is visible before the deadline."
        }
        if let deadlineText {
            return "\(deadlineText) is treated as \(isHard ? "a hard" : "a visible") deadline."
        }
        return isHard ? "A hard deadline is shaping believability." : "Deadline pressure is shaping believability."
    }

    func consequenceLevel(for input: BelievabilityProjectionInput, deadline: GoalDeadlineRisk) -> NowPressureLevel {
        let hint = captureHint(input.capture?.priorityHints.consequence)
        if hint != .none {
            return hint
        }
        if deadline.isHardDeadline && rank(deadline.level) >= rank(.elevated) {
            return .high
        }
        if input.capture?.priorityHints.optionalSomeday == true || input.goal?.mode == .learning || input.goal?.timing.tempo == .untimed {
            return .low
        }
        return .moderate
    }

    func importanceLevel(for input: BelievabilityProjectionInput, consequence: NowPressureLevel) -> NowPressureLevel {
        let hint = captureHint(input.capture?.priorityHints.importance)
        if hint != .none {
            return hint
        }
        if input.goal?.state == .active || input.capture?.priorityHints.goalSupporting == true {
            return maxPressure([.moderate, consequence])
        }
        if input.capture?.priorityHints.optionalSomeday == true {
            return .low
        }
        return consequence
    }

    func contextFit(for input: BelievabilityProjectionInput, contextLens: NowContextLens) -> NowPressureLevel {
        guard let snapshot = input.realitySnapshot else {
            return .low
        }
        if contextLens == .all || snapshot.activeContextLens == .all || snapshot.activeContextLens == contextLens {
            return .low
        }
        let matching = snapshot.openWindowCandidates.contains { $0.contextLens == contextLens || $0.contextLens == .all }
        return matching ? .moderate : .high
    }

    func capacityFit(for input: BelievabilityProjectionInput, effortMinutes: Int?, deadline: GoalDeadlineRisk) -> GoalCapacityFit {
        guard let snapshot = input.realitySnapshot else {
            return GoalCapacityFit(
                level: .moderate,
                requiredMinutes: effortMinutes,
                openWindowFit: .moderate,
                hasEnoughCapacity: true,
                summary: "No Reality Snapshot is attached, so this uses a baseline capacity assumption."
            )
        }
        let available = deadline.isDeadlineBound ? deadline.openMinutesBeforeDeadline : snapshot.capacityEstimate.totalOpenMinutes
        let required = effortMinutes ?? 30
        let enough = available >= required
        let openFit: NowPressureLevel
        if snapshot.openWindowCandidates.isEmpty {
            openFit = .critical
        } else if enough {
            openFit = .low
        } else if available > 0 {
            openFit = .elevated
        } else {
            openFit = .high
        }
        let level = enough ? snapshot.capacityEstimate.capacityLevel : maxPressure([snapshot.capacityEstimate.capacityLevel, .elevated])
        return GoalCapacityFit(
            level: level,
            requiredMinutes: effortMinutes,
            availableOpenMinutes: available,
            openWindowCount: snapshot.openWindowCandidates.count,
            openWindowFit: openFit,
            hasEnoughCapacity: enough,
            summary: enough
                ? "\(available) open minutes are visible for this item."
                : "Available open time is below the estimated effort."
        )
    }

    func goalRelationshipPressure(for input: BelievabilityProjectionInput) -> NowPressureLevel {
        if input.capture?.kind == .deliverableSeed || input.subjectKind == .deliverableSeed {
            return .elevated
        }
        if input.capture?.priorityHints.goalSupporting == true || input.goal?.relationshipKind == .support {
            return .moderate
        }
        if input.goal != nil {
            return .moderate
        }
        return .none
    }

    func priorityReality(
        importance: NowPressureLevel,
        urgency: NowPressureLevel,
        deadline: NowPressureLevel,
        consequence: NowPressureLevel,
        effort: NowPressureLevel,
        contextFit: NowPressureLevel,
        goalRelationship: NowPressureLevel,
        userPreference: NowPressureLevel,
        capacity: NowPressureLevel,
        recoveryState: NowRecoveryState
    ) -> GoalPriorityRealityAssessment {
        let recoveryPressure: NowPressureLevel
        switch recoveryState {
        case .stable: recoveryPressure = .none
        case .watch: recoveryPressure = .moderate
        case .needsRecovery, .recovering: recoveryPressure = .elevated
        case .blocked: recoveryPressure = .high
        }
        let overall = maxPressure([importance, urgency, deadline, consequence, effort, contextFit, goalRelationship, userPreference, capacity, recoveryPressure])
        return GoalPriorityRealityAssessment(
            importance: importance,
            urgency: urgency,
            deadline: deadline,
            consequence: consequence,
            effort: effort,
            contextFit: contextFit,
            goalRelationship: goalRelationship,
            userPreference: userPreference,
            capacity: capacity,
            recoveryState: recoveryState,
            overallPressure: overall,
            summary: "Priority reality keeps importance, urgency, deadline, consequence, effort, context, capacity, and recovery separate."
        )
    }

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
            return [.init(id: "recommend.protect-window", title: "Protect a work window", summary: "Use Plan later to place a user-confirmed block if this still matters.", correctionAction: .changeUrgency)]
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

    func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: return 0
        case .low: return 1
        case .moderate: return 2
        case .elevated: return 3
        case .high: return 4
        case .critical: return 5
        }
    }

    func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}
