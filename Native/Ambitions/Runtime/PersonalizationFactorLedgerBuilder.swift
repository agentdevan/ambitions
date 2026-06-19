import Foundation

struct PersonalizationFactorLedgerInput: Sendable {
    let goalID: String?
    let goalText: String?
    let projection: LifeContextRuntimeProjection?
    let recommendationTrace: RecommendationTrace?
    let decisionRecord: PrivateLifeRuntimeKernelDecisionRecord?
    let decisionOutput: PrivateLifeRuntimeKernelDecisionOutput?
    let generatedAt: Date
    let runtimeVersion: String
    let userContextVersion: String

    init(
        goalID: String? = nil,
        goalText: String? = nil,
        projection: LifeContextRuntimeProjection? = nil,
        recommendationTrace: RecommendationTrace? = nil,
        decisionRecord: PrivateLifeRuntimeKernelDecisionRecord? = nil,
        decisionOutput: PrivateLifeRuntimeKernelDecisionOutput? = nil,
        generatedAt: Date = .now,
        runtimeVersion: String = "private_life_runtime.factor_ledger.v1",
        userContextVersion: String = ""
    ) {
        self.goalID = goalID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalText = goalText?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.projection = projection
        self.recommendationTrace = recommendationTrace
        self.decisionRecord = decisionRecord
        self.decisionOutput = decisionOutput
        self.generatedAt = generatedAt
        self.runtimeVersion = runtimeVersion
        self.userContextVersion = userContextVersion
    }
}

struct PersonalizationFactorLedgerBuilder: Sendable {
    func build(_ input: PersonalizationFactorLedgerInput) -> PersonalizationFactorLedger {
        let generatedAt = DomainTimestamp.string(from: input.generatedAt)
        let goalText = input.goalText ?? input.decisionRecord?.goalText
        let projection = input.projection
        let selectedCandidateID = selectedCandidateID(for: input)
        let factors = makeFactors(input: input, selectedCandidateID: selectedCandidateID)
        let rejectedCandidateIDs = rejectedCandidateIDs(for: factors, selectedCandidateID: selectedCandidateID)
        let confidenceBand = confidenceBand(for: projection, factors: factors)
        let summarySourceIDs = sourceIDs(for: factors)
        let summarySourceKinds = sourceKinds(for: factors)
        let sourceProjection = PersonalizationFactorLedgerSourceProjection(
            sourceIDs: summarySourceIDs,
            sourceKinds: summarySourceKinds,
            currentFactorCount: factors.filter { $0.freshness.state == .current }.count,
            reviewFactorCount: factors.filter { $0.freshness.needsReview }.count,
            blockedFactorCount: factors.filter { $0.allowedForRuntimeUse == false }.count
        )
        let freshnessProjection = PersonalizationFactorLedgerFreshnessProjection(
            currentFactorCount: factors.filter { $0.freshness.state == .current }.count,
            needsReviewFactorCount: factors.filter { $0.freshness.needsReview }.count,
            staleFactorCount: factors.filter { $0.freshness.state == .stale }.count
        )
        let controlProjection = PersonalizationFactorLedgerControlProjection(
            userControlledFactorIDs: factors.filter(\.userControlled).map(\.id).sorted(),
            disabledFactorIDs: factors.filter { $0.allowedForRuntimeUse == false || $0.control.active == false }.map(\.id).sorted(),
            blockedFactorIDs: factors.filter { $0.allowedForRuntimeUse == false }.map(\.id).sorted()
        )
        let sensitiveFactorUsage = PersonalizationFactorLedgerSensitiveUseProjection(
            usedFactorIDs: factors.filter { $0.sensitiveUse.isSensitive && $0.allowedForRuntimeUse }.map(\.id).sorted(),
            blockedFactorIDs: factors.filter { $0.sensitiveUse.isSensitive && $0.allowedForRuntimeUse == false }.map(\.id).sorted(),
            permissionRequiredFactorIDs: factors.filter { $0.sensitiveUse.permissionState != .allowed }.map(\.id).sorted(),
            redactedFactorIDs: factors.filter { $0.sensitiveUse.redactedReason != nil }.map(\.id).sorted()
        )
        let explanationProjection = PersonalizationFactorLedgerExplanationProjection(
            summary: explanationSummary(goalText: goalText, confidenceBand: confidenceBand, factors: factors),
            sourceLabels: Array(Set(factors.map { $0.source.sourceLabel }.filter { $0.isEmpty == false })).sorted(),
            whyThisChangesPlans: factors
                .filter { $0.allowedForRuntimeUse }
                .prefix(5)
                .map { "\($0.factorType.rawValue): \($0.humanReadableReason)" },
            confidenceLabel: confidenceBand.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        )
        let replayProjection = PersonalizationFactorLedgerReplayProjection(
            canReplay: factors.allSatisfy { $0.replay.isReplayable },
            stableFingerprint: stableFingerprint(
                userContextVersion: input.userContextVersion.isEmpty ? userContextVersion(from: projection) : input.userContextVersion,
                factors: factors,
                rejectedCandidateIDs: rejectedCandidateIDs
            ),
            stableFactorIDs: factors.map(\.id).sorted(),
            selectedCandidateID: selectedCandidateID,
            rejectedCandidateIDs: rejectedCandidateIDs
        )
        let personalRuntimeLearningSignals = makePersonalRuntimeLearningSignals(input: input)

        return PersonalizationFactorLedger(
            recommendationID: selectedCandidateID,
            generatedAt: generatedAt,
            runtimeVersion: input.runtimeVersion,
            userContextVersion: input.userContextVersion.isEmpty ? userContextVersion(from: projection) : input.userContextVersion,
            goalID: input.goalID,
            selectedCandidateID: selectedCandidateID,
            rejectedCandidateIDs: rejectedCandidateIDs,
            factors: factors,
            confidenceBand: confidenceBand,
            missingContextQuestions: projection?.missingContextQuestions.map(\.id).sorted() ?? [],
            sensitiveFactorUsage: sensitiveFactorUsage,
            explanationProjection: explanationProjection,
            replayProjection: replayProjection,
            personalRuntimeLearningSignals: personalRuntimeLearningSignals,
            sourceProjection: sourceProjection,
            freshnessProjection: freshnessProjection,
            controlProjection: controlProjection
        )
    }
}
