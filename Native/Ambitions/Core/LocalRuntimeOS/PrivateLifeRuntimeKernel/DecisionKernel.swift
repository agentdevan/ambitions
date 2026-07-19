import Foundation

struct DecisionKernel: Sendable, Equatable {
    let boundary: PrivateLifeRuntimeBoundary

    private let recommendationKernel: RecommendationKernel
    private let closureKernel: ClosureKernel
    private let adaptationKernel: AdaptationKernel
    private let capacityFitKernel: CapacityFitKernel
    private let recoveryKernel: RecoveryKernel
    private let explanationKernel: ExplanationKernel
    private let proofKernel: ProofKernel

    init(boundary: PrivateLifeRuntimeBoundary = .localOnly) {
        self.boundary = boundary
        recommendationKernel = RecommendationKernel(boundary: boundary)
        closureKernel = ClosureKernel()
        adaptationKernel = AdaptationKernel()
        capacityFitKernel = CapacityFitKernel()
        recoveryKernel = RecoveryKernel()
        explanationKernel = ExplanationKernel()
        proofKernel = ProofKernel()
    }

    func evaluate(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionOutput {
        let record = makeDecisionRecord(input)
        let personalizationFactorLedger = record?.personalizationFactorLedger ?? makePersonalizationFactorLedger(
            for: input,
            decisionRecord: nil,
            decisionOutput: nil
        )
        let lifeContextEffect = record?.lifeContextEffect ?? makeLifeContextEffect(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        let lifeContextSignature = record?.lifeContextSignature ?? proofKernel.lifeContextSignature(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )

        return PrivateLifeRuntimeKernelDecisionOutput(
            decisionID: decisionIdentifier(for: input, traceShape: record?.traceShape),
            boundary: boundary,
            canDriveRecommendation: record?.canDriveRecommendation ?? false,
            hasRecommendationTrace: record != nil,
            traceShape: record?.traceShape,
            recordID: record?.id,
            personalizationFactorLedger: personalizationFactorLedger,
            lifeContextEffect: lifeContextEffect,
            lifeContextSignature: lifeContextSignature
        )
    }

    func makeDecisionRecord(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionRecord? {
        guard let recommendationTrace = input.recommendationTrace else {
            return nil
        }

        let canDriveRecommendation = recommendationKernel.canDriveRecommendation(
            traceContext: input.traceContext,
            recommendationTrace: recommendationTrace
        )
        let traceShape = recommendationKernel.traceShape(for: recommendationTrace)
        let personalizationFactorLedger = makePersonalizationFactorLedger(for: input)
        let lifeContextEffect = makeLifeContextEffect(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        let lifeContextSignature = proofKernel.lifeContextSignature(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )

        return PrivateLifeRuntimeKernelDecisionRecord(
            id: decisionIdentifier(for: input, traceShape: traceShape),
            decisionKey: input.decisionKey,
            goalText: input.goalText ?? input.traceContext.goalText,
            traceContext: input.traceContext,
            recommendationTrace: recommendationTrace,
            personalizationFactorLedger: personalizationFactorLedger,
            boundary: boundary,
            canDriveRecommendation: canDriveRecommendation,
            traceShape: traceShape,
            lifeContextEffect: lifeContextEffect,
            lifeContextSignature: lifeContextSignature
        )
    }

    func decisionIdentifier(
        for input: PrivateLifeRuntimeKernelDecisionInput,
        traceShape: String?
    ) -> String {
        let contextSignature = proofKernel.traceContextSignature(input.traceContext)
        let traceSignature = traceShape ?? "missing-trace"
        return [
            "plr",
            "decision",
            boundary.isLocalOnly ? "local-only" : "mixed",
            input.decisionKey.isEmpty ? "anonymous" : input.decisionKey,
            contextSignature,
            traceSignature
        ]
        .joined(separator: ".")
    }

    func makeLifeContextEffect(
        goalText: String?,
        projection: LifeContextRuntimeProjection?
    ) -> PrivateLifeRuntimeLifeContextEffect {
        let closureAssessment = closureKernel.assess(projection: projection)
        let readiness = closureAssessment.readiness
        let signals = adaptationKernel.signals(for: projection, readiness: readiness)
        let capacityFit = capacityFitKernel.evaluate(
            projection: projection,
            readiness: readiness,
            signals: signals
        )
        let recoveryAssessment = recoveryKernel.evaluate(
            projection: projection,
            readiness: readiness,
            signals: signals
        )
        let normalizedGoalTextValue = normalizeGoalText(goalText)
        let startHereTitle = normalizedGoalTextValue ?? "Start here"
        let explanation = explanationKernel.makeExplanation(
            goalText: startHereTitle,
            readiness: readiness,
            projection: projection,
            signals: signals
        )

        return PrivateLifeRuntimeLifeContextEffect(
            readiness: readiness,
            goalText: normalizedGoalTextValue,
            startHereTitle: startHereTitle,
            startHereExplanation: explanation,
            cadence: capacityFit.cadence,
            urgency: capacityFit.urgency,
            milestone: recoveryAssessment.milestone,
            pathwayLabels: projection?.eligibilityModel.compactMap { pathway in
                normalizeGoalText(pathway.sexLeaguePathway) ?? normalizeGoalText(pathway.eligibilityRulesSummary)
            } ?? [],
            sourceFreshnessStates: projection?.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" } ?? [],
            historyFactIDs: projection?.historySummary.map(\.id) ?? [],
            excludedHistoryFactIDs: projection?.excludedHistorySummary.map(\.factID) ?? [],
            excludedHistoryReasons: projection?.excludedHistorySummary.map { $0.reason.rawValue } ?? [],
            missingContextQuestionIDs: projection?.missingContextQuestions.map(\.id) ?? [],
            opportunityAnchorIDs: projection?.availableOpportunityAnchors.map(\.id) ?? []
        )
    }

    func makePersonalizationFactorLedger(
        for input: PrivateLifeRuntimeKernelDecisionInput,
        decisionRecord: PrivateLifeRuntimeKernelDecisionRecord? = nil,
        decisionOutput: PrivateLifeRuntimeKernelDecisionOutput? = nil
    ) -> PersonalizationFactorLedger {
        let userContextVersion = proofKernel.lifeContextSignature(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        return PersonalizationFactorLedgerBuilder().build(
            PersonalizationFactorLedgerInput(
                goalID: input.traceContext.goalIntelligenceContext?.goalID,
                goalText: input.goalText ?? input.traceContext.goalText,
                projection: input.traceContext.lifeContextProjection,
                recommendationTrace: input.recommendationTrace,
                decisionRecord: decisionRecord,
                decisionOutput: decisionOutput,
                generatedAt: input.traceContext.runtimeContext.externalSurfaceSnapshot
                    .flatMap { DomainTimestamp.date(from: $0.generatedAt) }
                    ?? Date(timeIntervalSince1970: 0),
                runtimeVersion: "private_life_runtime.factor_ledger.v1",
                userContextVersion: userContextVersion
            )
        )
    }

    private func normalizeGoalText(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }
}

extension PrivateLifeRuntimeKernel {
    func evaluate(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionOutput {
        DecisionKernel(boundary: boundary).evaluate(input)
    }

    func makeDecisionRecord(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionRecord? {
        DecisionKernel(boundary: boundary).makeDecisionRecord(input)
    }
}
