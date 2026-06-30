import Foundation

struct RecommendationKernel: Sendable, Equatable {
    let boundary: PrivateLifeRuntimeBoundary

    init(boundary: PrivateLifeRuntimeBoundary = .localOnly) {
        self.boundary = boundary
    }

    func canDriveRecommendation(
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

    func traceShape(for recommendationTrace: RecommendationTrace) -> String {
        [
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
