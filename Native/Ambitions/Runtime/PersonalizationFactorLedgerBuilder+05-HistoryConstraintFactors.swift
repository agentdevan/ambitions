import Foundation

extension PersonalizationFactorLedgerBuilder {
    func appendHistoryAndConstraintFactors(
        to factors: inout [PersonalizationFactorLedgerFactor],
        projection: LifeContextRuntimeProjection?
    ) {
        if let history = projection?.historySummary, history.isEmpty == false {
            let historyTitles = history.map(\.title)
            factors.append(
                factor(
                    id: "factor.historical_context",
                    type: .historicalContext,
                    category: .history,
                    reason: "Historical context includes \(historyTitles.prefix(2).joined(separator: ", ")).",
                    source: sourceProjection(kind: .lifeContext, sourceID: "history", label: "History", freshness: historyFreshness(from: history), isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "History", fallbackReason: "Historical context should be reviewed when freshness changes."),
                    userControlled: true,
                    runtimeWeight: min(1, 0.4 + Double(history.count) * 0.08),
                    affectedRecommendationArea: "Historical context",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use current constraints without older history until history is refreshed.",
                    active: true,
                    sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                    replaySeed: historyTitles + history.flatMap { $0.usedFor.map(\.rawValue) }
                )
            )

            let failureTitles = history.filter { entry in
                entry.title.localizedCaseInsensitiveContains("fail") || entry.title.localizedCaseInsensitiveContains("injury") || entry.usedFor.contains(.recovery)
            }
            if failureTitles.isEmpty == false {
                factors.append(
                    factor(
                        id: "factor.past_failure",
                        type: .pastFailure,
                        category: .recovery,
                        reason: "Older failure or recovery context keeps the plan conservative.",
                        source: sourceProjection(kind: .lifeContext, sourceID: "history.failure", label: "Failure and recovery history", freshness: historyFreshness(from: history), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Past failure", fallbackReason: "Failure history should be checked before the recommendation changes."),
                        userControlled: true,
                        runtimeWeight: 0.9,
                        affectedRecommendationArea: "Recovery",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use a less conservative fallback until the recovery context is restored.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: failureTitles.map(\.id)
                    )
                )
            }

            let successTitles = history.filter { entry in
                entry.title.localizedCaseInsensitiveContains("success") || entry.title.localizedCaseInsensitiveContains("achievement") || entry.usedFor.contains(.feasibility)
            }
            if successTitles.isEmpty == false {
                factors.append(
                    factor(
                        id: "factor.past_success",
                        type: .pastSuccess,
                        category: .history,
                        reason: "Past successes make the recommendation more believable.",
                        source: sourceProjection(kind: .lifeContext, sourceID: "history.success", label: "Success history", freshness: historyFreshness(from: history), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Past success", fallbackReason: "Success history should be refreshed when new evidence arrives."),
                        userControlled: true,
                        runtimeWeight: 0.7,
                        affectedRecommendationArea: "Believability",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use neutral believability until recent success is re-entered.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: successTitles.map(\.id)
                    )
                )
            }

            if let firstReview = history.first(where: { $0.freshness != .current || $0.usedFor.contains(.sequencing) || $0.usedFor.contains(.duration) }) {
                factors.append(
                    factor(
                        id: "factor.execution_behavior",
                        type: .executionBehavior,
                        category: .preference,
                        reason: "Execution behavior reflects how the user has actually completed similar work.",
                        source: sourceProjection(kind: .lifeContext, sourceID: "history.execution", label: "Execution behavior", freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Execution behavior", fallbackReason: "Execution behavior should be rechecked when history changes."),
                        userControlled: true,
                        runtimeWeight: 0.8,
                        affectedRecommendationArea: "Cadence",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use neutral cadence until execution behavior is refreshed.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [firstReview.id]
                    )
                )
            }
        }

        if let softConstraints = projection?.softConstraints, softConstraints.isEmpty == false {
            if let energy = softConstraints.first(where: { $0.title == "Energy pattern" || $0.detail.localizedCaseInsensitiveContains("morning") || $0.detail.localizedCaseInsensitiveContains("evening") || $0.detail.localizedCaseInsensitiveContains("midday") || $0.detail.localizedCaseInsensitiveContains("variable") }) {
                factors.append(
                    factor(
                        id: "factor.energy_pattern",
                        type: .energyPattern,
                        category: .timing,
                        reason: "Energy pattern is \(energy.detail).",
                        source: sourceProjection(kind: .lifeContext, sourceID: energy.id, label: energy.title, freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Energy pattern", fallbackReason: "Energy pattern should be rechecked when the schedule changes."),
                        userControlled: true,
                        runtimeWeight: 0.75,
                        affectedRecommendationArea: "Cadence",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use a neutral cadence until energy pattern is explicit again.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [energy.detail]
                    )
                )
                factors.append(
                    factor(
                        id: "factor.time_of_day_fit",
                        type: .timeOfDayFit,
                        category: .timing,
                        reason: "Time of day fit follows the energy pattern and the current schedule shape.",
                        source: sourceProjection(kind: .lifeContext, sourceID: energy.id, label: energy.title, freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Time of day", fallbackReason: "Time-of-day fit should be rechecked when the energy pattern changes."),
                        userControlled: true,
                        runtimeWeight: 0.65,
                        affectedRecommendationArea: "Time fit",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use neutral time-of-day assumptions until the energy pattern is known again.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [energy.id, energy.detail]
                    )
                )
            }

            if let budget = softConstraints.first(where: { $0.title == "Budget" }) {
                factors.append(
                    factor(
                        id: "factor.budget_constraint",
                        type: .budgetConstraint,
                        category: .preference,
                        reason: "Budget is \(budget.detail).",
                        source: sourceProjection(kind: .lifeContext, sourceID: budget.id, label: budget.title, freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Budget", fallbackReason: "Budget should be rechecked when the user updates their context."),
                        userControlled: true,
                        runtimeWeight: 0.7,
                        affectedRecommendationArea: "Budget fit",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use budget-neutral recommendations until budget is recaptured.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [budget.detail]
                    )
                )
            }

            if let preference = softConstraints.first(where: { $0.title != "Budget" && $0.title != "Energy pattern" }) {
                factors.append(
                    factor(
                        id: "factor.preference",
                        type: .preference,
                        category: .preference,
                        reason: "Preference context is present and user-owned.",
                        source: sourceProjection(kind: .lifeContext, sourceID: preference.id, label: preference.title, freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Preference", fallbackReason: "Preference should be rechecked when the context changes."),
                        userControlled: true,
                        runtimeWeight: 0.55,
                        affectedRecommendationArea: "Preference fit",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use neutral preference assumptions until the user re-states them.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [preference.id]
                    )
                )
            }
        }

        if let hardConstraints = projection?.hardConstraints, hardConstraints.isEmpty == false {
            if let dependency = hardConstraints.first(where: { $0.title.localizedCaseInsensitiveContains("dependency") }) {
                factors.append(
                    factor(
                        id: "factor.dependency_constraint",
                        type: .dependencyConstraint,
                        category: .access,
                        reason: dependency.detail,
                        source: sourceProjection(kind: .lifeContext, sourceID: dependency.id, label: dependency.title, freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Dependency", fallbackReason: "Dependency constraints should be refreshed before behavior changes."),
                        userControlled: true,
                        runtimeWeight: 0.85,
                        affectedRecommendationArea: "Sequencing",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use the shortest safe step until dependencies are confirmed again.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [dependency.detail]
                    )
                )
            }

            if let recovery = hardConstraints.first(where: { $0.title.localizedCaseInsensitiveContains("recovery") || $0.detail.localizedCaseInsensitiveContains("recovery") }) {
                factors.append(
                    factor(
                        id: "factor.recovery_constraint",
                        type: .recoveryConstraint,
                        category: .recovery,
                        reason: "Recovery context is present and needs review before runtime use.",
                        source: sourceProjection(kind: .lifeContext, sourceID: recovery.id, label: recovery.title, freshness: freshnessState(for: projection), isSensitive: true),
                        freshness: freshnessProjection(for: projection, area: "Recovery", fallbackReason: "Recovery constraints should stay visible until the user confirms the path is safe."),
                        userControlled: true,
                        runtimeWeight: 0.95,
                        affectedRecommendationArea: "Recovery",
                        allowedForRuntimeUse: false,
                        canDisable: false,
                        fallbackBehaviorIfRemoved: "Keep the recovery-safe fallback until the constraint is restated.",
                        active: false,
                        sensitive: .init(isSensitive: true, permissionState: .needsReview, sensitiveUseLabel: "Sensitive recovery context", redactedReason: "Recovery context is summarized rather than quoted."),
                        replaySeed: [recovery.id]
                    )
                )
            }

            if let budget = hardConstraints.first(where: { $0.title.localizedCaseInsensitiveContains("budget") }) {
                factors.append(
                    factor(
                        id: "factor.trust_allowance",
                        type: .trustAllowance,
                        category: .trust,
                        reason: "The user has a named budget allowance that keeps the plan believable.",
                        source: sourceProjection(kind: .lifeContext, sourceID: budget.id, label: budget.title, freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Trust allowance", fallbackReason: "Trust allowance should be refreshed when budget changes."),
                        userControlled: true,
                        runtimeWeight: 0.6,
                        affectedRecommendationArea: "Believability",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Use budget-neutral language until the trust allowance is restored.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: [budget.detail]
                    )
                )
            }
        }
    }
}
