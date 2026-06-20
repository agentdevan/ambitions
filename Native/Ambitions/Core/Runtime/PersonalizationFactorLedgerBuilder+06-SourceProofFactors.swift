import Foundation

extension PersonalizationFactorLedgerBuilder {
    func appendEligibilitySourceAndProofFactors(
        to factors: inout [PersonalizationFactorLedgerFactor],
        projection: LifeContextRuntimeProjection?,
        trace: RecommendationTrace?,
        record: PrivateLifeRuntimeKernelDecisionRecord?,
        output: PrivateLifeRuntimeKernelDecisionOutput?,
        runtimeSelectedLabel: String
    ) {
        if let eligibilityModel = projection?.eligibilityModel, eligibilityModel.isEmpty == false {
            let pathwaySummary = eligibilityModel.map { pathway in
                [
                    pathway.pathwayType.rawValue,
                    pathway.eligibilityRulesSummary,
                    pathway.userConfirmed ? "confirmed" : "review"
                ]
                .joined(separator: ":")
            }.sorted()
            factors.append(
                factor(
                    id: "factor.eligibility_pathway",
                    type: .eligibilityPathway,
                    category: .eligibility,
                    reason: "Eligibility pathways stay tied to the user-confirmed rules, not a demographic bucket.",
                    source: sourceProjection(kind: .lifeContext, sourceID: eligibilityModel.first?.id ?? "eligibility", label: "Eligibility & pathways", freshness: freshnessState(for: projection), isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Eligibility", fallbackReason: "Eligibility should be reviewed when the pathway changes."),
                    userControlled: true,
                    runtimeWeight: 0.8,
                    affectedRecommendationArea: "Eligibility",
                    allowedForRuntimeUse: eligibilityModel.contains(where: { $0.userConfirmed || $0.locationDependent }) || projection?.missingContextQuestions.isEmpty == true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Wait for a user-confirmed pathway before making a pathway-specific recommendation.",
                    active: eligibilityModel.contains(where: { $0.userConfirmed || $0.locationDependent }),
                    sensitive: .init(isSensitive: false, permissionState: eligibilityModel.contains(where: { $0.userConfirmed || $0.locationDependent }) ? .allowed : .needsReview, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                    replaySeed: pathwaySummary
                )
            )
        }

        if let sources = projection?.sourceFreshnessSummary, sources.isEmpty == false {
            let staleSources = sources.filter { $0.freshness != .current }
            if staleSources.isEmpty == false {
                factors.append(
                    factor(
                        id: "factor.recent_drift",
                        type: .recentDrift,
                        category: .freshness,
                        reason: "Some source context is \(staleSources.first?.freshness.rawValue.replacingOccurrences(of: "_", with: " ") ?? "not current").",
                        source: sourceProjection(kind: .lifeContext, sourceID: staleSources.first?.sourceID ?? "source-freshness", label: "Source freshness", freshness: freshestState(for: sources), isSensitive: false),
                        freshness: PersonalizationFactorFreshnessProjection(
                            state: staleSources.contains(where: { $0.freshness == .stale }) ? .stale : .mayNeedReview,
                            lastAffectedLabel: runtimeSelectedLabel,
                            needsReview: true,
                            reviewReason: "Older context should be reviewed before the runtime reuses it."
                        ),
                        userControlled: true,
                        runtimeWeight: 0.85,
                        affectedRecommendationArea: "Freshness",
                        allowedForRuntimeUse: false,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Fall back to current context only and ask for a fresh check.",
                        active: false,
                        sensitive: .init(isSensitive: false, permissionState: .blocked, sensitiveUseLabel: "Freshness needs review", redactedReason: nil),
                        replaySeed: staleSources.map { "\($0.sourceID):\($0.freshness.rawValue)" }
                    )
                )
            }
        }

        if let sensitiveWarnings = projection?.sensitiveUseWarnings, sensitiveWarnings.isEmpty == false {
            factors.append(
                factor(
                    id: "factor.safety_constraint",
                    type: .safetyConstraint,
                    category: .safety,
                    reason: "Sensitive context is present and needs explicit permission before runtime use.",
                    source: sourceProjection(kind: .lifeContext, sourceID: sensitiveWarnings.first?.factID ?? "sensitive", label: "Sensitive context", freshness: .mayNeedReview, isSensitive: true),
                    freshness: freshnessProjection(for: projection, area: "Sensitive context", fallbackReason: "Sensitive context needs explicit permission."),
                    userControlled: true,
                    runtimeWeight: 1,
                    affectedRecommendationArea: "Safety",
                    allowedForRuntimeUse: false,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use non-sensitive context and the safest visible fallback.",
                    active: false,
                    sensitive: .init(
                        isSensitive: true,
                        permissionState: .blocked,
                        sensitiveUseLabel: "Sensitive context blocked",
                        redactedReason: "Sensitive context is summarized without the private detail."
                    ),
                    replaySeed: sensitiveWarnings.map(\.factID)
                )
            )
        }

        if let output = output, output.hasRecommendationTrace == false {
            factors.append(
                factor(
                    id: "factor.recent_proof",
                    type: .recentProof,
                    category: .proof,
                    reason: "The current output has no recommendation trace, so the proof seam stays conservative.",
                    source: sourceProjection(kind: .runtime, sourceID: output.decisionID, label: "Runtime proof seam", freshness: .mayNeedReview, isSensitive: false, isUserOwned: false),
                    freshness: PersonalizationFactorFreshnessProjection(state: .mayNeedReview, lastAffectedLabel: runtimeSelectedLabel, needsReview: true, reviewReason: "Proof is incomplete until the recommendation trace is present."),
                    userControlled: false,
                    runtimeWeight: 0.5,
                    affectedRecommendationArea: "Proof",
                    allowedForRuntimeUse: false,
                    canDisable: false,
                    fallbackBehaviorIfRemoved: "Wait for the recommendation trace to be attached.",
                    active: false,
                    sensitive: .init(isSensitive: false, permissionState: .needsReview, sensitiveUseLabel: "Proof needs review", redactedReason: nil),
                    replaySeed: [output.decisionID]
                )
            )
        } else if let trace = trace, let record = record {
            factors.append(
                factor(
                    id: "factor.recent_proof",
                    type: .recentProof,
                    category: .proof,
                    reason: "The recommendation trace includes receipt and proof references.",
                    source: sourceProjection(kind: .receipt, sourceID: record.id, label: "Receipt and proof", freshness: .current, isSensitive: false, isUserOwned: true),
                    freshness: PersonalizationFactorFreshnessProjection(state: .current, lastAffectedLabel: runtimeSelectedLabel, needsReview: false, reviewReason: nil),
                    userControlled: true,
                    runtimeWeight: 0.9,
                    affectedRecommendationArea: "Proof",
                    allowedForRuntimeUse: trace.receiptBehavior.satisfiesTraceContract,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use the local recommendation explanation without proof-backed confidence.",
                    active: trace.receiptBehavior.satisfiesTraceContract,
                    sensitive: .init(isSensitive: false, permissionState: trace.receiptBehavior.satisfiesTraceContract ? .allowed : .needsReview, sensitiveUseLabel: "Receipt-backed proof", redactedReason: nil),
                    replaySeed: trace.receiptBehavior.receiptIDs + trace.receiptBehavior.actionReceiptIDs + trace.receiptBehavior.proofReferenceIDs
                )
            )
        }

        if let trace = trace {
            factors.append(
                factor(
                    id: "factor.trust_allowance.trace",
                    type: .trustAllowance,
                    category: .trust,
                    reason: trace.source.canSupportRecommendation ? "The trace source supports the recommendation." : "The trace source needs review before it can support the recommendation.",
                    source: sourceProjection(kind: .recommendationTrace, sourceID: trace.id, label: "Recommendation trace", freshness: trace.source.canSupportRecommendation ? .current : .mayNeedReview, isSensitive: false),
                    freshness: PersonalizationFactorFreshnessProjection(state: trace.source.canSupportRecommendation ? .current : .mayNeedReview, lastAffectedLabel: runtimeSelectedLabel, needsReview: trace.source.canSupportRecommendation == false, reviewReason: trace.source.canSupportRecommendation ? nil : "Trace source support needs review."),
                    userControlled: true,
                    runtimeWeight: trace.source.canSupportRecommendation ? 0.8 : 0.4,
                    affectedRecommendationArea: "Trust",
                    allowedForRuntimeUse: trace.source.canSupportRecommendation,
                    canDisable: false,
                    fallbackBehaviorIfRemoved: "Use the current local context without trace-backed trust.",
                    active: trace.source.canSupportRecommendation,
                    sensitive: .init(isSensitive: false, permissionState: trace.source.canSupportRecommendation ? .allowed : .needsReview, sensitiveUseLabel: "Trace trust", redactedReason: nil),
                    replaySeed: trace.source.citedSourceIDs + trace.source.sourceAtlasBlockReasons + trace.source.localEvidenceCategories.map(\.rawValue)
                )
            )
        }
    }
}
