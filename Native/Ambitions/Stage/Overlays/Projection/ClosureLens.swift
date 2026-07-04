import Foundation

enum ClosureLens {
    static let contract = OverlayLensContract(
        kind: .closure,
        ownerLayer: "Stage/Overlays/Projection",
        primaryObject: "Action closure outcome review",
        projectionInputs: ["closure prompt", "outcome options", "proof preview", "undo preview"],
        actionBoundary: "Closure saves only after the selected outcome explains visible mutation, receipt, and undo state.",
        accessibilityBoundary: "VoiceOver reads prompt, primary outcomes, receipt preview, privacy, and confirm action.",
        trustBoundary: "Closure receipts stay local and inspectable through proof, source, and history.",
        failureStates: ["no matching outcome", "receipt unavailable", "undo unavailable", "recovery needed"]
    )

    static func project(_ state: TodayActionClosureSheetState) -> OverlayLensReport {
        let primaryTitles = state.primaryOutcomes.map(\.title).joined(separator: ", ")
        return OverlayLensReport(
            contract: contract,
            title: state.prompt,
            primarySummary: state.objectTitle,
            actionSummary: "\(state.confirmTitle): \(primaryTitles)",
            accessibilitySummary: state.visibleCopy,
            trustSummary: "\(state.privacyLabel). \(state.recoveryReceiptLabel)",
            failureSummary: state.moreOutcomes.isEmpty ? "Primary outcomes cover this closure." : "Advanced outcomes stay available for recovery."
        )
    }
}
