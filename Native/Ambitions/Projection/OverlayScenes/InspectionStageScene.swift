import Foundation

enum InspectionStageScene {
    static let contract = OverlayStageSceneContract(
        kind: .inspection,
        ownerLayer: "Projection/OverlayScenes",
        routeBoundary: "Inspection appears as a trust-detail overlay, never a root surface.",
        dockBehavior: "Root dock remains owned by the invoking root surface.",
        focusRestoration: "Dismissal restores focus to the inspected receipt control.",
        semanticMirror: "Inspection overlay mirrors accessibility proof, privacy, source, and receipt.",
        motionBehavior: "Stage/Motion coordinates detail reveal and reduced transitions.",
        proofBoundary: "Inspection exposes only local proof and privacy summaries."
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
