import Foundation

let planningRuleCounterfactualDiffSchemaVersion = "planning_rule_counterfactual_diff.native.v1"

enum PlanningFeasibilityLevel: String, Codable, Sendable {
    case comfortable
    case tight
    case fragile
    case notBelievable = "not_believable"
}

enum PlanningPressureLevel: String, Codable, Sendable {
    case low
    case moderate
    case high
}

enum PlanningFragilityLevel: String, Codable, Sendable {
    case low
    case moderate
    case high
}

enum PlanningEffortPosture: String, Codable, Sendable {
    case gentle
    case steady
    case push
}

struct PlanningEvaluation: Codable, Sendable, Equatable {
    static let schemaVersion = "planning_evaluation.v1"

    let schemaVersion: String
    let feasibilityScore: Double
    let feasibilityLevel: PlanningFeasibilityLevel
    let recommendationConfidence: RecommendationConfidence
    let pressureLevel: PlanningPressureLevel
    let fragilityLevel: PlanningFragilityLevel
    let effortPosture: PlanningEffortPosture
    let reasons: [String]

    init(
        schemaVersion: String = PlanningEvaluation.schemaVersion,
        feasibilityScore: Double,
        feasibilityLevel: PlanningFeasibilityLevel,
        recommendationConfidence: RecommendationConfidence,
        pressureLevel: PlanningPressureLevel,
        fragilityLevel: PlanningFragilityLevel,
        effortPosture: PlanningEffortPosture,
        reasons: [String]
    ) {
        self.schemaVersion = schemaVersion
        self.feasibilityScore = feasibilityScore
        self.feasibilityLevel = feasibilityLevel
        self.recommendationConfidence = recommendationConfidence
        self.pressureLevel = pressureLevel
        self.fragilityLevel = fragilityLevel
        self.effortPosture = effortPosture
        self.reasons = Array(reasons.prefix(3))
    }
}

struct PlanningEvaluator: Sendable {
    func evaluate(
        draft: GoalDraft,
        plan: GoalPlan,
        inference: [String: InferenceMetadata] = [:],
        pathStateSummary: LifePathStateSummary? = nil,
        sharedLifeSummary: SharedLifeGoalSummary? = nil
    ) -> PlanningEvaluation {
        let steps = plan.sections.flatMap(\.steps)
        let incompleteSteps = steps.filter { $0.state != .completed && $0.state != .cancelled }.count
        let warningCount = plan.lint.issues.filter { $0.severity != .info }.count
        let assumptionsCount = plan.assumptions.count
        let confidenceInput = inference.isEmpty
            ? 0.78
            : inference.values.map(\.confidence).reduce(0, +) / Double(max(inference.count, 1))

        let pressure = pressureLevel(draft: draft, incompleteSteps: incompleteSteps)
        let effort = effortPosture(draft: draft, pressure: pressure, assumptionsCount: assumptionsCount)
        let fragility = fragilityLevel(assumptionsCount: assumptionsCount, warningCount: warningCount, pressure: pressure, confidenceInput: confidenceInput)
        let pathRiskCount = pathRiskCount(from: pathStateSummary)
        let sharedLifeRiskCount = sharedLifeRiskCount(from: sharedLifeSummary)
        let score = feasibilityScore(
            pressure: pressure,
            fragility: fragility,
            assumptionsCount: assumptionsCount,
            warningCount: warningCount,
            confidenceInput: confidenceInput,
            incompleteSteps: incompleteSteps,
            pathRiskCount: pathRiskCount,
            sharedLifeRiskCount: sharedLifeRiskCount
        )
        let feasibility = feasibilityLevel(score: score, pressure: pressure, fragility: fragility, pathRiskCount: pathRiskCount + sharedLifeRiskCount)

        return PlanningEvaluation(
            feasibilityScore: score,
            feasibilityLevel: feasibility,
            recommendationConfidence: RecommendationConfidence.label(for: confidenceInput - Double(assumptionsCount) * 0.08 - Double(warningCount) * 0.06),
            pressureLevel: pressure,
            fragilityLevel: fragility,
            effortPosture: effort,
            reasons: reasons(
                draft: draft,
                incompleteSteps: incompleteSteps,
                assumptionsCount: assumptionsCount,
                warningCount: warningCount,
                pressure: pressure,
                fragility: fragility,
                pathStateSummary: pathStateSummary,
                sharedLifeSummary: sharedLifeSummary
            )
        )
    }

    private func pressureLevel(draft: GoalDraft, incompleteSteps: Int) -> PlanningPressureLevel {
        switch draft.timing.tempo {
        case .deadlineBased:
            guard let due = date(from: draft.timing.dueAt ?? draft.timing.targetBy ?? draft.timing.windowEnd),
                  let reference = DomainTimestamp.date(from: draft.timing.startsOn ?? "") ?? date(from: draft.timing.suggestedNextAt ?? "") else {
                return incompleteSteps >= 6 ? .high : .moderate
            }
            let days = Calendar(identifier: .gregorian).dateComponents([.day], from: reference, to: due).day ?? 0
            if days <= 7 || incompleteSteps >= max(6, days / 2) { return .high }
            if days <= 21 || incompleteSteps >= 4 { return .moderate }
            return .low
        case .targetWindow:
            return incompleteSteps >= 6 ? .moderate : .low
        case .ongoing:
            return incompleteSteps >= 5 ? .moderate : .low
        case .untimed:
            return .low
        }
    }

    private func effortPosture(draft: GoalDraft, pressure: PlanningPressureLevel, assumptionsCount: Int) -> PlanningEffortPosture {
        if [.learning, .exploration, .recovery, .delegatedSupport].contains(draft.mode), pressure != .high {
            return .gentle
        }
        if assumptionsCount > 0 {
            return .gentle
        }
        switch pressure {
        case .low:
            return .steady
        case .moderate:
            return .steady
        case .high:
            return .push
        }
    }

    private func fragilityLevel(
        assumptionsCount: Int,
        warningCount: Int,
        pressure: PlanningPressureLevel,
        confidenceInput: Double
    ) -> PlanningFragilityLevel {
        if warningCount >= 2 || assumptionsCount >= 2 || (pressure == .high && confidenceInput < 0.75) {
            return .high
        }
        if warningCount > 0 || assumptionsCount > 0 || pressure == .high || confidenceInput < 0.7 {
            return .moderate
        }
        return .low
    }

    private func feasibilityScore(
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        assumptionsCount: Int,
        warningCount: Int,
        confidenceInput: Double,
        incompleteSteps: Int,
        pathRiskCount: Int,
        sharedLifeRiskCount: Int
    ) -> Double {
        let pressurePenalty: Double = {
            switch pressure {
            case .low: return 0.04
            case .moderate: return 0.18
            case .high: return 0.34
            }
        }()
        let fragilityPenalty: Double = {
            switch fragility {
            case .low: return 0.04
            case .moderate: return 0.18
            case .high: return 0.34
            }
        }()
        let raw = confidenceInput - pressurePenalty - fragilityPenalty - Double(assumptionsCount) * 0.06 - Double(warningCount) * 0.05 - Double(max(incompleteSteps - 8, 0)) * 0.02 - Double(pathRiskCount) * 0.05 - Double(sharedLifeRiskCount) * 0.04
        return (raw * 100).rounded() / 100
    }

    private func feasibilityLevel(
        score: Double,
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        pathRiskCount: Int
    ) -> PlanningFeasibilityLevel {
        if score < 0.34 || (pressure == .high && fragility == .high) || pathRiskCount >= 2 { return .notBelievable }
        if score < 0.52 || fragility == .high { return .fragile }
        if score < 0.72 || pressure == .moderate || fragility == .moderate { return .tight }
        return .comfortable
    }

    private func reasons(
        draft: GoalDraft,
        incompleteSteps: Int,
        assumptionsCount: Int,
        warningCount: Int,
        pressure: PlanningPressureLevel,
        fragility: PlanningFragilityLevel,
        pathStateSummary: LifePathStateSummary?,
        sharedLifeSummary: SharedLifeGoalSummary?
    ) -> [String] {
        var output: [String] = []
        if let pathStateSummary {
            if let prerequisite = pathStateSummary.blockedPrerequisites.first {
                output.append("Path prerequisites are still blocking the current stage: \(prerequisite.title).")
            } else if let gap = pathStateSummary.readiness.gapSignals.first {
                output.append("Readiness gaps are still visible for the active path stage: \(gap.title).")
            }
        }
        if pressure == .high {
            output.append("Deadline pressure is high for the visible step count.")
        } else if draft.timing.tempo == .untimed {
            output.append("The plan is untimed, so pressure stays low.")
        } else {
            output.append("\(incompleteSteps) visible step\(incompleteSteps == 1 ? "" : "s") remain in the current plan.")
        }
        if let sharedLifeSummary, sharedLifeSummary.pressureScore >= 0.6 {
            output.append(sharedLifeSummary.reasons.first ?? "Shared responsibilities are materially shaping the plan.")
        }
        if assumptionsCount > 0 {
            output.append("Starter assumptions reduce confidence.")
        }
        if warningCount > 0 {
            output.append("Plan lint found \(warningCount) risk signal\(warningCount == 1 ? "" : "s").")
        }
        if output.count < 2 {
            output.append(fragility == .low ? "No major fragility signals are present." : "Fragility is visible and should stay explicit.")
        }
        return output
    }

    private func pathRiskCount(from pathStateSummary: LifePathStateSummary?) -> Int {
        guard let pathStateSummary else { return 0 }
        var count = 0
        if pathStateSummary.blockedPrerequisites.isEmpty == false {
            count += 1
        }
        if pathStateSummary.readiness.gapCount > 0 {
            count += 1
        }
        return count
    }

    private func sharedLifeRiskCount(from sharedLifeSummary: SharedLifeGoalSummary?) -> Int {
        guard let sharedLifeSummary else { return 0 }
        var count = 0
        if sharedLifeSummary.careContextActive {
            count += 1
        }
        if sharedLifeSummary.pressureScore >= 0.7 || sharedLifeSummary.coordinationSignals.contains(where: \.isTimed) {
            count += 1
        }
        return count
    }

    private func date(from value: String?) -> Date? {
        guard let value else { return nil }
        if let full = DomainTimestamp.date(from: value) { return full }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}

struct PlanningNextStepCandidate: Codable, Sendable, Equatable {
    let goalID: String
    let stepID: String
    let score: Double
    let timingKey: String
    let evaluation: PlanningEvaluation
    let learnedFitScore: Double?
    let whyNow: WhyNowExplanationMetadata?
    let timelineRiskScore: Double?
    let energyFit: PlanningEnergyFitSummary?
    let energyLearning: PlanningEnergyLearningSummary?
    let ruleTrace: PlanningRuleTrace?
}

struct PlanningRuleTrace: Codable, Sendable, Equatable, Hashable {
    let id: String
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let contextVector: PlanningRuleContextVector
    let ruleReasons: [String]
    let fallbackReasonIDs: [String]
    let confidence: RecommendationConfidence
    let explanationSummary: String
    let controlVisibility: String
    let inspectionSurfaceTitle: String
    let localOnly: Bool

    var localFitLabel: String {
        [
            contextVector.timingFit,
            contextVector.feasibilityLevel.rawValue,
            contextVector.fragilityLevel.rawValue,
            contextVector.activeStepState.rawValue
        ]
        .joined(separator: "|")
    }
}

struct PlanningRuleContextVector: Codable, Sendable, Equatable, Hashable {
    let goalMode: GoalMode
    let timingFit: String
    let feasibilityLevel: PlanningFeasibilityLevel
    let fragilityLevel: PlanningFragilityLevel
    let activeStepState: StepLifecycleState
    let hasIncompleteDependencies: Bool
    let learnedFitScore: Double?
    let timelineRiskScore: Double?
    let energyLearningAdjustment: Double?
    let sharedLifePressureScore: Double?
    let preferredShortSteps: Bool
    let reviewCadenceDays: Int
}

struct PlanningNextStepSelection: Sendable, Equatable {
    let goal: Goal
    let step: Step
    let candidate: PlanningNextStepCandidate
}

struct PlanningRuleCounterfactualDiff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let selectedTraceID: String
    let alternativeTraceID: String
    let selectedStepID: String
    let alternativeStepID: String
    let selectedStepTitle: String
    let alternativeStepTitle: String
    let selectedRank: Double
    let alternativeRank: Double
    let rankDelta: Double
    let selectedLocalFitLabel: String
    let alternativeLocalFitLabel: String
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let runtimeSnapshotReferenceID: String?
    let privacyClass: AFEPStoragePrivacyClass
    let exportPolicy: AFEPExportPolicy
    let redactionClass: RuntimeSnapshotFieldRedactionClass
    let summary: String
    let schemaVersion: String

    init(
        selectedTraceID: String,
        alternativeTraceID: String,
        selectedStepID: String,
        alternativeStepID: String,
        selectedStepTitle: String,
        alternativeStepTitle: String,
        selectedRank: Double,
        alternativeRank: Double,
        selectedLocalFitLabel: String,
        alternativeLocalFitLabel: String,
        sourceRecordID: String,
        receiptID: String,
        replayTraceID: String,
        runtimeSnapshotReferenceID: String? = nil,
        privacyClass: AFEPStoragePrivacyClass = .localOnly,
        exportPolicy: AFEPExportPolicy = .redacted,
        redactionClass: RuntimeSnapshotFieldRedactionClass = .localOnly,
        schemaVersion: String = planningRuleCounterfactualDiffSchemaVersion
    ) {
        self.selectedTraceID = selectedTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeTraceID = alternativeTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedStepID = selectedStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeStepID = alternativeStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedStepTitle = selectedStepTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeStepTitle = alternativeStepTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedRank = selectedRank
        self.alternativeRank = alternativeRank
        self.rankDelta = ((alternativeRank - selectedRank) * 100).rounded() / 100
        self.selectedLocalFitLabel = selectedLocalFitLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.alternativeLocalFitLabel = alternativeLocalFitLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordID = sourceRecordID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRuntimeSnapshotReferenceID = runtimeSnapshotReferenceID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.runtimeSnapshotReferenceID = trimmedRuntimeSnapshotReferenceID?.isEmpty == true ? nil : trimmedRuntimeSnapshotReferenceID
        self.privacyClass = privacyClass
        self.exportPolicy = exportPolicy
        self.redactionClass = redactionClass
        self.summary = "Selected \(self.selectedStepTitle) stays ahead of \(self.alternativeStepTitle) by a deterministic local rank delta."
        self.schemaVersion = schemaVersion
        self.id = "planning-rule-counterfactual.\(self.selectedStepID).\(self.alternativeStepID)"
    }

    var isExportSafe: Bool {
        exportPolicy.isExportSafe && redactionClass != .redacted
    }

    var visibleCopy: [String] {
        [selectedStepTitle, alternativeStepTitle, selectedLocalFitLabel, alternativeLocalFitLabel, summary]
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return lowercased.contains("ai ") ||
                lowercased.contains("assistant") ||
                lowercased.contains("confidence") ||
                text.contains("%")
        }
    }
}

extension PlanningRuleTrace {
    static func counterfactualDiffs(
        selected selectedSelection: PlanningNextStepSelection,
        alternatives: [PlanningNextStepSelection],
        runtimeSnapshotReferenceID: String? = nil
    ) -> [PlanningRuleCounterfactualDiff] {
        let selectedTrace = trace(for: selectedSelection)

        return alternatives.enumerated().map { index, alternative in
            let alternativeTrace = trace(for: alternative)
            return PlanningRuleCounterfactualDiff(
                selectedTraceID: selectedTrace.id,
                alternativeTraceID: alternativeTrace.id,
                selectedStepID: selectedSelection.step.id,
                alternativeStepID: alternative.step.id,
                selectedStepTitle: selectedSelection.step.title,
                alternativeStepTitle: alternative.step.title,
                selectedRank: 0,
                alternativeRank: Double(index + 1),
                selectedLocalFitLabel: selectedTrace.localFitLabel,
                alternativeLocalFitLabel: alternativeTrace.localFitLabel,
                sourceRecordID: selectedTrace.sourceRecordID,
                receiptID: selectedTrace.receiptID,
                replayTraceID: selectedTrace.replayTraceID,
                runtimeSnapshotReferenceID: runtimeSnapshotReferenceID
            )
        }
    }

    private static func trace(for selection: PlanningNextStepSelection) -> PlanningRuleTrace {
        if let ruleTrace = selection.candidate.ruleTrace {
            return ruleTrace
        }

        return PlanningRuleTrace(
            id: "planning-rule-trace.\(selection.goal.id).\(selection.step.id)",
            sourceRecordID: "SourceRecord.planning.\(selection.goal.id).\(selection.step.id)",
            receiptID: "Receipt.planning.\(selection.goal.id).\(selection.step.id)",
            replayTraceID: "ReplayTrace.planning.\(selection.goal.id).\(selection.step.id)",
            contextVector: PlanningRuleContextVector(
                goalMode: selection.goal.mode,
                timingFit: selection.step.timing.timingType.rawValue,
                feasibilityLevel: .tight,
                fragilityLevel: .moderate,
                activeStepState: selection.step.state,
                hasIncompleteDependencies: false,
                learnedFitScore: selection.candidate.learnedFitScore,
                timelineRiskScore: selection.candidate.timelineRiskScore,
                energyLearningAdjustment: selection.candidate.energyLearning?.rankingAdjustment,
                sharedLifePressureScore: nil,
                preferredShortSteps: selection.goal.planningStrategy.preferShortSteps,
                reviewCadenceDays: selection.goal.timing.progressReviewCadenceDays ?? selection.goal.planningStrategy.revisitCadenceDays ?? PlanningPace(goalTempo: selection.goal.timing.tempo).defaultReviewCadenceDays
            ),
            ruleReasons: [],
            fallbackReasonIDs: [],
            confidence: selection.candidate.evaluation.recommendationConfidence,
            explanationSummary: "Local deterministic rules ranked this step.",
            controlVisibility: "You / What Ambitions knows can inspect the local trace.",
            inspectionSurfaceTitle: "What Ambitions knows",
            localOnly: true
        )
    }
}

struct PlanningNextStepSelector: Sendable {
    private let evaluator = PlanningEvaluator()
    private let learningService: LearningAnticipationService
    private let sharedLifeService: SharedLifeCoordinationService
    private let energyFitService: any GoalEnergyFitEvaluating
    private let energyLearningService: any GoalEnergyLearning

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

    private func score(
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

    private func ruleTrace(
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
            explanationSummary: "Local deterministic rules ranked this step through inspectable context. SourceRecord, Receipt, ReplayTrace, time fit, closure evidence, confidence, and fallback reasons stay visible.",
            controlVisibility: "You / What Ambitions knows can inspect sources, reasons, confidence, fallback, and reset or correction controls.",
            inspectionSurfaceTitle: "What Ambitions knows",
            localOnly: true
        )
    }

    private func fallbackReasons(
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

    private func timingFitLabel(for timing: GoalTiming, now: Date) -> String {
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

    private func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    private func reviewCadenceDays(for goal: Goal) -> Int {
        goal.timing.progressReviewCadenceDays
            ?? goal.planningStrategy.revisitCadenceDays
            ?? PlanningPace(goalTempo: goal.timing.tempo).defaultReviewCadenceDays
    }

    private func hasIncompleteDependencies(step: Step, completedStepIDs: Set<String>) -> Bool {
        step.dependencyStepIDs.contains { completedStepIDs.contains($0) == false }
    }

    private enum SelectorUrgency {
        case overdue
        case soon
        case normal
        case anytime
    }

    private func urgency(for timing: GoalTiming, now: Date) -> SelectorUrgency {
        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return timing.tempo == .untimed ? .anytime : .normal
        }

        let delta = reference.timeIntervalSince(now)
        if delta < 0 { return .overdue }
        if delta <= 48 * 60 * 60 { return .soon }
        return .normal
    }

    private func timingKey(for timing: GoalTiming, goalMode: GoalMode? = nil) -> String {
        if goalMode == .delegatedSupport {
            return timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
        }
        return timing.dueAt ?? timing.targetBy ?? timing.windowStart ?? timing.suggestedNextAt ?? "9999-12-31T23:59:59Z"
    }

    private func parseDate(_ value: String?) -> Date? {
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
