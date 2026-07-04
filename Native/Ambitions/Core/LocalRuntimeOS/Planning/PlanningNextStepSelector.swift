import Foundation

struct PlanningNextStepSelector: Sendable {
    let evaluator = PlanningEvaluator()
    let learningService: LearningAnticipationService
    let sharedLifeService: SharedLifeCoordinationService
    let energyFitService: any GoalEnergyFitEvaluating
    let energyLearningService: any GoalEnergyLearning

    init(
        learningService: LearningAnticipationService = LearningAnticipationService(),
        sharedLifeService: SharedLifeCoordinationService = SharedLifeCoordinationService(),
        energyFitService: any GoalEnergyFitEvaluating = DefaultGoalEnergyFitService(),
        energyLearningService: any GoalEnergyLearning = DefaultGoalEnergyLearningService()
    ) {
        self.learningService = learningService
        self.sharedLifeService = sharedLifeService
        self.energyFitService = energyFitService
        self.energyLearningService = energyLearningService
    }

    func rankedSelections(
        goals: [Goal],
        evidence: [ProgressEvidence] = [],
        feedback: [GoalFeedbackEvent] = [],
        canonicalEnergyModelsByGoalID: [String: GoalEnergyModel] = [:],
        now: Date
    ) -> [PlanningNextStepSelection] {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let learningSnapshot = learningService.buildSnapshot(
            goals: activeGoals,
            evidence: evidence,
            feedback: feedback,
            now: now
        )
        let sharedLifeSnapshot = sharedLifeService.buildSnapshot(
            goals: activeGoals,
            evidence: evidence,
            feedback: feedback,
            now: now
        )
        let selections = activeGoals.flatMap { goal -> [PlanningNextStepSelection] in
            guard let plan = goal.plan else { return [] }
            let draft = GoalDraft(
                schemaVersion: goal.schemaVersion,
                source: .derived,
                title: goal.title,
                summary: goal.summary,
                mode: goal.mode,
                relationshipKind: goal.relationshipKind,
                actor: goal.actor,
                parentGoalID: goal.parentGoalID,
                tags: goal.tags,
                timing: goal.timing,
                planningStrategy: goal.planningStrategy,
                progressStrategy: goal.progressStrategy,
                lifeGraph: goal.lifeGraph
            )
            let sharedLifeSummary = sharedLifeSnapshot.goalSummaries[goal.id]
            let evaluation = plan.evaluation ?? evaluator.evaluate(
                draft: draft,
                plan: plan,
                pathStateSummary: LifeGraphResolver.pathStateSummary(for: goal),
                sharedLifeSummary: sharedLifeSummary
            )
            let completedStepIDs = Set(plan.sections.flatMap(\.steps).filter { $0.state == .completed }.map(\.id))
            return plan.sections.flatMap(\.steps)
                .filter { $0.state != .completed && $0.state != .cancelled }
                .map { step in
                    let insight = learningService.learnedStepInsight(
                        goal: goal,
                        step: step,
                        snapshot: learningSnapshot,
                        now: now
                    )
                    let energyFit = energyFitService.planningSummary(
                        for: step,
                        goal: goal,
                        evaluation: evaluation,
                        canonicalEnergyModel: canonicalEnergyModelsByGoalID[goal.id]
                    )
                    let hasIncompleteDependencies = hasIncompleteDependencies(step: step, completedStepIDs: completedStepIDs)
                    let energyLearning: PlanningEnergyLearningSummary? = {
                        guard step.state != .blocked, hasIncompleteDependencies == false else { return nil }
                        return energyLearningService.planningSummary(
                            for: step,
                            goal: goal,
                            evidence: evidence,
                            feedback: feedback,
                            canonicalEnergyModel: canonicalEnergyModelsByGoalID[goal.id],
                            energyFit: energyFit,
                            now: now
                        )
                    }()
                    return PlanningNextStepSelection(
                        goal: goal,
                        step: step,
                        candidate: PlanningNextStepCandidate(
                            goalID: goal.id,
                            stepID: step.id,
                            score: score(
                                goal: goal,
                                step: step,
                                evaluation: evaluation,
                                hasIncompleteDependencies: hasIncompleteDependencies,
                                energyLearning: energyLearning,
                                sharedLifeSummary: sharedLifeSummary,
                                now: now
                            ),
                            timingKey: timingKey(for: step.timing, goalMode: goal.mode),
                            evaluation: evaluation,
                            learnedFitScore: insight.fitScore,
                            whyNow: insight.whyNow,
                            timelineRiskScore: learningSnapshot.goalSummaries[goal.id]?.timelineRisk.riskScore,
                            energyFit: energyFit,
                            energyLearning: energyLearning,
                            ruleTrace: ruleTrace(
                                goal: goal,
                                step: step,
                                evaluation: evaluation,
                                hasIncompleteDependencies: hasIncompleteDependencies,
                                learnedFitScore: insight.fitScore,
                                timelineRiskScore: learningSnapshot.goalSummaries[goal.id]?.timelineRisk.riskScore,
                                energyFit: energyFit,
                                energyLearning: energyLearning,
                                sharedLifeSummary: sharedLifeSummary,
                                now: now
                            )
                        )
                    )
                }
        }

        return selections.sorted { lhs, rhs in
            if lhs.candidate.score != rhs.candidate.score { return lhs.candidate.score > rhs.candidate.score }
            if lhs.candidate.timingKey != rhs.candidate.timingKey { return lhs.candidate.timingKey < rhs.candidate.timingKey }
            if lhs.goal.id != rhs.goal.id { return lhs.goal.id < rhs.goal.id }
            return lhs.step.id < rhs.step.id
        }
    }

    func bestSelection(
        goals: [Goal],
        evidence: [ProgressEvidence] = [],
        feedback: [GoalFeedbackEvent] = [],
        canonicalEnergyModelsByGoalID: [String: GoalEnergyModel] = [:],
        now: Date
    ) -> PlanningNextStepSelection? {
        rankedSelections(
            goals: goals,
            evidence: evidence,
            feedback: feedback,
            canonicalEnergyModelsByGoalID: canonicalEnergyModelsByGoalID,
            now: now
        ).first
    }

    func score(
        goal: Goal,
        step: Step,
        evaluation: PlanningEvaluation,
        hasIncompleteDependencies: Bool,
        energyLearning: PlanningEnergyLearningSummary?,
        sharedLifeSummary: SharedLifeGoalSummary?,
        now: Date
    ) -> Double {
        var value = 0.5
        switch evaluation.feasibilityLevel {
        case .comfortable:
            value += 0.24
        case .tight:
            value += 0.16
        case .fragile:
            value += 0.08
        case .notBelievable:
            value -= 0.12
        }
        switch step.state {
        case .active:
            value += 0.16
        case .blocked:
            value -= 0.18
        case .planned, .completed, .cancelled:
            break
        }
        if hasIncompleteDependencies {
            value -= 0.24
        }
        if evaluation.fragilityLevel == .high && step.state != .active {
            value -= 0.08
        }
        switch urgency(for: step.timing, now: now) {
        case .overdue:
            value += 0.18
        case .soon:
            value += 0.12
        case .normal:
            value += 0.04
        case .anytime:
            value += goal.mode == .learning || goal.mode == .exploration ? 0.03 : 0
        }
        if goal.mode == .delegatedSupport {
            value -= 0.04
        }
        if let sharedLifeSummary, sharedLifeSummary.pressureScore >= 0.7 {
            value -= 0.04
        }
        value += energyLearning?.rankingAdjustment ?? 0
        return (value * 100).rounded() / 100
    }

    func ruleTrace(
        goal: Goal,
        step: Step,
        evaluation: PlanningEvaluation,
        hasIncompleteDependencies: Bool,
        learnedFitScore: Double?,
        timelineRiskScore: Double?,
        energyFit: PlanningEnergyFitSummary?,
        energyLearning: PlanningEnergyLearningSummary?,
        sharedLifeSummary: SharedLifeGoalSummary?,
        now: Date
    ) -> PlanningRuleTrace {
        let timingFit = timingFitLabel(for: step.timing, now: now)
        let reviewCadence = reviewCadenceDays(for: goal)
        let contextVector = PlanningRuleContextVector(
            goalMode: goal.mode,
            timingFit: timingFit,
            feasibilityLevel: evaluation.feasibilityLevel,
            fragilityLevel: evaluation.fragilityLevel,
            activeStepState: step.state,
            hasIncompleteDependencies: hasIncompleteDependencies,
            learnedFitScore: learnedFitScore.map(roundToTwoDecimals),
            timelineRiskScore: timelineRiskScore.map(roundToTwoDecimals),
            energyLearningAdjustment: energyLearning.map { roundToTwoDecimals($0.rankingAdjustment) },
            sharedLifePressureScore: sharedLifeSummary.map { roundToTwoDecimals($0.pressureScore) },
            preferredShortSteps: goal.planningStrategy.preferShortSteps,
            reviewCadenceDays: reviewCadence
        )
        let fallbackReasonIDs = fallbackReasons(
            evaluation: evaluation,
            hasIncompleteDependencies: hasIncompleteDependencies,
            learnedFitScore: learnedFitScore,
            energyFit: energyFit,
            energyLearning: energyLearning
        )
        let ruleReasons = [
            "time_fit:\(timingFit)",
            "feasibility:\(evaluation.feasibilityLevel.rawValue)",
            "fragility:\(evaluation.fragilityLevel.rawValue)",
            "confidence:\(evaluation.recommendationConfidence.rawValue)",
            "user_default_short_steps:\(goal.planningStrategy.preferShortSteps)",
            "review_cadence_days:\(contextVector.reviewCadenceDays)"
        ]

        return PlanningRuleTrace(
            id: "planning-rule-trace.\(goal.id).\(step.id)",
            sourceRecordID: "SourceRecord.planning.\(goal.id).\(step.id)",
            receiptID: "Receipt.planning.\(goal.id).\(step.id)",
            replayTraceID: "ReplayTrace.planning.\(goal.id).\(step.id)",
            contextVector: contextVector,
            ruleReasons: ruleReasons,
            fallbackReasonIDs: fallbackReasonIDs,
            confidence: evaluation.recommendationConfidence,
            explanationSummary: "Local deterministic rules ranked this step through inspectable context. Source, receipt, reason, time fit, closure evidence, confidence, and fallback reasons stay visible.",
            controlVisibility: "You / Search Ambitions can inspect sources, reasons, confidence, fallback, and reset or correction controls.",
            inspectionSurfaceTitle: "Search Ambitions",
            localOnly: true
        )
    }

    func fallbackReasons(
        evaluation: PlanningEvaluation,
        hasIncompleteDependencies: Bool,
        learnedFitScore: Double?,
        energyFit: PlanningEnergyFitSummary?,
        energyLearning: PlanningEnergyLearningSummary?
    ) -> [String] {
        var reasons: [String] = []
        if hasIncompleteDependencies {
            reasons.append("dependency_not_complete")
        }
        if evaluation.feasibilityLevel == .notBelievable || evaluation.fragilityLevel == .high {
            reasons.append("plan_fragility_review")
        }
        if learnedFitScore == nil {
            reasons.append("closure_evidence_missing")
        }
        if energyFit == nil {
            reasons.append("time_fit_uses_goal_timing")
        }
        if energyLearning == nil {
            reasons.append("energy_learning_no_adjustment")
        } else if energyLearning?.rankingAdjustment == 0 {
            energyLearning?.reasonCodes.forEach { code in
                reasons.append("energy_learning:\(code.rawValue)")
            }
        }
        return reasons.sorted()
    }

    func timingFitLabel(for timing: GoalTiming, now: Date) -> String {
        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return timing.tempo == .untimed ? "open_window" : "scheduled"
        }

        let delta = reference.timeIntervalSince(now)
        if delta < 0 {
            return "past_target"
        }
        if delta <= 48 * 60 * 60 {
            return "near_term"
        }
        return "scheduled"
    }

    func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    func reviewCadenceDays(for goal: Goal) -> Int {
        goal.timing.progressReviewCadenceDays
            ?? goal.planningStrategy.revisitCadenceDays
            ?? PlanningPace(goalTempo: goal.timing.tempo).defaultReviewCadenceDays
    }

    func hasIncompleteDependencies(step: Step, completedStepIDs: Set<String>) -> Bool {
        step.dependencyStepIDs.contains { completedStepIDs.contains($0) == false }
    }

    enum SelectorUrgency {
        case overdue
        case soon
        case normal
        case anytime
    }

    func urgency(for timing: GoalTiming, now: Date) -> SelectorUrgency {
        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return timing.tempo == .untimed ? .anytime : .normal
        }

        let delta = reference.timeIntervalSince(now)
        if delta < 0 { return .overdue }
        if delta <= 48 * 60 * 60 { return .soon }
        return .normal
    }

    func timingKey(for timing: GoalTiming, goalMode: GoalMode? = nil) -> String {
        if goalMode == .delegatedSupport {
            return timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
        }
        return timing.dueAt ?? timing.targetBy ?? timing.windowStart ?? timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        if let date = DomainTimestamp.date(from: value) { return date }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
