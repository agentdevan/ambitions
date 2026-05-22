import Foundation

protocol PrivateLifeRuntimeKernelContracting: Sendable {
    var boundary: PrivateLifeRuntimeBoundary { get }

    func evaluate(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionOutput
    func makeDecisionRecord(_ input: PrivateLifeRuntimeKernelDecisionInput) -> PrivateLifeRuntimeKernelDecisionRecord?
}

struct PrivateLifeRuntimeKernelTraceContext: Sendable {
    let runtimeContext: RuntimeContextSnapshot
    let goalIntelligenceContext: RuntimeGoalIntelligenceContext?
}

struct PrivateLifeRuntimeKernelDecisionInput: Sendable {
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let decisionKey: String
    let recommendationTrace: RecommendationTrace?

    init(
        traceContext: PrivateLifeRuntimeKernelTraceContext,
        decisionKey: String,
        recommendationTrace: RecommendationTrace? = nil
    ) {
        self.traceContext = traceContext
        self.decisionKey = decisionKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationTrace = recommendationTrace
    }
}

struct PrivateLifeRuntimeKernelDecisionRecord: Sendable {
    let id: String
    let decisionKey: String
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let recommendationTrace: RecommendationTrace
    let boundary: PrivateLifeRuntimeBoundary
    let canDriveRecommendation: Bool
    let traceShape: String

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
        return PrivateLifeRuntimeKernelDecisionOutput(
            decisionID: decisionIdentifier(for: input, traceShape: record?.traceShape),
            boundary: boundary,
            canDriveRecommendation: record?.canDriveRecommendation ?? false,
            hasRecommendationTrace: record != nil,
            traceShape: record?.traceShape,
            recordID: record?.id
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

        return PrivateLifeRuntimeKernelDecisionRecord(
            id: decisionIdentifier(for: input, traceShape: traceShape),
            decisionKey: input.decisionKey,
            traceContext: input.traceContext,
            recommendationTrace: recommendationTrace,
            boundary: boundary,
            canDriveRecommendation: canDriveRecommendation,
            traceShape: traceShape
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
            goalIntelligenceSignature
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
