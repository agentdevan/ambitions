import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeHistoryRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        [
            makeLifeContextFactRow(
                id: "life-context-history-experience",
                title: "Prior experience",
                detail: factSummary(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorExperience, .trainingHistory, .workHistory, .creativeCatalog]),
                whereUsed: "Use only when the facts still feel current",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-attempts",
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
                id: "life-context-history-achievements",
                title: "Past achievements",
                detail: factSummary(for: bundle, matching: [.pastAchievement]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.pastAchievement]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.pastAchievement]),
                whereUsed: "Keep proven signals visible",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-progress",
                title: "Old progress",
                detail: factSummary(for: bundle, matching: [.trainingHistory, .educationHistory, .workHistory]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.trainingHistory, .educationHistory, .workHistory]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.trainingHistory, .educationHistory, .workHistory]),
                whereUsed: "Keep older progress visible before Ambitions reuses it",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-history-injuries",
                title: "Injuries / limitations",
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
                id: "life-context-history-tried",
                title: "Already-tried approaches",
                detail: factSummary(for: bundle, matching: [.priorAttempt, .trainingHistory, .workHistory, .creativeCatalog]),
                sourceLabel: "Historical facts",
                freshness: factFreshness(for: bundle, matching: [.priorAttempt, .trainingHistory, .workHistory, .creativeCatalog]),
                runtimeUseState: factRuntimeUseState(for: bundle, matching: [.priorAttempt, .trainingHistory, .workHistory, .creativeCatalog]),
                whereUsed: "Avoid repeating dead ends",
                updateTargets: [.historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        ]
    }

    func makeConstraintsRows(
        bundle: LifeContextBundle?,
        projection: LifeContextRuntimeProjection?,
        basePath: String
    ) -> [YouLifeContextFactRow] {
        let hardConstraints = projection?.hardConstraints ?? []
        let softConstraints = projection?.softConstraints ?? []

        let budgetDetail = softConstraints.first(where: { $0.title == "Budget" })?.detail
            ?? (bundle.flatMap { displayLabel(for: $0.profile.budgetConstraintBand) } ?? "Not captured")

        let energyDetail = softConstraints.first(where: { $0.title == "Energy pattern" })?.detail
            ?? (bundle.flatMap { displayLabel(for: $0.profile.energyPattern) } ?? "Not captured")

        let familyDetail = constraintDetail(
            from: hardConstraints,
            matching: ["Dependency constraint", "School or work context"],
            fallback: bundle?.profile.dependencyConstraints.joined(separator: ", ") ?? "Not captured"
        )

        let accessibilityDetail = constraintDetail(
            from: hardConstraints,
            matching: ["Accessibility need"],
            fallback: bundle?.profile.accessibilityNeeds.joined(separator: ", ") ?? "Not captured"
        )

        let recoveryDetail = constraintDetail(
            from: hardConstraints,
            matching: ["Recovery constraint"],
            fallback: bundle?.profile.recoveryConstraints.joined(separator: ", ") ?? "Not captured"
        )

        return [
            makeLifeContextFactRow(
                id: "life-context-constraint-budget",
                title: "Budget",
                detail: budgetDetail,
                sourceLabel: "Profile",
                freshness: bundle?.profile.budgetConstraintBand == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.budgetConstraintBand == .unknown ? .needsReview : .used,
                whereUsed: "Keep recommendations within real spending limits",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-energy",
                title: "Energy",
                detail: energyDetail,
                sourceLabel: "Profile",
                freshness: bundle?.profile.energyPattern == .unknown ? .basedOnOlderContext : .current,
                runtimeUseState: bundle?.profile.energyPattern == .unknown ? .needsReview : .used,
                whereUsed: "Keep the day honest about capacity",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-family",
                title: "Family / caregiver dependencies",
                detail: familyDetail,
                sourceLabel: "Profile",
                freshness: familyDetail == "Not captured" ? .basedOnOlderContext : .current,
                runtimeUseState: familyDetail == "Not captured" ? .needsReview : .used,
                whereUsed: "Avoid impossible timing or access assumptions",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-accessibility",
                title: "Accessibility needs",
                detail: accessibilityDetail,
                sourceLabel: "Profile",
                freshness: accessibilityDetail == "Not captured" ? .basedOnOlderContext : .current,
                runtimeUseState: accessibilityDetail == "Not captured" ? .needsReview : .used,
                whereUsed: "Keep access and pace aligned with real needs",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-recovery",
                title: "Recovery needs",
                detail: recoveryDetail,
                sourceLabel: "Profile",
                freshness: recoveryDetail == "Not captured" ? .basedOnOlderContext : .current,
                runtimeUseState: recoveryDetail == "Not captured" ? .needsReview : .used,
                whereUsed: "Keep recovery-aware pacing visible",
                updateTargets: [.profile, .historicalFact],
                captureRouteContext: .needsReview,
                basePath: basePath
            ),
            makeLifeContextFactRow(
                id: "life-context-constraint-dont-assume",
                title: "Do not assume",
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

    func makeReviewNeededRows(
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

        rows.append(contentsOf: (bundle?.sources ?? []).compactMap { source in
            let freshness = projection?.sourceFreshnessSummary.first(where: { $0.sourceID == source.id })?.freshness ?? .basedOnOlderContext
            guard source.kind != .userConfirmed || freshness != .current else {
                return nil
            }

            return makeLifeContextFactRow(
                id: "life-context-source-\(source.id)",
                title: "\(displayLabel(for: source.kind)) fact",
                detail: source.visibleExplanation,
                sourceLabel: source.label,
                freshness: memoryFreshness(for: freshness),
                runtimeUseState: .needsReview,
                whereUsed: source.kind == .imported ? "Imported context needs review before runtime use" : "Review before runtime use",
                updateTargets: [.historicalFact, .profile],
                captureRouteContext: .needsReview,
                basePath: basePath
            )
        })

        rows.append(contentsOf: (projection?.excludedHistorySummary ?? []).map { exclusion in
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
        })

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

}
