import Foundation

extension PrivateLifeRuntimeKernel {

    func lifeContextCadence(
        for projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness
    ) -> String {
        guard let projection else {
            return "review before cadence"
        }
        if readiness == .clarification {
            return "review before cadence"
        }
        if readiness == .review {
            return "rebuild from active context"
        }
        if projection.lifeStage == .highSchool {
            return (projection.ageYears ?? 0) < 16 ? "school-week cadence" : "compressed portfolio cadence"
        }
        if projection.eligibilityModel.contains(where: { $0.sexLeaguePathway != nil }) {
            return "pathway-specific cadence"
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("maker") }) {
            return "weekly maker-space cadence"
        }
        if projection.travelModel.radiusMinutes ?? 0 <= 20 {
            return "local access cadence"
        }
        return "steady weekly cadence"
    }


    func lifeContextUrgency(
        for projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness
    ) -> String {
        guard let projection else {
            return "clarification"
        }
        switch readiness {
        case .clarification:
            return "clarification"
        case .review:
            return "review"
        case .ready:
            if projection.lifeStage == .highSchool {
                return (projection.ageYears ?? 0) < 16 ? "steady" : "focused"
            }
            if projection.travelModel.radiusMinutes ?? 0 <= 20 {
                return "focused"
            }
            if projection.eligibilityModel.contains(where: { $0.sexLeaguePathway != nil }) {
                return "focused"
            }
            return "steady"
        }
    }


    func lifeContextMilestone(
        for projection: LifeContextRuntimeProjection?,
        readiness: PrivateLifeRuntimeLifeContextReadiness
    ) -> String {
        guard let projection else {
            return "capture the missing context"
        }
        if readiness == .clarification {
            return "capture the missing context"
        }
        if projection.excludedHistorySummary.isEmpty == false {
            return "confirm paused context stays excluded"
        }
        if projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("injury") || $0.title.localizedCaseInsensitiveContains("blocked") }) {
            return "confirm the recovery-safe re-entry milestone"
        }
        if projection.eligibilityModel.contains(where: { $0.sexLeaguePathway != nil }) {
            let label = projection.eligibilityModel.compactMap(\.sexLeaguePathway).first ?? "explicit pathway"
            return "\(label) exposure milestone"
        }
        if projection.lifeStage == .highSchool {
            return (projection.ageYears ?? 0) < 16
                ? "lock one guardian-transport build block"
                : "tighten portfolio readiness around school access"
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("home") }) &&
            projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("tool") }) {
            return "confirm equipment and local practice"
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("maker") }) {
            return "reach the first maker-space build"
        }
        if projection.travelModel.radiusMinutes ?? 0 <= 20 {
            return "confirm local access and equipment"
        }
        return "name the next visible milestone"
    }


    func lifeContextExplanation(
        goalText: String,
        readiness: PrivateLifeRuntimeLifeContextReadiness,
        projection: LifeContextRuntimeProjection?
    ) -> String {
        guard let projection else {
            return "\(goalText) stays in clarification until life context is provided."
        }

        var reasonParts: [String] = []
        switch readiness {
        case .clarification:
            reasonParts.append("missing context keeps the runtime in clarification")
        case .review:
            reasonParts.append("active context needs review before a faster recommendation")
        case .ready:
            break
        }

        if projection.eligibilityModel.contains(where: { $0.sexLeaguePathway != nil }) {
            if let label = projection.eligibilityModel.compactMap(\.sexLeaguePathway).first {
                reasonParts.append("the explicit pathway is \(label)")
            }
        } else if projection.lifeStage == .highSchool {
            reasonParts.append((projection.ageYears ?? 0) < 16 ? "the timeline is still early" : "the timeline is compressed")
        }

        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("maker") }) {
            reasonParts.append("maker-space access shapes the first step")
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("home") }) &&
            projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("tool") }) {
            reasonParts.append("equipment and local practice matter before maker-space access")
        }
        if projection.excludedHistorySummary.isEmpty == false {
            reasonParts.append("paused or deleted context stays out of the runtime path")
        }
        if projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("injury") || $0.title.localizedCaseInsensitiveContains("blocked") }) {
            reasonParts.append("older injury or blocked-attempt context keeps the plan conservative")
        }

        if reasonParts.isEmpty {
            reasonParts.append("the local life context keeps the recommendation specific")
        }

        return "\(goalText) " + reasonParts.joined(separator: ", ") + "."
    }


    func makePersonalizationFactorLedger(
        for input: PrivateLifeRuntimeKernelDecisionInput,
        decisionRecord: PrivateLifeRuntimeKernelDecisionRecord? = nil,
        decisionOutput: PrivateLifeRuntimeKernelDecisionOutput? = nil
    ) -> PersonalizationFactorLedger {
        let builder = PersonalizationFactorLedgerBuilder()
        let userContextVersion = lifeContextSignature(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        return builder.build(
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


    func normalizeGoalText(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }


    func traceShape(for recommendationTrace: RecommendationTrace) -> String {
        return [
            Self.traceIdentitySignature(recommendationTrace),
            Self.traceSourceSignature(recommendationTrace.source),
            Self.traceReasonSignature(recommendationTrace.reason),
            Self.traceFitSignature(recommendationTrace.fit),
            Self.traceUncertaintySignature(recommendationTrace.uncertainty),
            Self.traceControlSignature(recommendationTrace.control),
            Self.traceReceiptSignature(recommendationTrace.receiptBehavior),
            recommendationTrace.schemaVersion
        ]
        .joined(separator: "|")
    }


    static func whisperSignature(_ whisper: GoalTrustWhisperState) -> String {
        [
            whisper.title,
            whisper.subtitle,
            whisper.pillLine,
            whisper.pills.map { pill in
                [
                    pill.id,
                    pill.title,
                    pill.icon,
                    pill.state.rawValue
                ]
                .joined(separator: ":")
            }
            .sorted()
            .joined(separator: ",")
        ]
        .joined(separator: "|")
    }


    static func whyThisSignature(_ whyThis: GoalWhyThisState) -> String {
        [
            whyThis.compactSummary,
            whyThis.lines.joined(separator: ",")
        ]
        .joined(separator: "|")
    }


    static func freshnessSignature(_ freshness: GoalFreshnessState) -> String {
        [
            freshness.posture.rawValue,
            freshness.postureLabel,
            freshness.severityLabel,
            freshness.detailLabels.joined(separator: ",")
        ]
        .joined(separator: "|")
    }


    static func confidenceSignature(_ confidence: GoalConfidenceState) -> String {
        [
            confidence.understandingConfidence.rawValue,
            confidence.pathConfidence?.rawValue ?? "none",
            confidence.detailLabels.joined(separator: ",")
        ]
        .joined(separator: "|")
    }


    static func sourceAuditSignature(_ sourceAudit: GoalSourceAuditSectionState) -> String {
        sourceAudit.rows
            .map(Self.sourceAuditRowSignature)
            .sorted()
            .joined(separator: ",")
    }


    static func sourceAuditRowSignature(_ row: GoalSourceAuditRowState) -> String {
        [
            row.id,
            row.resourceID,
            row.title,
            row.subtitle,
            row.detailLabels.joined(separator: ","),
            row.state.rawValue
        ]
        .joined(separator: ":")
    }


    static func contradictionSignature(_ contradictions: [GoalContradictionSummaryState]) -> String {
        contradictions
            .map(Self.contradictionEntrySignature)
            .sorted()
            .joined(separator: ",")
    }


    static func contradictionEntrySignature(_ contradiction: GoalContradictionSummaryState) -> String {
        [
            contradiction.id,
            contradiction.code.rawValue,
            contradiction.title,
            contradiction.summary,
            contradiction.severityLabel,
            contradiction.state.rawValue
        ]
        .joined(separator: ":")
    }


    static func correctionControlSignature(_ controls: [GoalCorrectionControlState]) -> String {
        controls
            .map(Self.correctionControlEntrySignature)
            .sorted()
            .joined(separator: ",")
    }


    static func correctionControlEntrySignature(_ control: GoalCorrectionControlState) -> String {
        [
            control.id,
            control.title,
            control.subtitle,
            control.kind.rawValue,
            control.artifactKind.rawValue,
            control.teachingSignalKind.rawValue,
            control.state.rawValue
        ]
        .joined(separator: ":")
    }


    static func appliedTeachingBadgeSignature(_ badges: [GoalAppliedTeachingBadgeState]) -> String {
        badges
            .map(Self.appliedTeachingBadgeEntrySignature)
            .sorted()
            .joined(separator: ",")
    }


    static func appliedTeachingBadgeEntrySignature(_ badge: GoalAppliedTeachingBadgeState) -> String {
        [
            badge.id,
            badge.signalID,
            badge.title,
            badge.subtitle,
            badge.state.rawValue
        ]
        .joined(separator: ":")
    }


    static func traceIdentitySignature(_ trace: RecommendationTrace) -> String {
        [
            trace.id,
            trace.recommendationID
        ]
        .joined(separator: ":")
    }


    static func traceSourceSignature(_ source: RecommendationTraceSource) -> String {
        [
            source.citedSourceIDs.sorted().joined(separator: ","),
            source.sourceAtlasBlockReasons.sorted().joined(separator: ","),
            source.localEvidenceCategories.map(\.rawValue).sorted().joined(separator: ","),
            source.canSupportRecommendation ? "can-support" : "blocked"
        ]
        .joined(separator: "|")
    }
}
