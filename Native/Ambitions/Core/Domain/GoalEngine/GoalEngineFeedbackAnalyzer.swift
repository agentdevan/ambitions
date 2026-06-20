import Foundation

struct GoalEngineFeedbackAnalysis: Sendable, Equatable {
    let signals: GoalFeedbackSignalSnapshot
    let repeatedAvoidance: Bool
    let repeatedConfusion: Bool
    let repeatedIrrelevance: Bool
    let waitingOnExternalDependency: Bool
    let waitingOnDependencyChain: Bool
    let needsReadinessRecovery: Bool
    let hasFragilePlan: Bool
    let wantsSmallerVersion: Bool
    let asksWhyThisMatters: Bool
    let timingPressureMismatch: Bool
    let shouldReduceLearningPressure: Bool
    let shouldSoftenRecoveryApproach: Bool
}

struct GoalEngineFeedbackAnalyzer {
    func analyze(input: GoalAdaptivePlanInput) -> GoalEngineFeedbackAnalysis {
        let stepEvents = input.feedbackHistory.filter { $0.stepID == input.selectedStep.id }
        let avoidanceCount = stepEvents.filter {
            if case let .skipped(_, reasonCode) = $0 {
                return [.avoidance, .tooHard, .notNow].contains(reasonCode)
            }
            return false
        }.count
        let tooBigCount = stepEvents.filter {
            switch $0 {
            case .tooBig, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count
        let confusedCount = stepEvents.filter {
            if case .confused = $0 { return true }
            return false
        }.count
        let notRelevantCount = stepEvents.filter {
            if case .notRelevant = $0 { return true }
            return false
        }.count
        let delayedCount = stepEvents.filter {
            if case .delayed = $0 { return true }
            return false
        }.count
        let askedWhyCount = stepEvents.filter {
            if case .askedWhyThisMatters = $0 { return true }
            return false
        }.count

        let confidenceScore = stepEvents.reduce(0.0) { score, event in
            switch event {
            case let .completed(_, _, _, confidenceDelta):
                return score + (confidenceDelta ?? 0)
            case .confused, .notRelevant:
                return score - 0.25
            case .skipped:
                return score - 0.15
            default:
                return score
            }
        }

        let frictionScore = roundToTwoDecimals(min(3, max(0, Double(avoidanceCount) * 0.3 + Double(tooBigCount) * 0.35 + Double(confusedCount) * 0.28 + Double(delayedCount) * 0.14)))
        let toneDriftDetected = input.currentResult.draft.mode == .delegatedSupport && stepContainsPunitiveLanguage(input.selectedStep)
        let rigidityDetected = timingFeelsRigid(input.selectedStep.timing) && [.learning, .exploration].contains(input.currentResult.draft.mode)
        let roundedConfidence = roundToTwoDecimals(confidenceScore)
        let trend: GoalFeedbackSignalSnapshot.ConfidenceTrend =
            roundedConfidence > 0.35 ? .improving : (roundedConfidence < -0.35 ? .eroding : .flat)
        let primaryCauseOfDrift = primaryCauseOfDrift(in: stepEvents)
        let executionMode = executionMode(
            mode: input.currentResult.draft.mode,
            step: input.selectedStep,
            frictionScore: frictionScore,
            confidenceScore: roundedConfidence
        )
        let narrativeMomentum = narrativeMomentum(
            mode: input.currentResult.draft.mode,
            executionMode: executionMode,
            confidenceTrend: trend,
            primaryCauseOfDrift: primaryCauseOfDrift
        )
        let recommendationConfidence = RecommendationConfidence.label(
            for: confidenceLabelScore(
                confidenceScore: roundedConfidence,
                frictionScore: frictionScore,
                causeOfDrift: primaryCauseOfDrift
            )
        )
        let hasFragilePlan = input.currentResult.plan.evaluation?.fragilityLevel == .high
        let waitingOnExternalDependency = primaryCauseOfDrift == .externalDependency
        let waitingOnDependencyChain =
            (!input.selectedStep.dependencyStepIDs.isEmpty && input.selectedStep.state == .blocked) ||
            (!input.selectedStep.dependencyStepIDs.isEmpty && primaryCauseOfDrift == .externalDependency)
        let needsReadinessRecovery = primaryCauseOfDrift == .notReady

        let signals = GoalFeedbackSignalSnapshot(
            avoidanceCount: avoidanceCount,
            tooBigCount: tooBigCount,
            confusedCount: confusedCount,
            notRelevantCount: notRelevantCount,
            delayedCount: delayedCount,
            askedWhyCount: askedWhyCount,
            confidenceScore: roundedConfidence,
            confidenceTrend: trend,
            frictionScore: frictionScore,
            executionMode: executionMode,
            narrativeMomentum: narrativeMomentum,
            primaryCauseOfDrift: primaryCauseOfDrift,
            recommendationConfidence: recommendationConfidence,
            toneDriftDetected: toneDriftDetected,
            rigidityDetected: rigidityDetected
        )

        return GoalEngineFeedbackAnalysis(
            signals: signals,
            repeatedAvoidance: avoidanceCount >= 2 && tooBigCount >= 1,
            repeatedConfusion: confusedCount >= 2,
            repeatedIrrelevance: notRelevantCount >= 2,
            waitingOnExternalDependency: waitingOnExternalDependency,
            waitingOnDependencyChain: waitingOnDependencyChain,
            needsReadinessRecovery: needsReadinessRecovery,
            hasFragilePlan: hasFragilePlan,
            wantsSmallerVersion: tooBigCount >= 1 || hasFragilePlan,
            asksWhyThisMatters: askedWhyCount >= 1,
            timingPressureMismatch: delayedCount >= 1 && input.currentResult.draft.timing.tempo == .untimed && input.selectedStep.timing.timingType != .logWhenDone,
            shouldReduceLearningPressure: [.learning, .exploration].contains(input.currentResult.draft.mode) && (rigidityDetected || delayedCount >= 1 || confusedCount >= 1),
            shouldSoftenRecoveryApproach: input.currentResult.draft.mode == .recovery && (frozenByFriction(frictionScore) || tooBigCount >= 1 || avoidanceCount >= 1 || hasFragilePlan || needsReadinessRecovery)
        )
    }

    private func stepContainsPunitiveLanguage(_ step: Step) -> Bool {
        let combined = [step.title, step.summary ?? "", step.actionability.action].joined(separator: " ").lowercased()
        return combined.range(of: #"\b(make sure|make them|ensure|must|should|force|discipline|keep them on track)\b"#, options: .regularExpression) != nil
    }

    private func timingFeelsRigid(_ timing: GoalTiming) -> Bool {
        timing.timingType == .dueAt || timing.timingType == .targetBy
    }

    private func frozenByFriction(_ score: Double) -> Bool {
        score >= 0.7
    }

    private func roundToTwoDecimals(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    private func primaryCauseOfDrift(in events: [GoalFeedbackEvent]) -> CauseOfDrift? {
        for event in events.reversed() {
            if let cause = event.causeOfDrift {
                return cause
            }
        }
        return nil
    }

    private func executionMode(
        mode: GoalMode,
        step: Step,
        frictionScore: Double,
        confidenceScore: Double
    ) -> ExecutionMode {
        if mode == .recovery || frictionScore >= 0.7 {
            return .recovery
        }
        if mode == .maintenance || step.isRepeatable {
            return .maintenance
        }
        if confidenceScore >= 0.4 && frictionScore < 0.35 {
            return .sprint
        }
        return .standard
    }

    private func narrativeMomentum(
        mode: GoalMode,
        executionMode: ExecutionMode,
        confidenceTrend: GoalFeedbackSignalSnapshot.ConfidenceTrend,
        primaryCauseOfDrift: CauseOfDrift?
    ) -> NarrativeMomentum {
        if executionMode == .recovery || mode == .recovery {
            return .recovering
        }
        if primaryCauseOfDrift == .externalDependency {
            return .waiting
        }
        if executionMode == .maintenance {
            return .stabilizing
        }
        if confidenceTrend == .improving {
            return .accelerating
        }
        return .building
    }

    private func confidenceLabelScore(
        confidenceScore: Double,
        frictionScore: Double,
        causeOfDrift: CauseOfDrift?
    ) -> Double {
        let normalizedConfidence = min(max((confidenceScore + 1) / 2, 0), 1)
        let frictionPenalty = min(frictionScore / 3, 1) * 0.2
        let causeBonus: Double
        switch causeOfDrift {
        case .some(.oversizedStep), .some(.timingPressure):
            causeBonus = 0.08
        case .some(.externalDependency):
            causeBonus = 0.04
        default:
            causeBonus = 0
        }

        return min(max(normalizedConfidence + 0.28 + causeBonus - frictionPenalty, 0), 1)
    }
}
