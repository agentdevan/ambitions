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

private extension PersonalizationFactorLedgerBuilder {
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

        if let travelModel = projection?.travelModel {
            let transportLabel = travelModel.transportationAccess.rawValue.replacingOccurrences(of: "_", with: " ")
            let accessDetail = travelModel.locationLabel ?? "unknown location"
            let availabilityReason = travelModel.radiusMinutes.map { "\($0) minute travel window" } ?? "No travel radius captured"
            let travelFreshness = freshnessState(for: projection)

            factors.append(
                factor(
                    id: "factor.availability_window",
                    type: .availabilityWindow,
                    category: .timing,
                    reason: "\(availabilityReason) and \(accessDetail) shape what can happen now.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "travel", label: "Travel & access", freshness: travelFreshness, isSensitive: false),
                    freshness: PersonalizationFactorFreshnessProjection(
                        state: travelFreshness,
                        lastAffectedLabel: runtimeSelectedLabel,
                        needsReview: travelFreshness != .current,
                        reviewReason: travelFreshness == .current ? nil : "Travel and access should be reviewed."
                    ),
                    userControlled: true,
                    runtimeWeight: travelModel.radiusMinutes.map { max(0.3, min(1.0, Double($0) / 40.0)) } ?? 0.5,
                    affectedRecommendationArea: "Time fit",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use broader timing defaults until the travel window is known again.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [travelModel.transportationAccess.rawValue, travelModel.locationPrecision.rawValue]
                )
            )

            factors.append(
                factor(
                    id: "factor.travel_fit",
                    type: .travelFit,
                    category: .access,
                    reason: "Travel fit uses the current radius, precision, and access posture.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "travel", label: "Travel & access", freshness: travelFreshness, isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Travel fit", fallbackReason: "Travel fit should be rechecked when location precision changes."),
                    userControlled: true,
                    runtimeWeight: 0.9,
                    affectedRecommendationArea: "Travel fit",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Fall back to local-only opportunities and shorter windows.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [travelModel.transportationAccess.rawValue, travelModel.locationPrecision.rawValue, accessDetail]
                )
            )

            factors.append(
                factor(
                    id: "factor.transportation_constraint",
                    type: .transportationConstraint,
                    category: .access,
                    reason: "Transportation is \(transportLabel); that directly narrows what is reachable.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "travel", label: "Travel & access", freshness: travelFreshness, isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Transportation", fallbackReason: "Transportation should be reviewed when access changes."),
                    userControlled: true,
                    runtimeWeight: transportWeight(for: travelModel.transportationAccess),
                    affectedRecommendationArea: "Access and travel",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use neutral access assumptions until transportation is re-entered.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [travelModel.transportationAccess.rawValue]
                )
            )
        }

        if let anchors = projection?.availableOpportunityAnchors, anchors.isEmpty == false {
            let facilityLabels = anchors.map(\.title).sorted()
            factors.append(
                factor(
                    id: "factor.facility_access",
                    type: .facilityAccess,
                    category: .access,
                    reason: "Available facilities include \(facilityLabels.prefix(3).joined(separator: ", ")).",
                    source: sourceProjection(kind: .lifeContext, sourceID: "facilities", label: "Facilities & equipment", freshness: freshnessState(for: projection), isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Facilities", fallbackReason: "Facility access should be rechecked before a recommendation changes."),
                    userControlled: true,
                    runtimeWeight: min(1, 0.5 + Double(anchors.count) * 0.1),
                    affectedRecommendationArea: "Facility access",
                    allowedForRuntimeUse: true,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Only use facility-light recommendations until access is restored.",
                    active: true,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: anchors.map(\.id)
                )
            )

            let equipmentDetail = anchors.map(\.detail).joined(separator: " ")
            factors.append(
                factor(
                    id: "factor.equipment_access",
                    type: .equipmentAccess,
                    category: .access,
                    reason: equipmentDetail.isEmpty ? "Equipment access is not fully described yet." : "Equipment access is described by the current opportunity detail.",
                    source: sourceProjection(kind: .lifeContext, sourceID: "equipment", label: "Facilities & equipment", freshness: freshnessState(for: projection), isSensitive: false),
                    freshness: freshnessProjection(for: projection, area: "Equipment", fallbackReason: "Equipment access should be refreshed when the opportunity detail changes."),
                    userControlled: true,
                    runtimeWeight: equipmentDetail.isEmpty ? 0.4 : 0.8,
                    affectedRecommendationArea: "Equipment fit",
                    allowedForRuntimeUse: equipmentDetail.isEmpty == false,
                    canDisable: true,
                    fallbackBehaviorIfRemoved: "Use equipment-light suggestions until gear access is explicit again.",
                    active: equipmentDetail.isEmpty == false,
                    sensitive: .init(
                        isSensitive: false,
                        permissionState: equipmentDetail.isEmpty ? .needsReview : .allowed,
                        sensitiveUseLabel: "Not sensitive",
                        redactedReason: nil
                    ),
                    replaySeed: [equipmentDetail]
                )
            )

            if anchors.contains(where: { $0.detail.localizedCaseInsensitiveContains("season") }) {
                factors.append(
                    factor(
                        id: "factor.seasonality",
                        type: .seasonality,
                        category: .timing,
                        reason: "The current opportunity detail includes seasonal availability.",
                        source: sourceProjection(kind: .lifeContext, sourceID: "seasonality", label: "Opportunity seasonality", freshness: freshnessState(for: projection), isSensitive: false),
                        freshness: freshnessProjection(for: projection, area: "Seasonality", fallbackReason: "Seasonal availability should be refreshed when the opportunity changes."),
                        userControlled: true,
                        runtimeWeight: 0.6,
                        affectedRecommendationArea: "Seasonality",
                        allowedForRuntimeUse: true,
                        canDisable: true,
                        fallbackBehaviorIfRemoved: "Assume year-round availability until seasonality is captured again.",
                        active: true,
                        sensitive: .init(isSensitive: false, permissionState: .allowed, sensitiveUseLabel: "Not sensitive", redactedReason: nil),
                        replaySeed: anchors.map(\.detail)
                    )
                )
            }
        }

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

        return factors.sorted { lhs, rhs in
            if lhs.factorType.rawValue != rhs.factorType.rawValue {
                return lhs.factorType.rawValue < rhs.factorType.rawValue
            }
            return lhs.id < rhs.id
        }
    }

    func factor(
        id: String,
        type: PersonalizationFactorLedgerFactorType,
        category: PersonalizationFactorLedgerFactorCategory,
        reason: String,
        source: PersonalizationFactorSourceProjection,
        freshness: PersonalizationFactorFreshnessProjection,
        userControlled: Bool,
        runtimeWeight: Double,
        affectedRecommendationArea: String,
        allowedForRuntimeUse: Bool,
        canDisable: Bool,
        fallbackBehaviorIfRemoved: String,
        active: Bool,
        sensitive: PersonalizationFactorSensitiveUseProjection,
        replaySeed: [String]
    ) -> PersonalizationFactorLedgerFactor {
        let control = PersonalizationFactorControlProjection(
            userControlled: userControlled,
            canDisable: canDisable,
            allowedForRuntimeUse: allowedForRuntimeUse,
            active: active,
            fallbackBehaviorIfRemoved: fallbackBehaviorIfRemoved
        )
        let replay = PersonalizationFactorReplayProjection(
            isReplayable: allowedForRuntimeUse && freshness.state != .stale,
            stableFactorFingerprint: stableFingerprint(values: [id, type.rawValue, source.sourceLabel, reason, affectedRecommendationArea] + replaySeed),
            stableEvidenceIDs: replaySeed,
            selectedCandidateID: nil,
            rejectedCandidateIDs: []
        )
        return PersonalizationFactorLedgerFactor(
            id: id,
            factorType: type,
            factorCategory: category,
            humanReadableReason: reason,
            source: source,
            freshness: freshness,
            userControlled: userControlled,
            runtimeWeight: runtimeWeight,
            affectedRecommendationArea: affectedRecommendationArea,
            allowedForRuntimeUse: allowedForRuntimeUse,
            canDisable: canDisable,
            fallbackBehaviorIfRemoved: fallbackBehaviorIfRemoved,
            active: active,
            lastAffectedLabel: freshness.lastAffectedLabel,
            control: control,
            sensitiveUse: sensitive,
            replay: replay
        )
    }

    func sourceProjection(
        kind: PersonalizationFactorLedgerSourceKind,
        sourceID: String,
        label: String,
        freshness: PersonalizationFactorLedgerFreshnessState,
        isSensitive: Bool,
        isUserOwned: Bool = true,
        isPresent: Bool = true
    ) -> PersonalizationFactorSourceProjection {
        PersonalizationFactorSourceProjection(
            kind: kind,
            sourceID: sourceID,
            sourceLabel: label,
            freshness: freshness,
            isSensitive: isSensitive,
            isUserOwned: isUserOwned,
            isPresent: isPresent
        )
    }

    func sourceIDs(for factors: [PersonalizationFactorLedgerFactor]) -> [String] {
        Array(Set(factors.map { $0.source.sourceID }.filter { $0.isEmpty == false })).sorted()
    }

    func sourceKinds(for factors: [PersonalizationFactorLedgerFactor]) -> [String] {
        Array(Set(factors.map { $0.source.kind.rawValue }.filter { $0.isEmpty == false })).sorted()
    }

    func makePersonalRuntimeLearningSignals(
        input: PersonalizationFactorLedgerInput
    ) -> [RuntimeLearningSignal] {
        guard let recommendationTrace = input.recommendationTrace else {
            return []
        }
        return recommendationTrace.personalRuntimeLearningSignals
    }

    func selectedCandidateID(for input: PersonalizationFactorLedgerInput) -> String {
        if let trace = input.recommendationTrace {
            return trace.recommendationID
        }
        if let recommendationID = input.decisionRecord?.recommendationTrace.recommendationID {
            return recommendationID
        }
        if let decisionID = input.decisionOutput?.decisionID {
            return decisionID
        }
        return "candidate.unscoped"
    }

    func rejectedCandidateIDs(for factors: [PersonalizationFactorLedgerFactor], selectedCandidateID: String) -> [String] {
        Array(
            Set(
                factors
                    .filter {
                        $0.allowedForRuntimeUse == false ||
                            $0.control.active == false ||
                            $0.sensitiveUse.permissionState != .allowed
                    }
                    .map { "candidate.\($0.factorType.rawValue)" }
            )
        )
        .sorted()
        .filter { $0 != selectedCandidateID }
    }

    func confidenceBand(for projection: LifeContextRuntimeProjection?, factors: [PersonalizationFactorLedgerFactor]) -> PersonalizationFactorLedgerConfidenceBand {
        if projection?.missingContextQuestions.isEmpty == false {
            return .reviewNeeded
        }
        if factors.contains(where: { $0.freshness.state == .stale }) {
            return .reviewNeeded
        }
        if factors.contains(where: { $0.freshness.state == .basedOnOlderContext || $0.freshness.state == .mayNeedReview }) {
            return .guarded
        }
        if factors.contains(where: { $0.allowedForRuntimeUse == false }) {
            return .guarded
        }
        if factors.count >= 12 {
            return .high
        }
        if factors.count >= 6 {
            return .moderate
        }
        return .low
    }

    func explanationSummary(
        goalText: String?,
        confidenceBand: PersonalizationFactorLedgerConfidenceBand,
        factors: [PersonalizationFactorLedgerFactor]
    ) -> String {
        let activeReasons = factors.filter { $0.allowedForRuntimeUse }.prefix(3).map(\.humanReadableReason)
        let goalPart = goalText.flatMap { $0.isEmpty ? nil : " for \($0)" } ?? ""
        let reasonPart = activeReasons.isEmpty ? "The runtime is using the visible local context." : activeReasons.joined(separator: " ")
        return "The recommendation\(goalPart) stays grounded in local constraints. \(reasonPart) Confidence is \(confidenceBand.rawValue.replacingOccurrences(of: "_", with: " "))."
    }

    func freshnessState(for projection: LifeContextRuntimeProjection?) -> PersonalizationFactorLedgerFreshnessState {
        guard let projection else {
            return .basedOnOlderContext
        }
        if projection.missingContextQuestions.isEmpty == false {
            return .mayNeedReview
        }
        if projection.sourceFreshnessSummary.contains(where: { $0.freshness != .current }) {
            return .mayNeedReview
        }
        if projection.historySummary.contains(where: { $0.freshness != .current }) {
            return .mayNeedReview
        }
        if projection.sensitiveUseWarnings.isEmpty == false {
            return .mayNeedReview
        }
        return .current
    }

    func freshnessProjection(
        for projection: LifeContextRuntimeProjection?,
        area: String,
        fallbackReason: String
    ) -> PersonalizationFactorFreshnessProjection {
        let state = freshnessState(for: projection)
        return PersonalizationFactorFreshnessProjection(
            state: state,
            lastAffectedLabel: state == .current ? "This run" : "Needs review",
            needsReview: state != .current,
            reviewReason: state == .current ? nil : fallbackReason
        )
    }

    func deadlinePressureReason(
        goalText: String?,
        projection: LifeContextRuntimeProjection?,
        trace: RecommendationTrace?
    ) -> String? {
        let normalizedGoalText = goalText?.lowercased() ?? ""
        let normalizedTraceSummary = trace?.reason.summary.lowercased() ?? ""
        let constraintText = [
            projection?.hardConstraints.map(\.detail).joined(separator: " ") ?? "",
            projection?.softConstraints.map(\.detail).joined(separator: " ") ?? "",
            projection?.missingContextQuestions.map(\.reason).joined(separator: " ") ?? ""
        ]
        .joined(separator: " ")
        .lowercased()

        let combined = [
            normalizedGoalText,
            normalizedTraceSummary,
            constraintText
        ]
        .joined(separator: " ")

        guard combined.contains("deadline") || combined.contains("due") || combined.contains("time-sensitive") || combined.contains("by ") else {
            return nil
        }

        if combined.contains("deadline") {
            return "The goal or context mentions a deadline that changes the timing shape."
        }
        if combined.contains("due") {
            return "The goal or context mentions a due date that changes the timing shape."
        }
        return "The goal or context is time-sensitive, so timing matters more than usual."
    }

    func historyFreshness(from history: [LifeContextHistorySummary]) -> PersonalizationFactorLedgerFreshnessState {
        if history.contains(where: { $0.freshness == .stale }) {
            return .stale
        }
        if history.contains(where: { $0.freshness != .current }) {
            return .mayNeedReview
        }
        return .current
    }

    func freshestState(for sources: [LifeContextSourceFreshnessSummary]) -> PersonalizationFactorLedgerFreshnessState {
        if sources.contains(where: { $0.freshness == .stale }) {
            return .stale
        }
        if sources.contains(where: { $0.freshness != .current }) {
            return .mayNeedReview
        }
        return .current
    }

    func transportWeight(for access: LifeContextTransportationAccess) -> Double {
        switch access {
        case .walk:
            return 0.95
        case .bike:
            return 0.9
        case .transit:
            return 0.7
        case .rideshare:
            return 0.65
        case .car:
            return 0.9
        case .parentGuardian:
            return 0.55
        case .limited:
            return 0.35
        case .custom:
            return 0.6
        case .unknown:
            return 0.4
        }
    }

    func stableFingerprint(
        userContextVersion: String,
        factors: [PersonalizationFactorLedgerFactor],
        rejectedCandidateIDs: [String]
    ) -> String {
        stableFingerprint(values: factors.map { "\($0.id):\($0.replay.stableFactorFingerprint)" } + rejectedCandidateIDs)
    }

    func stableFingerprint(values: [String]) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for value in values {
            for byte in value.utf8 {
                hash ^= UInt64(byte)
                hash = hash &* 0x100000001b3
            }
        }
        return String(hash, radix: 16)
    }

    func userContextVersion(from projection: LifeContextRuntimeProjection?) -> String {
        guard let projection else {
            return "life-context.none"
        }
        let signature = [
            projection.lifeStage.rawValue,
            projection.travelModel.transportationAccess.rawValue,
            projection.travelModel.locationPrecision.rawValue,
            projection.availableOpportunityAnchors.map(\.id).sorted().joined(separator: ","),
            projection.hardConstraints.map(\.id).sorted().joined(separator: ","),
            projection.softConstraints.map(\.id).sorted().joined(separator: ","),
            projection.eligibilityModel.map(\.id).sorted().joined(separator: ","),
            projection.historySummary.map { "\($0.id):\($0.freshness.rawValue)" }.sorted().joined(separator: ","),
            projection.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" }.sorted().joined(separator: ","),
            projection.sensitiveUseWarnings.map(\.factID).sorted().joined(separator: ","),
            projection.missingContextQuestions.map(\.id).sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
        return "life-context.\(stableFingerprint(values: [signature]))"
    }
}
