import Foundation

struct StepCandidateFieldGenerator: Sendable {
    func generate(_ context: CandidateGenerationContext) -> StepCandidateField {
        let sourceSteps = resolvedSourceSteps(for: context)
        let factorLedger = context.resolvedFactorLedger
        let missingContext = hasMissingContext(context: context, factorLedger: factorLedger)
        let rejectionHistory = context.rejectionHistory
        let contextFingerprint = context.contextFingerprint

        var candidates: [StepCandidate] = []
        for sourceStep in sourceSteps {
            candidates.append(contentsOf: generateVariants(
                for: sourceStep,
                context: context,
                factorLedger: factorLedger,
                missingContext: missingContext,
                rejectionHistory: rejectionHistory
            ))
        }

        if shouldAddFallbackCandidate(sourceSteps: sourceSteps, context: context, missingContext: missingContext) {
            let fallbackSourceStep = sourceSteps.first ?? syntheticSourceStep(for: context)
            candidates.append(
                makeCandidate(
                    kind: .fallback,
                    sourceStep: fallbackSourceStep,
                    context: context,
                    factorLedger: factorLedger,
                    missingContext: true,
                    rejectionHistory: rejectionHistory
                )
            )
        }

        let dedupedResult = deduplicate(candidates)
        let deduped = dedupedResult.candidates
        let suppressedRejectedIDs = Set(
            rejectionHistory
                .filter { $0.contextFingerprint == contextFingerprint }
                .map(\.candidateID)
        )
        let filtered = deduped.filter { suppressedRejectedIDs.contains($0.id) == false }
        let activeCandidates = filtered.isEmpty
            ? [
                makeCandidate(
                    kind: .fallback,
                    sourceStep: syntheticSourceStep(for: context),
                    context: context,
                    factorLedger: factorLedger,
                    missingContext: true,
                    rejectionHistory: rejectionHistory
                )
            ]
            : filtered
        let sorted = activeCandidates.sorted(by: rankCandidates(lhs:rhs:))
        let limited = Array(sorted.prefix(context.candidateLimit))
        let selected = limited.first ?? makeCandidate(
            kind: .fallback,
            sourceStep: syntheticSourceStep(for: context),
            context: context,
            factorLedger: factorLedger,
            missingContext: true,
            rejectionHistory: rejectionHistory
        )
        let rankedIDs = limited.map(\.id)
        let rejectedIDs = Array(sorted.dropFirst().map(\.id))
        let factorEvidenceIDs = Array(Set(limited.flatMap { $0.score.evidenceFactorIDs })).sorted()
        let replayFingerprint = factorLedger?.replayProjection.stableFingerprint
            ?? context.replayTrace?.personalizationFactorLedger.replayProjection.stableFingerprint
            ?? context.runtimeOutput?.personalizationFactorLedger.replayProjection.stableFingerprint
        let rankingTrace = CandidateRankingTrace(
            generatedAt: context.generatedAt,
            selectedCandidateID: selected.id,
            rankedCandidateIDs: rankedIDs,
            rejectedCandidateIDs: rejectedIDs,
            suppressedRejectedCandidateIDs: Array(suppressedRejectedIDs).sorted(),
            duplicateRejectedCandidateIDs: dedupedResult.duplicateRejectedIDs,
            sourceProvenance: context.sourceProvenance,
            factorEvidenceIDs: factorEvidenceIDs,
            replayReferenceID: context.replayTrace?.id ?? context.decisionRecord?.id ?? context.runtimeOutput?.recordID,
            replayFingerprint: replayFingerprint,
            sourceAtlasExpansionTrace: context.sourceAtlasExpansionTrace,
            semanticSummary: rankingSummary(
                selected: selected,
                factorLedger: factorLedger,
                missingContext: missingContext,
                candidateCount: limited.count
            ),
            factorlessRanking: factorEvidenceIDs.isEmpty
        )

        return StepCandidateField(
            goalID: context.goalID,
            deadlineTargetDate: context.deadlineTargetDate ?? earliestTargetDate(in: sourceSteps),
            generatedAt: context.generatedAt,
            sourceProvenance: context.sourceProvenance,
            candidates: limited,
            rankingTrace: rankingTrace,
            sourceAtlasExpansionTrace: context.sourceAtlasExpansionTrace,
            localOnly: context.localOnly
        )
    }
}
