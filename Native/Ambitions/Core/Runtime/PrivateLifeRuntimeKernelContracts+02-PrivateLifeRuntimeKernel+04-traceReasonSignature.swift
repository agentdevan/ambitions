import Foundation

extension PrivateLifeRuntimeKernel {

    static func traceReasonSignature(_ reason: RecommendationTraceReason) -> String {
        [
            reason.explanationID,
            reason.summary,
            reason.evidenceCategoryIDs.sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
    }


    static func traceFitSignature(_ fit: RecommendationTraceFit) -> String {
        [
            fit.state.rawValue,
            fit.blockReasons.sorted().joined(separator: ","),
            fit.canDriveRecommendation ? "drive" : "review"
        ]
        .joined(separator: "|")
    }


    static func traceUncertaintySignature(_ uncertainty: RecommendationTraceUncertainty) -> String {
        [
            uncertainty.uncertaintyIDs.sorted().joined(separator: ","),
            uncertainty.summaries.sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
    }


    static func traceControlSignature(_ control: RecommendationTraceControl) -> String {
        [
            control.correctionActionIDs.sorted().joined(separator: ","),
            control.controlActionIDs.sorted().joined(separator: ","),
            control.correctableFieldKeys.sorted().joined(separator: ","),
            control.hasRequiredControl ? "required" : "optional"
        ]
        .joined(separator: "|")
    }


    static func traceReceiptSignature(_ receiptBehavior: RecommendationTraceReceiptBehavior) -> String {
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
