import Foundation

protocol PrivateLifeRuntimeKernelContracting: Sendable {
    var boundary: PrivateLifeRuntimeBoundary { get }

    func evaluate(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionOutput
    func makeDecisionRecord(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionRecord?
}

struct PrivateLifeRuntimeKernelTraceContext: Sendable {
    let runtimeContext: RuntimeContextSnapshot
    let goalIntelligenceContext: RuntimeGoalIntelligenceContext?
    let lifeContextProjection: LifeContextRuntimeProjection?
    let goalText: String?

    init(
        runtimeContext: RuntimeContextSnapshot,
        goalIntelligenceContext: RuntimeGoalIntelligenceContext? = nil,
        lifeContextProjection: LifeContextRuntimeProjection? = nil,
        goalText: String? = nil
    ) {
        self.runtimeContext = runtimeContext
        self.goalIntelligenceContext = goalIntelligenceContext
        self.lifeContextProjection = lifeContextProjection
        self.goalText = goalText?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PrivateLifeRuntimeKernelDecisionInput: Sendable {
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let decisionKey: String
    let goalText: String?
    let recommendationTrace: RecommendationTrace?

    init(
        traceContext: PrivateLifeRuntimeKernelTraceContext,
        decisionKey: String,
        goalText: String? = nil,
        recommendationTrace: RecommendationTrace? = nil
    ) {
        self.traceContext = traceContext
        self.decisionKey = decisionKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalText = goalText?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationTrace = recommendationTrace
    }
}

enum PrivateLifeRuntimeLifeContextReadiness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case review
    case clarification
}

struct PrivateLifeRuntimeLifeContextEffect: Codable, Sendable, Equatable, Hashable {
    let readiness: PrivateLifeRuntimeLifeContextReadiness
    let goalText: String?
    let startHereTitle: String
    let startHereExplanation: String
    let cadence: String
    let urgency: String
    let milestone: String
    let pathwayLabels: [String]
    let sourceFreshnessStates: [String]
    let historyFactIDs: [String]
    let excludedHistoryFactIDs: [String]
    let excludedHistoryReasons: [String]
    let missingContextQuestionIDs: [String]
    let opportunityAnchorIDs: [String]
}

struct PrivateLifeRuntimeKernelDecisionRecord: Sendable {
    let id: String
    let decisionKey: String
    let goalText: String?
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let recommendationTrace: RecommendationTrace
    let personalizationFactorLedger: PersonalizationFactorLedger
    let boundary: PrivateLifeRuntimeBoundary
    let canDriveRecommendation: Bool
    let traceShape: String
    let lifeContextEffect: PrivateLifeRuntimeLifeContextEffect
    let lifeContextSignature: String

    var source: RecommendationTraceSource {
        recommendationTrace.source
    }

    var reason: RecommendationTraceReason {
        recommendationTrace.reason
    }

    var fit: RecommendationTraceFit {
        recommendationTrace.fit
    }

    var uncertainty: RecommendationTraceUncertainty {
        recommendationTrace.uncertainty
    }

    var control: RecommendationTraceControl {
        recommendationTrace.control
    }

    var receiptBehavior: RecommendationTraceReceiptBehavior {
        recommendationTrace.receiptBehavior
    }
}

struct PrivateLifeRuntimeKernelDecisionOutput: Sendable, Equatable {
    let decisionID: String
    let boundary: PrivateLifeRuntimeBoundary
    let canDriveRecommendation: Bool
    let hasRecommendationTrace: Bool
    let traceShape: String?
    let recordID: String?
    let personalizationFactorLedger: PersonalizationFactorLedger
    let lifeContextEffect: PrivateLifeRuntimeLifeContextEffect
    let lifeContextSignature: String

    var isLocalOnly: Bool {
        boundary.isLocalOnly
    }
}

struct PrivateLifeRuntimeKernel: PrivateLifeRuntimeKernelContracting, Sendable, Equatable {
    let boundary: PrivateLifeRuntimeBoundary

    init(boundary: PrivateLifeRuntimeBoundary = .localOnly) {
        self.boundary = boundary
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
        let lifeContextSignature = record?.lifeContextSignature ?? lifeContextSignature(
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

        let canDriveRecommendation = canDriveRecommendation(
            traceContext: input.traceContext,
            recommendationTrace: recommendationTrace
        )
        let traceShape = traceShape(for: recommendationTrace)
        let personalizationFactorLedger = makePersonalizationFactorLedger(for: input)
        let lifeContextEffect = makeLifeContextEffect(
            goalText: input.goalText ?? input.traceContext.goalText,
            projection: input.traceContext.lifeContextProjection
        )
        let lifeContextSignature = lifeContextSignature(
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

    private func canDriveRecommendation(
        traceContext: PrivateLifeRuntimeKernelTraceContext,
        recommendationTrace: RecommendationTrace
    ) -> Bool {
        boundary.isLocalOnly &&
            traceContext.runtimeContext.capabilities.privateLifeRuntimeBoundary.isLocalOnly &&
            traceContext.runtimeContext.capabilities.hasRemoteIntelligenceBackend == false &&
            (traceContext.goalIntelligenceContext?.quarantine.canDriveRecommendation ?? true) &&
            recommendationTrace.isComplete &&
            recommendationTrace.canDriveRecommendationBehavior
    }

    private func decisionIdentifier(
        for input: PrivateLifeRuntimeKernelDecisionInput,
        traceShape: String?
    ) -> String {
        let contextSignature = traceContextSignature(input.traceContext)
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

    private func traceContextSignature(_ traceContext: PrivateLifeRuntimeKernelTraceContext) -> String {
        let runtimeContext = traceContext.runtimeContext
        let knowledgeSignature = runtimeContext.knowledgeProviderStatuses
            .map { status in
                [
                    status.provider.id,
                    status.availability.rawValue,
                    status.runtimeTrustPosture.rawValue
                ]
                .joined(separator: ":")
            }
            .sorted()
            .joined(separator: ",")
        let goalIntelligenceSignature = goalIntelligenceSignature(traceContext.goalIntelligenceContext)
        let lifeContextSignature = lifeContextSignature(
            goalText: traceContext.goalText,
            projection: traceContext.lifeContextProjection
        )

        return [
            runtimeContext.clientContext.kind.rawValue,
            runtimeContext.capabilities.syncBackendKind.rawValue,
            runtimeContext.capabilities.privateLifeRuntimeBoundary.isLocalOnly ? "local" : "mixed",
            runtimeContext.capabilities.hasRemoteIntelligenceBackend ? "remote" : "local",
            runtimeContext.syncStatus.backendKind.rawValue,
            runtimeContext.syncStatus.availability.rawValue,
            "g\(runtimeContext.memorySummary.goalCount)",
            "d\(runtimeContext.memorySummary.draftCount)",
            "e\(runtimeContext.memorySummary.evidenceCount)",
            "f\(runtimeContext.memorySummary.feedbackCount)",
            "c\(runtimeContext.memorySummary.captureCount)",
            knowledgeSignature,
            goalIntelligenceSignature,
            lifeContextSignature
        ]
        .joined(separator: "|")
    }

    private func goalIntelligenceSignature(_ context: RuntimeGoalIntelligenceContext?) -> String {
        guard let context else {
            return "goal-intelligence:none"
        }

        let sourceAuditSignature = Self.sourceAuditSignature(context.explainability.sourceAudit)
        let contradictionSignature = Self.contradictionSignature(context.explainability.contradictions)
        let controlSignature = Self.correctionControlSignature(context.explainability.correctionControls)
        let badgeSignature = Self.appliedTeachingBadgeSignature(context.explainability.appliedTeachingBadges)
        let explanationSignature = [
            Self.whisperSignature(context.explainability.whisper),
            Self.whyThisSignature(context.explainability.whyThis),
            sourceAuditSignature,
            Self.freshnessSignature(context.explainability.freshness),
            Self.confidenceSignature(context.explainability.confidence),
            contradictionSignature,
            controlSignature,
            badgeSignature
        ]
        .joined(separator: "|")

        let applicableSignalsSignature: String
        if let applicableSignals = context.applicableSignals {
            applicableSignalsSignature = [
                applicableSignals.goalID,
                applicableSignals.signals.map(\.id).sorted().joined(separator: ","),
                applicableSignals.supersededSignalIDs.sorted().joined(separator: ",")
            ]
            .joined(separator: "|")
        } else {
            applicableSignalsSignature = "none"
        }

        let whyNowSignature = context.whyNow.map { whyNow in
            [
                whyNow.conciseReason,
                whyNow.reasons.joined(separator: ",")
            ]
            .joined(separator: "|")
        } ?? "none"

        let quarantineSignature = [
            context.quarantine.issues.map(\.rawValue).sorted().joined(separator: ","),
            context.quarantine.canDriveRecommendation ? "drive" : "review",
            context.quarantine.disclosureSummary
        ]
        .joined(separator: "|")

        return [
            context.goalID ?? "no-goal",
            context.draftID ?? "no-draft",
            context.primaryStepID ?? "no-step",
            applicableSignalsSignature,
            explanationSignature,
            whyNowSignature,
            quarantineSignature
        ]
        .joined(separator: "|")
    }

    private func makeLifeContextEffect(
        goalText: String?,
        projection: LifeContextRuntimeProjection?
    ) -> PrivateLifeRuntimeLifeContextEffect {
        let readiness = lifeContextReadiness(for: projection)
        let normalizedGoalTextValue = normalizeGoalText(goalText)
        let startHereTitle = normalizedGoalTextValue ?? "Start here"
        let explanation = lifeContextExplanation(
            goalText: startHereTitle,
            readiness: readiness,
            projection: projection
        )

        return PrivateLifeRuntimeLifeContextEffect(
            readiness: readiness,
            goalText: normalizedGoalTextValue,
            startHereTitle: startHereTitle,
            startHereExplanation: explanation,
            cadence: lifeContextCadence(for: projection, readiness: readiness),
            urgency: lifeContextUrgency(for: projection, readiness: readiness),
            milestone: lifeContextMilestone(for: projection, readiness: readiness),
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

    private func lifeContextSignature(
        goalText: String?,
        projection: LifeContextRuntimeProjection?
    ) -> String {
        let goalTextSignature = normalizeGoalText(goalText) ?? "goal:none"
        guard let projection else {
            return [
                goalTextSignature,
                "life-context:none"
            ]
            .joined(separator: "|")
        }

        let anchorSignature = projection.availableOpportunityAnchors.map { anchor in
            [
                anchor.id,
                anchor.title,
                anchor.verificationStatus.rawValue
            ]
            .joined(separator: ":")
        }
        .sorted()
        .joined(separator: ",")
        let hardConstraintSignature = projection.hardConstraints.map { "\($0.id):\($0.isHardConstraint ? "hard" : "soft")" }.joined(separator: ",")
        let softConstraintSignature = projection.softConstraints.map { "\($0.id):\($0.isHardConstraint ? "hard" : "soft")" }.joined(separator: ",")
        let eligibilitySignature = projection.eligibilityModel.map { pathway in
            [
                pathway.id,
                pathway.pathwayType.rawValue,
                pathway.freshness.rawValue,
                pathway.locationDependent ? "location" : "no-location",
                pathway.userConfirmed ? "confirmed" : "review",
                pathway.sexLeaguePathway ?? "no-sex-label"
            ]
            .joined(separator: ":")
        }
        .sorted()
        .joined(separator: ",")
        let historySignature = projection.historySummary.map { "\($0.id):\($0.freshness.rawValue)" }.joined(separator: ",")
        let exclusionSignature = projection.excludedHistorySummary.map { "\($0.factID):\($0.reason.rawValue)" }.joined(separator: ",")
        let freshnessSignature = projection.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" }.joined(separator: ",")
        let warningSignature = projection.sensitiveUseWarnings.map(\.factID).joined(separator: ",")
        let missingSignature = projection.missingContextQuestions.map(\.id).joined(separator: ",")

        return [
            goalTextSignature,
            "age:\(projection.ageYears.map(String.init) ?? "unknown")",
            "stage:\(projection.lifeStage.rawValue)",
            "travel:\(projection.travelModel.radiusMinutes.map(String.init) ?? "none")",
            "transport:\(projection.travelModel.transportationAccess.rawValue)",
            "anchors:\(anchorSignature)",
            "hard:\(hardConstraintSignature)",
            "soft:\(softConstraintSignature)",
            "pathways:\(eligibilitySignature)",
            "history:\(historySignature)",
            "freshness:\(freshnessSignature)",
            "warnings:\(warningSignature)",
            "missing:\(missingSignature)",
            "excluded:\(exclusionSignature)"
        ]
        .joined(separator: "|")
    }

    private func lifeContextReadiness(for projection: LifeContextRuntimeProjection?) -> PrivateLifeRuntimeLifeContextReadiness {
        guard let projection else {
            return .clarification
        }
        if projection.missingContextQuestions.isEmpty == false {
            return .clarification
        }
        if projection.excludedHistorySummary.isEmpty == false {
            return .review
        }
        if projection.sourceFreshnessSummary.contains(where: { $0.freshness != .current }) {
            return .review
        }
        if projection.historySummary.contains(where: { $0.freshness != .current }) {
            return .review
        }
        if projection.sensitiveUseWarnings.isEmpty == false {
            return .review
        }
        return .ready
    }

    private func lifeContextCadence(
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
            return (projection.ageYears ?? 0) < 16 ? "school-week cadence" : "compressed varsity cadence"
        }
        if projection.eligibilityModel.contains(where: { $0.sexLeaguePathway != nil }) {
            return "pathway-specific cadence"
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("trail") }) {
            return "weekly trail cadence"
        }
        if projection.travelModel.radiusMinutes ?? 0 <= 20 {
            return "local access cadence"
        }
        return "steady weekly cadence"
    }

    private func lifeContextUrgency(
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

    private func lifeContextMilestone(
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
        if projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("injury") || $0.title.localizedCaseInsensitiveContains("failed") }) {
            return "confirm the recovery-safe re-entry milestone"
        }
        if projection.eligibilityModel.contains(where: { $0.sexLeaguePathway != nil }) {
            let label = projection.eligibilityModel.compactMap(\.sexLeaguePathway).first ?? "explicit pathway"
            return "\(label) exposure milestone"
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("gym") }) &&
            projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("bike") }) {
            return "confirm equipment and indoor conditioning"
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("trail") }) {
            return "reach the first local ride"
        }
        if projection.lifeStage == .highSchool {
            return (projection.ageYears ?? 0) < 16
                ? "lock one parent-ride training block"
                : "tighten varsity readiness around school access"
        }
        if projection.travelModel.radiusMinutes ?? 0 <= 20 {
            return "confirm local access and equipment"
        }
        return "name the next visible milestone"
    }

    private func lifeContextExplanation(
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

        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("trail") }) {
            reasonParts.append("trail access shapes the first step")
        }
        if projection.availableOpportunityAnchors.contains(where: { $0.id.localizedCaseInsensitiveContains("gym") }) &&
            projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("bike") }) {
            reasonParts.append("equipment and indoor conditioning matter before trail access")
        }
        if projection.excludedHistorySummary.isEmpty == false {
            reasonParts.append("paused or deleted context stays out of the runtime path")
        }
        if projection.historySummary.contains(where: { $0.title.localizedCaseInsensitiveContains("injury") || $0.title.localizedCaseInsensitiveContains("failed") }) {
            reasonParts.append("older injury or failed-attempt context keeps the plan conservative")
        }

        if reasonParts.isEmpty {
            reasonParts.append("the local life context keeps the recommendation specific")
        }

        return "\(goalText) " + reasonParts.joined(separator: ", ") + "."
    }

    private func makePersonalizationFactorLedger(
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

    private func normalizeGoalText(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }

    private func traceShape(for recommendationTrace: RecommendationTrace) -> String {
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

    private static func whisperSignature(_ whisper: GoalTrustWhisperState) -> String {
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

    private static func whyThisSignature(_ whyThis: GoalWhyThisState) -> String {
        [
            whyThis.compactSummary,
            whyThis.lines.joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func freshnessSignature(_ freshness: GoalFreshnessState) -> String {
        [
            freshness.posture.rawValue,
            freshness.postureLabel,
            freshness.severityLabel,
            freshness.detailLabels.joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func confidenceSignature(_ confidence: GoalConfidenceState) -> String {
        [
            confidence.understandingConfidence.rawValue,
            confidence.pathConfidence?.rawValue ?? "none",
            confidence.detailLabels.joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func sourceAuditSignature(_ sourceAudit: GoalSourceAuditSectionState) -> String {
        sourceAudit.rows
            .map(Self.sourceAuditRowSignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func sourceAuditRowSignature(_ row: GoalSourceAuditRowState) -> String {
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

    private static func contradictionSignature(_ contradictions: [GoalContradictionSummaryState]) -> String {
        contradictions
            .map(Self.contradictionEntrySignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func contradictionEntrySignature(_ contradiction: GoalContradictionSummaryState) -> String {
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

    private static func correctionControlSignature(_ controls: [GoalCorrectionControlState]) -> String {
        controls
            .map(Self.correctionControlEntrySignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func correctionControlEntrySignature(_ control: GoalCorrectionControlState) -> String {
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

    private static func appliedTeachingBadgeSignature(_ badges: [GoalAppliedTeachingBadgeState]) -> String {
        badges
            .map(Self.appliedTeachingBadgeEntrySignature)
            .sorted()
            .joined(separator: ",")
    }

    private static func appliedTeachingBadgeEntrySignature(_ badge: GoalAppliedTeachingBadgeState) -> String {
        [
            badge.id,
            badge.signalID,
            badge.title,
            badge.subtitle,
            badge.state.rawValue
        ]
        .joined(separator: ":")
    }

    private static func traceIdentitySignature(_ trace: RecommendationTrace) -> String {
        [
            trace.id,
            trace.recommendationID
        ]
        .joined(separator: ":")
    }

    private static func traceSourceSignature(_ source: RecommendationTraceSource) -> String {
        [
            source.citedSourceIDs.sorted().joined(separator: ","),
            source.sourceAtlasBlockReasons.sorted().joined(separator: ","),
            source.localEvidenceCategories.map(\.rawValue).sorted().joined(separator: ","),
            source.canSupportRecommendation ? "can-support" : "blocked"
        ]
        .joined(separator: "|")
    }

    private static func traceReasonSignature(_ reason: RecommendationTraceReason) -> String {
        [
            reason.explanationID,
            reason.summary,
            reason.evidenceCategoryIDs.sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func traceFitSignature(_ fit: RecommendationTraceFit) -> String {
        [
            fit.state.rawValue,
            fit.blockReasons.sorted().joined(separator: ","),
            fit.canDriveRecommendation ? "drive" : "review"
        ]
        .joined(separator: "|")
    }

    private static func traceUncertaintySignature(_ uncertainty: RecommendationTraceUncertainty) -> String {
        [
            uncertainty.uncertaintyIDs.sorted().joined(separator: ","),
            uncertainty.summaries.sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    private static func traceControlSignature(_ control: RecommendationTraceControl) -> String {
        [
            control.correctionActionIDs.sorted().joined(separator: ","),
            control.controlActionIDs.sorted().joined(separator: ","),
            control.correctableFieldKeys.sorted().joined(separator: ","),
            control.hasRequiredControl ? "required" : "optional"
        ]
        .joined(separator: "|")
    }

    private static func traceReceiptSignature(_ receiptBehavior: RecommendationTraceReceiptBehavior) -> String {
        [
            receiptBehavior.state.rawValue,
            receiptBehavior.receiptIDs.sorted().joined(separator: ","),
            receiptBehavior.actionReceiptIDs.sorted().joined(separator: ","),
            receiptBehavior.proofReferenceIDs.sorted().joined(separator: ","),
            receiptBehavior.requiresReceiptBeforeBehaviorChange ? "receipt-required" : "receipt-optional"
        ]
        .joined(separator: "|")
    }
}
