import Foundation

extension SmartAttachmentResult {
    func captureRuntimeReceipt(
        timestamp: String,
        correction: CaptureRuntimeCorrectionInput? = nil
    ) -> CaptureRuntimeReceipt {
        captureRuntimeReplayTrace(timestamp: timestamp, correction: correction).receipt
    }

    func captureRuntimeReplayTrace(
        timestamp: String,
        correction: CaptureRuntimeCorrectionInput? = nil
    ) -> CaptureRuntimeReplayTrace {
        let futureProof = futureProofContextCandidate
        let runtimeFactoring = captureRuntimeFactoringCandidate
        let proposedDestinations = captureRuntimeProposedDestinations(correction: correction)
        let userDecision = CaptureRuntimeUserDecision(
            selectedRouteType: selectedCandidate?.target.routeType,
            selectedDestinationID: selectedCandidate?.target.destinationID,
            selectedDestinationLabel: selectedCandidate?.target.destinationLabel,
            decisionSummary: captureRuntimeDecisionSummary(correction: correction),
            correctionKind: correction?.kind,
            correctionNote: correction?.note
        )
        let futureUse = captureRuntimeFutureUse(
            futureProof: futureProof,
            runtimeFactoring: runtimeFactoring,
            hasSelectedCandidate: selectedCandidate != nil,
            correction: correction
        )
        let receiptKinds = captureRuntimeReceiptKinds(
            futureUse: futureUse,
            correction: correction
        )
        let receipt = captureRuntimeReceipt(
            timestamp: timestamp,
            correction: correction,
            futureUse: futureUse,
            receiptKinds: receiptKinds
        )

        return CaptureRuntimeReplayTrace(
            id: "capture-runtime-replay.\(id).\(receipt.kind.rawValue)",
            rawCapture: input.rawText,
            extraction: semanticExtraction,
            ambiguity: clarification,
            relevanceScan: goalRelevanceScan,
            proposedDestinations: proposedDestinations,
            userDecision: userDecision,
            runtimeUseStatus: captureRuntimeUseStatus(correction: correction, futureUse: futureUse),
            receipt: receipt,
            stagedInputs: receipt.stagedInputs,
            futureUse: futureUse,
            receiptKinds: receiptKinds
        )
    }
}
