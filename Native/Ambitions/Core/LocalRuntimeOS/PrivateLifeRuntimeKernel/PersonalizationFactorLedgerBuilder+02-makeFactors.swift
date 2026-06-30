import Foundation

extension PersonalizationFactorLedgerBuilder {
    func makeFactors(
        input: PersonalizationFactorLedgerInput,
        selectedCandidateID: String
    ) -> [PersonalizationFactorLedgerFactor] {
        var factors: [PersonalizationFactorLedgerFactor] = []
        let projection = input.projection
        let trace = input.recommendationTrace
        let record = input.decisionRecord
        let output = input.decisionOutput
        let lifeContextFreshness = freshnessState(for: projection)
        let runtimeSelectedLabel = output.map { "This run: \($0.decisionID)" } ?? "This run"

        if let goalText = input.goalText ?? record?.goalText {
            factors.append(
                factor(
                    id: "factor.goal_requirement",
                    type: .goalRequirement,
                    category: .goal,
                    reason: goalText.isEmpty ? "The runtime needs a goal thread." : "The goal thread is \(goalText).",
                    source: sourceProjection(
                        kind: .recommendationTrace,
                        sourceID: trace?.id ?? record?.id ?? "goal-thread",
                        label: "Goal thread",
                        freshness: lifeContextFreshness,
                        isSensitive: false,
                        isUserOwned: true
                    ),
                    freshness: PersonalizationFactorFreshnessProjection(
                        state: lifeContextFreshness,
                        lastAffectedLabel: runtimeSelectedLabel,
                        needsReview: lifeContextFreshness != .current,
                        reviewReason: lifeContextFreshness == .current ? nil : "The goal thread needs a fresh check."
                    ),
                    userControlled: true,
                    runtimeWeight: 1,
                    affectedRecommendationArea: "Goal thread",
                    allowedForRuntimeUse: true,
                    canDisable: false,
                    fallbackBehaviorIfRemoved: "Keep the recommendation grounded in the user-owned goal thread.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [trace?.reason.explanationID ?? ""]
                )
            )
        }

        if let deadlinePressure = deadlinePressureReason(goalText: input.goalText ?? record?.goalText, projection: projection, trace: trace) {
            factors.append(
                factor(
                    id: "factor.deadline_pressure",
                    type: .deadlinePressure,
                    category: .timing,
                    reason: deadlinePressure,
                    source: sourceProjection(
                        kind: .recommendationTrace,
                        sourceID: trace?.id ?? record?.id ?? "deadline-pressure",
                        label: "Deadline pressure",
                        freshness: lifeContextFreshness,
                        isSensitive: false
                    ),
                    freshness: PersonalizationFactorFreshnessProjection(
                        state: lifeContextFreshness,
                        lastAffectedLabel: runtimeSelectedLabel,
                        needsReview: lifeContextFreshness != .current,
                        reviewReason: lifeContextFreshness == .current ? nil : "Deadline pressure should be refreshed with current context."
                    ),
                    userControlled: true,
                    runtimeWeight: 0.95,
                    affectedRecommendationArea: "Timing",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use a slower timing assumption until the deadline pressure is restated.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [deadlinePressure, trace?.reason.explanationID ?? ""]
                )
            )
        }

        appendAccessAndOpportunityFactors(
            to: &factors,
            projection: projection,
            runtimeSelectedLabel: runtimeSelectedLabel
        )
        appendHistoryAndConstraintFactors(
            to: &factors,
            projection: projection
        )
        appendEligibilitySourceAndProofFactors(
            to: &factors,
            projection: projection,
            trace: trace,
            record: record,
            output: output,
            runtimeSelectedLabel: runtimeSelectedLabel
        )

        return factors.sorted { lhs, rhs in
            if lhs.factorType.rawValue != rhs.factorType.rawValue {
                return lhs.factorType.rawValue < rhs.factorType.rawValue
            }
            return lhs.id < rhs.id
        }
    }
}
