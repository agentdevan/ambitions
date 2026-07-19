import Foundation

enum InspectionLens {
    static let contract = OverlayLensContract(
        kind: .inspection,
        ownerLayer: "Trust/Projection",
        primaryObject: "Trust inspection detail",
        projectionInputs: ["receipt search query", "receipt results", "privacy level", "proof relevance"],
        actionBoundary: "Inspection opens detail only when requested or required and does not become root navigation.",
        accessibilityBoundary: "VoiceOver reads receipt title, result, privacy, proof, undo, and hidden-detail state.",
        trustBoundary: "Inspection is local trust detail for source, proof, privacy, history, and receipts.",
        failureStates: ["empty result", "redacted result", "stale source", "missing receipt"]
    )

    static func project(_ projection: ActionReceiptSearchProjection) -> OverlayLensReport {
        let first = projection.results.first
        let accessibilitySummary = [first?.proofLabel, first?.hiddenDetailLabel]
            .compactMap { $0 }
            .joined(separator: ". ")
        return OverlayLensReport(
            contract: contract,
            title: first?.title ?? projection.emptyTitle,
            primarySummary: first?.summary ?? projection.emptyDetail,
            actionSummary: first?.undoLabel ?? "Review trust detail",
            accessibilitySummary: accessibilitySummary.isEmpty
                ? "No receipt detail matched. \(projection.emptyDetail)"
                : accessibilitySummary,
            trustSummary: projection.localOnly ? "Inspection remains local." : "Inspection source must be reviewed.",
            failureSummary: projection.isEmpty ? projection.emptyDetail : "Receipt detail is bounded by privacy and proof state."
        )
    }
}
