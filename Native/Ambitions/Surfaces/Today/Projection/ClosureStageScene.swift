import Foundation

enum ClosureStageScene {
    static let contract = OverlayStageSceneContract(
        kind: .closure,
        ownerLayer: "Surfaces/Today/Projection",
        routeBoundary: "Closure appears as a bounded overlay after a surface action.",
        dockBehavior: "Root dock does not duplicate inside closure drilldown.",
        focusRestoration: "Dismissal restores focus to the completed step.",
        semanticMirror: "Closure overlay mirrors accessibility outcome, undo, proof, and recovery.",
        motionBehavior: "Stage/Motion coordinates closure confirmation and undo return.",
        proofBoundary: "Closure receipts stay local and reviewable."
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
