import Foundation

struct StepReallocationApprovedDecision: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let timeContext: StepReallocationTimeContext
    let momentumContext: StepReallocationMomentumContext
    let pressureImpact: StepReallocationPressureImpact
    let proofImpact: StepReallocationProofImpact
    let approvedAt: String
    let approvalSummary: String
    let isApproved: Bool

    init(
        id: String,
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        timeContext: StepReallocationTimeContext,
        momentumContext: StepReallocationMomentumContext,
        pressureImpact: StepReallocationPressureImpact,
        proofImpact: StepReallocationProofImpact,
        approvedAt: String,
        approvalSummary: String,
        isApproved: Bool
    ) {
        self.id = Self.normalizedRequired(id)
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.timeContext = timeContext
        self.momentumContext = momentumContext
        self.pressureImpact = pressureImpact
        self.proofImpact = proofImpact
        self.approvedAt = Self.normalizedRequired(approvedAt)
        self.approvalSummary = Self.normalizedRequired(approvalSummary)
        self.isApproved = isApproved
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            timeContext.isWellFormed &&
            momentumContext.isWellFormed &&
            pressureImpact.isWellFormed &&
            proofImpact.isWellFormed &&
            approvedAt.isEmpty == false &&
            approvalSummary.isEmpty == false
    }

    func emitStepReallocationEvent() -> StepReallocationEvent? {
        guard isApproved, isWellFormed else {
            return nil
        }

        return StepReallocationEvent(
            id: "step-reallocation.event.\(id)",
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            timeContext: timeContext,
            momentumContext: momentumContext,
            pressureImpact: pressureImpact,
            proofImpact: proofImpact
        )
    }

    static func isWellFormed(sourceRecord: SourceRecord) -> Bool {
        sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            (sourceRecord.locator?.isEmpty == false || sourceRecord.locator == nil)
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct StepReallocationEvent: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRecord: SourceRecord
    let receipt: Receipt
    let replayTrace: ReplayTrace
    let timeContext: StepReallocationTimeContext
    let momentumContext: StepReallocationMomentumContext
    let pressureImpact: StepReallocationPressureImpact
    let proofImpact: StepReallocationProofImpact
    let schemaVersion: String

    init(
        id: String,
        sourceRecord: SourceRecord,
        receipt: Receipt,
        replayTrace: ReplayTrace,
        timeContext: StepReallocationTimeContext,
        momentumContext: StepReallocationMomentumContext,
        pressureImpact: StepReallocationPressureImpact,
        proofImpact: StepReallocationProofImpact,
        schemaVersion: String = stepReallocationEventSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.sourceRecord = sourceRecord
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.timeContext = timeContext
        self.momentumContext = momentumContext
        self.pressureImpact = pressureImpact
        self.proofImpact = proofImpact
        self.schemaVersion = Self.normalizedRequired(schemaVersion)
    }

    var sourceRecordLabel: String {
        sourceRecord.entityTitle
    }

    var sourceAdapterUseSummary: String {
        "Step reallocation stays local and inspectable through source adapters."
    }

    var inspectionSurfaceTitle: String {
        "Search Ambitions"
    }

    var inspectionSummary: String {
        "You / Search Ambitions can inspect this Step Reallocation source adapter, receipt, and reason."
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "Search Ambitions" && replayTrace.isLocalOnly
    }

    var isWellFormed: Bool {
        Self.isWellFormed(sourceRecord: sourceRecord) &&
            receipt.isWellFormed &&
            replayTrace.isLocalOnly &&
            replayTrace.isReplayable &&
            timeContext.isWellFormed &&
            momentumContext.isWellFormed &&
            pressureImpact.isWellFormed &&
            proofImpact.isWellFormed &&
            schemaVersion == stepReallocationEventSchemaVersion
    }

    static func isWellFormed(sourceRecord: SourceRecord) -> Bool {
        sourceRecord.id.isEmpty == false &&
            sourceRecord.providerID.isEmpty == false &&
            sourceRecord.entityTitle.isEmpty == false &&
            (sourceRecord.locator?.isEmpty == false || sourceRecord.locator == nil)
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct StepReallocationRuntimeInput: Sendable {
    let event: StepReallocationEvent
    let traceContext: PrivateLifeRuntimeKernelTraceContext
    let decisionKey: String
    let goalText: String?
    let recommendationTrace: RecommendationTrace
    let inspectionSurfaceTitle: String

    var sourceRecord: SourceRecord {
        event.sourceRecord
    }

    var receipt: Receipt {
        event.receipt
    }

    var replayTrace: ReplayTrace {
        event.replayTrace
    }

    var sourceAdapterUseSummary: String {
        event.sourceAdapterUseSummary
    }

    var inspectionSummary: String {
        "You / Search Ambitions can inspect this Step Reallocation source adapter, receipt, and reason."
    }

    var isInspectableBoundary: Bool {
        inspectionSurfaceTitle == "Search Ambitions" && replayTrace.isLocalOnly
    }

    var runtimeInput: PrivateLifeRuntimeKernelDecisionInput {
        PrivateLifeRuntimeKernelDecisionInput(
            traceContext: traceContext,
            decisionKey: decisionKey,
            goalText: goalText,
            recommendationTrace: recommendationTrace
        )
    }
}

struct StepReallocationSourceAdapter: Sendable, Equatable, Hashable {
    let inspectionSurfaceTitle: String

    init(inspectionSurfaceTitle: String = "Search Ambitions") {
        self.inspectionSurfaceTitle = inspectionSurfaceTitle
    }

    func makeRuntimeInput(
        from event: StepReallocationEvent,
        runtimeContext: RuntimeContextSnapshot,
        goalText: String? = nil
    ) -> StepReallocationRuntimeInput {
        let traceContext = PrivateLifeRuntimeKernelTraceContext(
            runtimeContext: runtimeContext,
            goalText: goalText ?? event.momentumContext.destinationStepTitle
        )
        return StepReallocationRuntimeInput(
            event: event,
            traceContext: traceContext,
            decisionKey: decisionKey(for: event),
            goalText: goalText ?? event.momentumContext.destinationStepTitle,
            recommendationTrace: recommendationTrace(for: event),
            inspectionSurfaceTitle: inspectionSurfaceTitle
        )
    }

    func decisionKey(for event: StepReallocationEvent) -> String {
        "step.reallocation.\(event.id)"
    }

    func recommendationTrace(for event: StepReallocationEvent) -> RecommendationTrace {
        RecommendationTrace(
            id: "trace.step-reallocation.\(event.id)",
            recommendationID: "recommendation.step-reallocation.\(event.id)",
            source: RecommendationTraceSource(
                citedSourceIDs: [
                    event.sourceRecord.id,
                    event.receipt.id,
                    decisionKey(for: event),
                    event.replayTrace.id
                ],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .goalState, .contextLens, .recovery],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.step-reallocation.\(event.id)",
                summary: [
                    event.timeContext.scheduleImpactSummary,
                    event.momentumContext.momentumSummary,
                    event.pressureImpact.pressureSummary
                ]
                .joined(separator: " "),
                evidenceCategoryIDs: [
                    RecommendationExplanationEvidenceCategory.sourceTruth.rawValue,
                    RecommendationExplanationEvidenceCategory.goalState.rawValue,
                    RecommendationExplanationEvidenceCategory.contextLens.rawValue,
                    RecommendationExplanationEvidenceCategory.recovery.rawValue
                ]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: [
                    event.timeContext.timeWindowLabel,
                    event.momentumContext.momentumSummary,
                    event.pressureImpact.reviewSummary,
                    event.proofImpact.proofSummary
                ],
                summaries: [
                    event.timeContext.scheduleImpactSummary,
                    event.pressureImpact.pressureSummary,
                    event.proofImpact.proofSummary
                ]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: [
                    RecommendationExplanationCorrectionActionKind.changeDeadline.rawValue,
                    RecommendationExplanationCorrectionActionKind.changeRoute.rawValue,
                    RecommendationExplanationCorrectionActionKind.explainMore.rawValue
                ],
                controlActionIDs: [
                    "open_step",
                    "start_now"
                ],
                correctableFieldKeys: [
                    "sourceRecord",
                    "receipt",
                    "replayTrace",
                    "timeContext",
                    "momentumContext",
                    "pressureImpact",
                    "proofImpact"
                ],
                hasRequiredControl: true
            ),
            receiptBehavior: .available(
                receiptIDs: [event.receipt.id],
                actionReceiptIDs: [event.receipt.id],
                proofReferenceIDs: event.proofImpact.proofReferenceIDs
            )
        )
    }
}

extension StepReallocationEvent {
    func personalRuntimeLearningSignal(
        confidenceState: PersonalRuntimeLearningSignalConfidenceState? = nil,
        deletedAt: String? = nil
    ) -> PersonalRuntimeLearningSignal {
        let resolvedConfidenceState = confidenceState ?? (timeContext.requiresSensitiveReview ? .reviewRequired : .active)

        return PersonalRuntimeLearningSignal(
            id: "personal-runtime-learning.\(PersonalRuntimeLearningSignalType.momentumReflow.rawValue).\(id)",
            signalType: .momentumReflow,
            confidenceState: resolvedConfidenceState,
            sourceRecord: sourceRecord,
            receipt: receipt,
            replayTrace: replayTrace,
            sourceAdapterUseSummary: sourceAdapterUseSummary,
            inspectionSummary: "You / Search Ambitions can inspect this Momentum Reflow signal, source, receipt, and reason.",
            reviewSummary: timeContext.requiresSensitiveReview
                ? "Protected or sensitive time requires review before future ranking can use this signal."
                : "Local and source-tied.",
            medicalAdviceBoundarySummary: "Momentum Reflow never infers medical advice.",
            requiresSensitiveReview: timeContext.requiresSensitiveReview,
            deletedAt: deletedAt
        )
    }
}
