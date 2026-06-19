import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeSensitiveContextUsageRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let sensitiveFactors = ledger.factors.filter { $0.sensitiveUse.isSensitive || $0.sensitiveUse.permissionState != .allowed }
        if sensitiveFactors.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-sensitive-empty",
                    title: "Sensitive context",
                    detail: "No sensitive factor is active.",
                    sourceLabel: "Runtime output",
                    freshness: .current,
                    runtimeUseState: .used,
                    activityLabel: "No sensitive use",
                    lastAffectedLabel: ledger.generatedAt,
                    runtimePermissionLabel: "Allowed",
                    whereUsed: "Sensitive inputs stay blocked unless approved",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return sensitiveFactors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-sensitive-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.sensitiveUse.sensitiveUseLabel,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: factor.allowedForRuntimeUse ? .used : .needsReview,
                activityLabel: factor.sensitiveUse.permissionState == .allowed ? "Allowed" : "Blocked",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.sensitiveUse.permissionState.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeContextConfidenceRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-confidence-band",
                title: "Confidence band",
                detail: ledger.confidenceBand.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                sourceLabel: "Runtime output",
                freshness: ledger.confidenceBand == .reviewNeeded ? .mayNeedReview : .current,
                runtimeUseState: ledger.confidenceBand == .reviewNeeded ? .needsReview : .used,
                activityLabel: "Active",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: ledger.replayProjection.canReplay ? "Allowed" : "Blocked",
                whereUsed: "How sure the runtime is",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-confidence-review",
                title: "Needs review",
                detail: ledger.missingContextQuestions.isEmpty ? "No unanswered questions." : ledger.missingContextQuestions.joined(separator: ", "),
                sourceLabel: "Runtime output",
                freshness: ledger.missingContextQuestions.isEmpty ? .current : .mayNeedReview,
                runtimeUseState: ledger.missingContextQuestions.isEmpty ? .used : .needsReview,
                activityLabel: ledger.missingContextQuestions.isEmpty ? "Clear" : "Needs review",
                lastAffectedLabel: ledger.generatedAt,
                runtimePermissionLabel: ledger.missingContextQuestions.isEmpty ? "Allowed" : "Needs review",
                whereUsed: "What still needs attention before trust is higher",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeDisabledFactorRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let disabledFactors = ledger.factors.filter {
            $0.control.active == false || $0.allowedForRuntimeUse == false || $0.sensitiveUse.permissionState == .disabled
        }
        if disabledFactors.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-disabled-empty",
                    title: "Disabled factors",
                    detail: "None yet.",
                    sourceLabel: "Runtime output",
                    freshness: .current,
                    runtimeUseState: .used,
                    activityLabel: "None disabled",
                    lastAffectedLabel: ledger.generatedAt,
                    runtimePermissionLabel: "Allowed",
                    whereUsed: "Nothing has been disabled yet",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return disabledFactors.map { factor in
            makeLifeContextFactRow(
                id: "life-context-disabled-\(factor.id)",
                title: displayLabel(for: factor.factorType),
                detail: factor.fallbackBehaviorIfRemoved,
                sourceLabel: factor.source.sourceLabel,
                freshness: memoryFreshness(for: factor.freshness.state),
                runtimeUseState: .notUsed,
                activityLabel: "Disabled",
                lastAffectedLabel: factor.lastAffectedLabel,
                runtimePermissionLabel: factor.sensitiveUse.permissionState.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                whereUsed: factor.affectedRecommendationArea,
                updateTargets: factorUpdateTargets(for: factor),
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }
    }

    func makeReplayAndReceiptRows(
        ledger: PersonalizationFactorLedger,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-replay-fingerprint",
                title: "Replay fingerprint",
                detail: ledger.replayProjection.stableFingerprint,
                sourceLabel: "Replay projection",
                freshness: ledger.replayProjection.canReplay ? .current : .mayNeedReview,
                runtimeUseState: ledger.replayProjection.canReplay ? .used : .needsReview,
                activityLabel: ledger.replayProjection.canReplay ? "Replayable" : "Needs review",
                lastAffectedLabel: ledger.generatedAt,
                runtimePermissionLabel: ledger.replayProjection.canReplay ? "Allowed" : "Blocked",
                whereUsed: "Deterministic replay",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-replay-candidate",
                title: "Selected / rejected candidates",
                detail: "Selected \(ledger.replayProjection.selectedCandidateID); rejected \(ledger.replayProjection.rejectedCandidateIDs.isEmpty ? "none" : ledger.replayProjection.rejectedCandidateIDs.joined(separator: ", "))",
                sourceLabel: "Replay projection",
                freshness: ledger.replayProjection.canReplay ? .current : .mayNeedReview,
                runtimeUseState: ledger.replayProjection.canReplay ? .used : .needsReview,
                activityLabel: "Replayable",
                lastAffectedLabel: ledger.replayProjection.stableFingerprint,
                runtimePermissionLabel: "Allowed",
                whereUsed: "Selected and rejected candidate memory",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeHistoricalContextRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-experience",
                title: "Prior experience",
                detail: factSummary(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog, .pastAchievement]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog, .pastAchievement]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog, .pastAchievement]),
                whereUsed: "Use only when the facts still feel current",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-attempts",
                title: "Prior attempts",
                detail: factSummary(for: bundle, matching: [.priorAttempt]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorAttempt]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorAttempt]),
                whereUsed: "Avoid repeating dead ends",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-blockers",
                title: "Blockers, injuries, and limitations",
                detail: factSummary(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.injuryLimitation, .healthBaseline, .relationshipDependency]),
                whereUsed: "Protect recovery and safety",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-deadlines",
                title: "Important deadlines and windows",
                detail: deadlineSummary(for: bundle, projection: projection),
                sourceLabel: "Profile and historical facts",
                freshness: deadlineFreshness(for: bundle, projection: projection),
                runtimeUseState: deadlineRuntimeUseState(for: bundle, projection: projection),
                whereUsed: "Keep timing honest",
                updateTargets: [.profile, .historicalFact, .opportunityContext],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-dont-assume",
                title: "Things Ambitions should not assume",
                detail: bundle?.profile.userNotes ?? "No assumptions logged yet.",
                sourceLabel: "Profile notes",
                freshness: bundle?.profile.userNotes == nil ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.userNotes == nil ? .needsReview : .used,
                whereUsed: "Guardrail, not a default fact",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeNeedsReviewRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        var rows: [YouLifeContextFactRow] = [
            makeLifeContextFactRow(
                id: "life-context-older-review",
                title: "Older context that may need review",
                detail: olderContextSummary(for: bundle, projection: projection),
                sourceLabel: "Freshness review",
                freshness: olderContextFreshness(for: bundle, projection: projection),
                runtimeUseState: olderContextRuntimeUseState(for: bundle, projection: projection),
                whereUsed: "Review before runtime use",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]

        rows.append(contentsOf: (projection?.sensitiveUseWarnings ?? []).map { warning in
            makeLifeContextFactRow(
                id: "life-context-sensitive-\(warning.factID)",
                title: warning.title,
                detail: warning.detail,
                sourceLabel: "Sensitive context",
                freshness: .mayNeedReview,
                runtimeUseState: .needsReview,
                whereUsed: "Blocked until you allow runtime use",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        rows.append(contentsOf: (projection?.missingContextQuestions ?? []).map { question in
            makeLifeContextFactRow(
                id: "life-context-question-\(question.id)",
                title: question.prompt,
                detail: question.reason,
                sourceLabel: "Open question",
                freshness: .basedOnOlderContext,
                runtimeUseState: .needsReview,
                whereUsed: "Needs an answer before Ambitions assumes more",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        return rows
    }

    func makePausedOrNotUsedRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let rows = (projection?.excludedHistorySummary ?? []).map { exclusion in
            let title = bundle?.historicalFacts.first(where: { $0.id == exclusion.factID })?.title ?? exclusion.reason.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            return makeLifeContextFactRow(
                id: "life-context-excluded-\(exclusion.factID)",
                title: title,
                detail: exclusion.reason == .deleted ? "Deleted from runtime use." : "Paused from runtime use.",
                sourceLabel: exclusion.reason == .deleted ? "Deleted history" : "Paused history",
                freshness: .basedOnOlderContext,
                runtimeUseState: .notUsed,
                whereUsed: "History only; not runtime input",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }

        if rows.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-excluded-empty",
                    title: "Paused / not used",
                    detail: "No paused or deleted facts yet.",
                    sourceLabel: "History",
                    freshness: .basedOnOlderContext,
                    runtimeUseState: .notUsed,
                    whereUsed: "Nothing is currently excluded",
                    updateTargets: [.historicalFact],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return rows
    }

    func makeReceiptRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let sourceRows = (projection?.sourceFreshnessSummary ?? []).map { source in
            makeLifeContextFactRow(
                id: "life-context-receipt-source-\(source.sourceID)",
                title: source.label,
                detail: source.detail,
                sourceLabel: "Source receipt",
                freshness: memoryFreshness(for: source.freshness),
                runtimeUseState: receiptRuntimeUseState(for: source.freshness),
                whereUsed: "Explains whether this source can currently guide recommendations",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }

        let confirmationRows = (bundle?.eligibilityPathways ?? []).map { pathway in
            makeLifeContextFactRow(
                id: "life-context-receipt-pathway-\(pathway.id)",
                title: pathway.pathwayType.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                detail: pathway.userConfirmed ? "Confirmed by the user." : "Needs confirmation.",
                sourceLabel: "Confirmation receipt",
                freshness: pathway.userConfirmed ? .current : .mayNeedReview,
                runtimeUseState: pathway.userConfirmed ? .used : .needsReview,
                whereUsed: "Shows the pathway was explicitly confirmed",
                updateTargets: [.eligibilityPathway],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        }

        if sourceRows.isEmpty && confirmationRows.isEmpty {
            return [
                makeLifeContextFactRow(
                    id: "life-context-receipts-empty",
                    title: "Receipts",
                    detail: "No source or confirmation receipts yet.",
                    sourceLabel: "Receipt layer",
                    freshness: .basedOnOlderContext,
                    runtimeUseState: .needsReview,
                    whereUsed: "Receipts will appear when context is captured",
                    updateTargets: [.historicalFact, .eligibilityPathway],
                    captureRouteContext: .needsReview,
                    basePath: basePath
                )
            ]
        }

        return sourceRows + confirmationRows
    }

}
