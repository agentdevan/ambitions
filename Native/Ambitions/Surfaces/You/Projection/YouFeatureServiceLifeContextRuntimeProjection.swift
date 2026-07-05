import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeRuntimeFactorRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        ledger.factors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-runtime-factor-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.humanReadableReason,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: runtimeUseState(for: factor),
                activityLabel: factor.active ? "Active" : "Disabled",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.allowedForRuntimeUse ? "Allowed" : "Blocked",
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeRecommendationInputRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-recommendation-selected",
                title: "Selected candidate",
                detail: ledger.selectedCandidateID,
                sourceLabel: "Runtime output",
                freshness: ledger.replayProjection.canReplay ? .current : .mayNeedReview,
                runtimeUseState: ledger.replayProjection.canReplay ? .used : .needsReview,
                activityLabel: "Selected",
                lastAffectedLabel: "This run",
                runtimePermissionLabel: "Allowed",
                whereUsed: "Candidate competition",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recommendation-rejected",
                title: "Rejected candidates",
                detail: ledger.rejectedCandidateIDs.isEmpty ? "None" : ledger.rejectedCandidateIDs.joined(separator: ", "),
                sourceLabel: "Runtime output",
                freshness: ledger.rejectedCandidateIDs.isEmpty ? .current : .mayNeedReview,
                runtimeUseState: ledger.rejectedCandidateIDs.isEmpty ? .used : .needsReview,
                activityLabel: ledger.rejectedCandidateIDs.isEmpty ? "None rejected" : "Rejected",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Candidate competition",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-recommendation-sources",
                title: "Recommendation inputs",
                detail: ledger.explanationProjection.sourceLabels.isEmpty ? "No source labels yet." : ledger.explanationProjection.sourceLabels.joined(separator: ", "),
                sourceLabel: "Explanation projection",
                freshness: ledger.confidenceBand == .reviewNeeded ? .mayNeedReview : .current,
                runtimeUseState: ledger.confidenceBand == .reviewNeeded ? .needsReview : .used,
                activityLabel: "Explained",
                lastAffectedLabel: ledger.explanationProjection.confidenceLabel,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Why the recommendation changed",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeWhyThisChangesPlanRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-why-summary",
                title: "Why this changes plans",
                detail: ledger.explanationProjection.summary,
                sourceLabel: "Explanation projection",
                freshness: ledger.confidenceBand == .reviewNeeded ? .mayNeedReview : .current,
                runtimeUseState: ledger.confidenceBand == .reviewNeeded ? .needsReview : .used,
                activityLabel: ledger.confidenceBand == .reviewNeeded ? "Needs review" : "Active",
                lastAffectedLabel: ledger.generatedAt,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Path-shaping explanation",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-why-reasons",
                title: "Reason stack",
                detail: ledger.explanationProjection.whyThisChangesPlans.isEmpty ? "No local reasons recorded yet." : ledger.explanationProjection.whyThisChangesPlans.joined(separator: " • "),
                sourceLabel: "Explanation projection",
                freshness: ledger.explanationProjection.whyThisChangesPlans.isEmpty ? .basedOnOlderContext : .current,
                runtimeUseState: ledger.explanationProjection.whyThisChangesPlans.isEmpty ? .needsReview : .used,
                activityLabel: "Active",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Reasons allowed to change the plan",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeRejectedFactorRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let rejectedFactors = ledger.factors.filter {
            $0.allowedForRuntimeUse == false ||
                $0.control.active == false ||
                $0.sensitiveUse.permissionState == .blocked
        }
        if rejectedFactors.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-rejected-empty",
                    title: "Rejected factors",
                    detail: "None yet.",
                    sourceLabel: "Runtime output",
                    freshness: .current,
                    runtimeUseState: .used,
                    activityLabel: "None rejected",
                    lastAffectedLabel: ledger.generatedAt,
                    runtimePermissionLabel: "Allowed",
                    whereUsed: "No factor rejection yet",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return rejectedFactors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-rejected-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.fallbackBehaviorIfRemoved,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: .notUsed,
                activityLabel: "Rejected",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.sensitiveUse.permissionState.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

}
