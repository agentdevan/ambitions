import Foundation

extension GoalBelievabilityProjector {
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
}
