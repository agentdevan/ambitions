import Foundation

enum CaptureStageScene {
    static let contract = OverlayStageSceneContract(
        kind: .capture,
        ownerLayer: "Composer/Capture/Projection",
        routeBoundary: "Capture appears as a composer overlay, never a root route.",
        dockBehavior: "Root dock remains owned by persistent surfaces under the overlay.",
        focusRestoration: "Dismissal restores focus to the invoking surface action.",
        semanticMirror: "Capture overlay exposes accessibility summaries before mutation.",
        motionBehavior: "Stage/Motion coordinates composer reveal, reduction, and return.",
        proofBoundary: "Capture placement proof remains local and inspectable."
    )

    static func project(_ lens: OverlayLensReport) -> OverlayStageScene {
        OverlayStageScene(
            contract: contract,
            title: lens.title,
            primaryObject: lens.contract.primaryObject,
            visibleAction: lens.actionSummary,
            stateSummary: lens.primarySummary,
            accessibilitySummary: lens.accessibilitySummary,
            trustSummary: lens.trustSummary,
            failureSummary: lens.failureSummary
        )
    }
}
