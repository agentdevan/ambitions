import Foundation

extension PersonalizationFactorLedgerBuilder {

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
